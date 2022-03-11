function generateVideos(video,ampVideo,resultsDir,s,alpha,sigma,state)

% This function generates the original and amplify mp4 videos  
    
    nFrames = size(video,3);
    FrameRate = nFrames;
    
    for k = 1:nFrames
        outA(:,:,1,k) = ampVideo(:,:,k);
        outO(:,:,1,k)= video(:,:,k);  
    end
    
    outA = mat2gray(outA);
    outO = mat2gray(outO);

    switch state
        case 'deNoise'
            stateName = '_denoise_';
        case 'Noise'
            stateName = '_noise_';        
    end

    outName = 'amplified_saggital' ;
    vidOut = VideoWriter([resultsDir '/' outName stateName num2str(s) '_amp_' num2str(alpha) '_sig_' num2str(sigma)  '.mp4'],'MPEG-4');
    vidOut.FrameRate = FrameRate;
    open(vidOut);
    writeVideo(vidOut,outA);
    close(vidOut);
    
    vidOut = VideoWriter([resultsDir '/original_saggital' stateName num2str(s) '.mp4'],'MPEG-4');
    vidOut.FrameRate = FrameRate;
    open(vidOut);
    writeVideo(vidOut,outO);
    close(vidOut);
    

end