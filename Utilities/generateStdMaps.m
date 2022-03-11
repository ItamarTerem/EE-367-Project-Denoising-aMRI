
function generateStdMaps(video,ampVideo,resultsDir,s,alpha,sigma,state)

% This function generates the temporal standard deviation maps  

    switch state
        case 'deNoise'
            stateName = '_denoise_';
        case 'Noise'
            stateName = '_noise_';        
    end
    
    outName = [resultsDir '/Sagittal_std_Original_' stateName num2str(s) '_amp_' num2str(alpha) '_sig_' num2str(sigma)  '.tiff'];
    hFig = figure;
    imshow(mat2gray(std(video,[],3)));
    caxis manual;
    caxis([0 1]);
    colormap jet; colorbar; axis off; axis square;
    saveas(hFig,outName)


    
    outName = [resultsDir '/Sagittal_std_Amplify_' stateName num2str(s) '_amp_' num2str(alpha) '_sig_' num2str(sigma)  '.tiff'];
    hFig = figure;
    imshow(mat2gray(std(ampVideo,[],3)));
    caxis manual;
    caxis([0  1]);
    colormap jet; colorbar; axis off; axis square;
    saveas(hFig,outName)

    close all; 

end