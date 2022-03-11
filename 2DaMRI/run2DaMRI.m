function amp = run2DaMRI(video,s,state,denoiser,folder,alpha,sigma)

% This function will run the amplification algorithm (aMRI.m), and will
% save the videos, and STD maps to the result folder


    mkdir([folder denoiser])
    resultsDir = [folder denoiser '/' ];
    nFrames = 20;
    heart_rate = 60;
    fl = (60/heart_rate) - 0.1 ; 
    fh = (60/heart_rate) + 0.1;
    samplingRate = nFrames/(60/heart_rate) ; 
    amp = aMRI(video,samplingRate,fl,fh,alpha,true,'octave',sigma);

    switch state
        case 'deNoise'
            stateName = '_denoise_';
        case 'Noise'
            stateName = '_noise_';        
    end

    outName = [resultsDir '/Output_' stateName num2str(s) '_amp_' num2str(alpha) '_sig_' num2str(sigma)  '.mat'];
    save(outName,'amp','video');

    generateVideos(video,amp,resultsDir,s,alpha,sigma,state)
    generateStdMaps(video,amp,resultsDir,s,alpha,sigma,state)

end

