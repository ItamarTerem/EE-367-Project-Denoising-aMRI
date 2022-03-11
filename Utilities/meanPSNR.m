function meanPSNR = meanPSNR(Video,refVideo)

% This function calculate the temporal mean PSNR over the brain tissue, excluding the background

    mask = load('Utilities/mask.mat');
    mask = mask.mask;
    nFrames = size(Video,3);
    PSNR = zeros([nFrames,1]);
    for i = 1:nFrames
        temp1 = Video(:,:,i);
        temp2 = refVideo(:,:,i);
        PSNR(i) = psnr(temp1(mask == 1),temp2(mask == 1));   
    end
    meanPSNR = mean(PSNR);
end