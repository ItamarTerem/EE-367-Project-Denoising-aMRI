function generateFigures(x,y1,y2,y3,y4,flag)

% This function will generate the plot of the PSNR and SSIM 

if flag == 0

    hFig1 = figure; hold on;
    h11 = plot(x,y1(1,:),'r');
    h12 = plot(x,y1(2,:),'g');
    h13 = plot(x,y1(3,:),'b');
    h14 = plot(x,y2(1,:),'m');
    
    xlabel('S factor','FontSize',40,'FontWeight', 'bold' ); ylabel('PSNR','FontSize',40,'FontWeight', 'bold' );
    set(gcf,'color','w'); 
    legend([h11 h12 h13 h14],'Non-Local Means','BM3D','DnCNN','Noisy Video','FontSize',30,'FontWeight', 'bold' )
    set(gca,'FontSize',40)
    
    hFig2 = figure; hold on;
    h21 = plot(x,y3(1,:),'r');
    h22 = plot(x,y3(2,:),'g');
    h23 = plot(x,y3(3,:),'b');
    h24 = plot(x,y4,'m');
    
    xlabel('S factor','FontSize',40,'FontWeight', 'bold' ); ylabel('SSIM','FontSize',40,'FontWeight', 'bold' );
    set(gcf,'color','w'); 
    legend([h21 h22 h23 h24],'Non-Local Means','BM3D','DnCNN','Noisy Video','FontSize',30,'FontWeight', 'bold' )
    set(gca,'FontSize',40)
else
    hFig1 = figure; hold on;
    h11 = plot(x,y1(1,:),'r');
    h12 = plot(x,y1(2,:),'g');
    h13 = plot(x,y1(3,:),'b');
    
    xlabel('S factor','FontSize',40,'FontWeight', 'bold' ); ylabel('PSNR','FontSize',40,'FontWeight', 'bold' );
    set(gcf,'color','w'); 
    legend([h11 h12 h13],'Non-Local Means','BM3D','DnCNN','FontSize',30,'FontWeight', 'bold' )
    set(gca,'FontSize',40)
    
    hFig2 = figure; hold on;
    h21 = plot(x,y3(1,:),'r');
    h22 = plot(x,y3(2,:),'g');
    h23 = plot(x,y3(3,:),'b');
    
    xlabel('S factor','FontSize',40,'FontWeight', 'bold' ); ylabel('SSIM','FontSize',40,'FontWeight', 'bold' );
    set(gcf,'color','w'); 
    legend([h21 h22 h23],'Non-Local Means','BM3D','DnCNN','FontSize',30,'FontWeight', 'bold' )
    set(gca,'FontSize',40)


end

end