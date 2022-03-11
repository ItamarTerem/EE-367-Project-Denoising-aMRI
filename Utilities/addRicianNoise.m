function noisyVideo = addRicianNoise(video,s)
% This function will add Rician noise to the MRI image with a given S
% factor
    
    nFrames = size(video,3);
    noisyVideo = zeros(size(video));
    for i = 1:nFrames
        noisyVideo(:,:,i) = ricernd(video(:,:,i), s);
    end
end