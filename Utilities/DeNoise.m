function deNoiseVideo = DeNoise(noisyVideo,method,s)
% This function will denoise the noisy MRI image with the given denoising
% algorithm

    
    nFrames = size(noisyVideo,3);
    deNoiseVideo = zeros(size(noisyVideo));
    switch char(method)
        case 'NonLocalMeans'
            for i = 1:nFrames
                deNoiseVideo(:,:,i) = imnlmfilt(noisyVideo(:,:,i));
            end
        case 'BM3D'
            for i = 1:nFrames
                deNoiseVideo(:,:,i) = BM3D(noisyVideo(:,:,i),s);
            end
        case 'DnCNN'
            net = denoisingNetwork('DnCNN');
            for i = 1:nFrames
                deNoiseVideo(:,:,i) = denoiseImage(noisyVideo(:,:,i),net);
            end
    end
   
end