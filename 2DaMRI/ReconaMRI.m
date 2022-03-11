%2DaMRI(VIDFILE, MAGPHASE, FL, FH, FS, OUTDIR, VARARGIN) 
% 
% Takes input VIDFILE and motion magnifies the motions that are within a
% passband of FL to FH Hz by MAGPHASE times. FS is the videos sampling rate
% and OUTDIR is the output directory. 
%
% Optional arguments:
% attenuateOtherFrequencies (false)
%   - Whether to attenuate frequencies in the stopband  
% pyrType                   ('halfOctave')
%   - Spatial representation to use (see paper)
% sigma                     (0)            
%   - Amount of spatial smoothing (in px) to apply to phases 
% temporalFilter            (FIRWindowBP) 
%   - What temporal filter to use
%

function [vid ,amp_d, amp_i,amp_d_res, amp_i_res] = ReconaMRI(vidFile,outDir,fs,fl,fh,magPhase,varargin)

     vid=squeeze(vidFile);
     [h,w,nF]=size(vid);
   
      
    %% Parse Input
    p = inputParser();

    defaultAttenuateOtherFrequencies = false; %If true, use reference frame phases
    pyrTypes = {'octave', 'halfOctave', 'smoothHalfOctave', 'quarterOctave'}; 
    checkPyrType = @(x) find(ismember(x, pyrTypes));
    defaultPyrType = 'octave';
    defaultSigma = 0;
    defaultTemporalFilter = @FIRWindowBP;
    defaultTemporalFilterBS = @FIRWindowBS;
    
    addOptional(p, 'attenuateOtherFreq', defaultAttenuateOtherFrequencies, @islogical);
    addOptional(p, 'pyrType', defaultPyrType, checkPyrType);
    addOptional(p,'sigma', defaultSigma, @isnumeric);   
    addOptional(p, 'temporalFilter', defaultTemporalFilter);
    addOptional(p, 'temporalFilterBS', defaultTemporalFilterBS);
    
    parse(p, varargin{:});

    refFrame = 1;
    attenuateOtherFreq = p.Results.attenuateOtherFreq;
    pyrType            = p.Results.pyrType;
    sigma              = p.Results.sigma;
    temporalFilter     = p.Results.temporalFilter;
    temporalFilterBS     = p.Results.temporalFilterBS;

    %% Compute spatial filters        
   
    fprintf('Computing spatial filters\n');
    ht = maxSCFpyrHt(zeros(h,w));
    switch pyrType
        case 'octave'
            filters = getFilters([h w], 2.^[0:-1:-ht], 4);
            fprintf('Using octave bandwidth pyramid\n');        
        case 'halfOctave'            
            filters = getFilters([h w], 2.^[0:-0.5:-ht], 8,'twidth', 0.75);
            fprintf('Using half octave bandwidth pyramid\n'); 
        case 'smoothHalfOctave'
            filters = getFiltersSmoothWindow([h w], 8, 'filtersPerOctave', 2);           
            fprintf('Using half octave pyramid with smooth window.\n');
        case 'quarterOctave'
            filters = getFiltersSmoothWindow([h w], 8, 'filtersPerOctave', 4);
            fprintf('Using quarter octave pyramid.\n');
        otherwise 
            error('Invalid Filter Types');
    end

    [croppedFilters, filtIDX] = getFilterIDX(filters);
    
    %% Initialization of motion magnified luma component
    magnifiedLumaFFT = zeros(h,w,nF,'single');
    BS = zeros(h,w,nF,'single');
    
    buildLevel = @(im_dft, k) ifft2(ifftshift(croppedFilters{k}.* ...
        im_dft(filtIDX{k,1}, filtIDX{k,2})));
    
    reconLevel = @(im_dft, k) 2*(croppedFilters{k}.*fftshift(fft2(im_dft)));


    %% First compute phase differences from reference frame
    numLevels = numel(filters);        
    fprintf('Moving video to Fourier domain\n');
    vidFFT = zeros(h,w,nF,'single');
    
    for k = 1:nF
        vidFFT(:,:,k) = single(fftshift(fft2(im2single(vid(:,:,k)))));
    end
    
    for level = 2:numLevels-1
      %% Compute phases of level
        % We assume that the video is mostly static
        pyrRef = buildLevel(vidFFT(:,:,refFrame), level);        
        pyrRef = angle(pyrRef);
        
        delta = zeros(size(pyrRef,1), size(pyrRef,2) ,nF,'single');
        residual = zeros(size(pyrRef,1), size(pyrRef,2) ,nF,'single');
       
        fprintf('Processing level %d of %d\n', level, numLevels);
           
        for frameIDX = 1:nF
            filterResponse = buildLevel(vidFFT(:,:,frameIDX), level);
            pyrCurrent = angle(filterResponse);
            delta(:,:,frameIDX) = single(mod(pi+pyrCurrent-pyrRef,2*pi)-pi); 
            residual(:,:,frameIDX) = single(mod(pi+pyrCurrent-pyrRef,2*pi)-pi); 
        end
       
  
        % Temporal Filtering
        fprintf('Bandpassing phases\n');
        temp = delta; 
        delta = temporalFilter(delta, fl/fs,fh/fs);
        residual = temp - delta; % temporalFilterBS(residual, fl/fs,fh/fs);
        
        %% Apply magnification
        fprintf('Applying magnification\n');
        for frameIDX = 1:nF

            phaseOfFrame = delta(:,:,frameIDX);
            resPhaseOfFrame = residual(:,:,frameIDX);

            originalLevel = buildLevel(vidFFT(:,:,frameIDX),level);
            
            %% Amplitude Weighted Blur        
            if (sigma~= 0)
                phaseOfFrame = AmplitudeWeightedBlur(phaseOfFrame, abs(originalLevel)+eps, sigma);
                resPhaseOfFrame = AmplitudeWeightedBlur(resPhaseOfFrame, abs(originalLevel)+eps, sigma); 
            end

            % Increase phase variation
            phaseOfFrame = magPhase *phaseOfFrame;  
            resPhaseOfFrame = magPhase *resPhaseOfFrame;
            
            if (attenuateOtherFreq)
                %tempOrig = abs(originalLevel).*pyrRefPhaseOrig;
                tempOrig = abs(originalLevel).*exp(1i*pyrRef);
                
            else
                tempOrig = originalLevel;
            end
            
            tempTransformOut = exp(1i*phaseOfFrame).*tempOrig;
            tempTransformOutRes = exp(1i*resPhaseOfFrame).*tempOrig;

           
            curLevelFrame = reconLevel(tempTransformOut, level);
            curLevelFrameRes = reconLevel(tempTransformOutRes, level);

            magnifiedLumaFFT(filtIDX{level,1}, filtIDX{level,2},frameIDX) = curLevelFrame + magnifiedLumaFFT(filtIDX{level,1}, filtIDX{level,2},frameIDX);
            BS(filtIDX{level,1}, filtIDX{level,2},frameIDX) = curLevelFrameRes + BS(filtIDX{level,1}, filtIDX{level,2},frameIDX);
        end
    end
 
    %% Add unmolested lowpass residual
    
    level = numel(filters);
    for frameIDX = 1:nF 
        lowpassFrame = (vidFFT(filtIDX{level,1},filtIDX{level,2},frameIDX).*croppedFilters{end}.^2);
        magnifiedLumaFFT(filtIDX{level,1},filtIDX{level,2},frameIDX) = magnifiedLumaFFT(filtIDX{level,1},filtIDX{level,2},frameIDX) + lowpassFrame; 
        BS(filtIDX{level,1},filtIDX{level,2},frameIDX) = BS(filtIDX{level,1},filtIDX{level,2},frameIDX) + lowpassFrame;    
    end 
     
    amp_i = zeros(h,w,nF,'int16');  
    amp_d = zeros(h,w,nF,'double');

    amp_i_res = zeros(h,w,nF,'int16');  
    amp_d_res = zeros(h,w,nF,'double');
    
    % moving volume back to spatial domain
    for k = 1:nF
        out = real(ifftn(ifftshift(magnifiedLumaFFT(:,:,k))));
        outRes = real(ifftn(ifftshift(BS(:,:,k))));
        
        amp_d(:,:,k)=out;
        amp_i(:,:,k) = im2int16(out);
        amp_d_res(:,:,k)=outRes;
        amp_i_res(:,:,k) = im2int16(outRes);
    end
    

% saving the amplify data as int 16.
Iamp = amp_i;
Iorg = vid;
save([outDir '/Output.mat'],'Iamp','Iorg','amp_d');
  
end

