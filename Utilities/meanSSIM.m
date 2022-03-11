function meanSSIM = meanSSIM(Video,refVideo)

% This function calculate the temporal mean SSIM over the brain tissue, excluding the background

    mask = load('Utilities/mask.mat');
    mask = mask.mask;
    nFrames = size(Video,3);
    SSIM = zeros([nFrames,1]);
    for i = 1:nFrames
        temp1 = Video(:,:,i);
        temp2 = refVideo(:,:,i);
        SSIM(i) = ssim(temp1(mask == 1),temp2(mask == 1));   
    end
    meanSSIM = mean(SSIM);
end
