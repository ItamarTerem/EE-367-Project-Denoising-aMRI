clear; clc; close all;
addpath(genpath('/Users/Itamar/opt/anaconda3/envs/EE367/homework/project2/code/'));
cd('/Users/Itamar/opt/anaconda3/envs/EE367/homework/project2/code/')
resultsDir = ['/Users/Itamar/opt/anaconda3/envs/EE367/homework/project2/results/'];

%Load Data  
temp = load('video.mat');
video = mat2gray(squeeze(temp.video));

%Reference amplify video
alpha = 15;
sigma = 5;
tempFolder = [resultsDir 'Referece/'];
mkdir(tempFolder)
ampRef = run2DaMRI(video,0,'Noise','reference',tempFolder,alpha,sigma);

%Denosing algorithms
Denoise = {'NonLocalMeans','BM3D','DnCNN'};

%% PSNR Different Noise Level (without Amplification) 
tempFolder = [resultsDir 'RicianSFactorNoAmp/'];
mkdir(tempFolder)
s = [0.0063,0.0125,0.025,0.05,0.1];
BM3DsFactor = [0.01,0.02,0.03,0.055,0.09];
N = length(s);

NoAmpDeNoisePSNR = zeros([3,N]);
NoAmpDeNoiseSSIM = zeros([3,N]);

for i = 1:length(s)
    noisyVideo = addRicianNoise(video,s(i));
    for j=1:3
        deNoiseVideo = DeNoise(noisyVideo,Denoise(j),BM3DsFactor(i));
        NoAmpDeNoisePSNR(j,i) = meanPSNR(deNoiseVideo ,video);
        NoAmpDeNoiseSSIM(j,i) = meanSSIM(deNoiseVideo ,video);    
    end
end

save([tempFolder 'NoAmpDeNoisePSNR.mat'],'NoAmpDeNoisePSNR');
save([tempFolder 'NoAmpDeNoiseSSIM.mat'],'NoAmpDeNoiseSSIM');


generateFigures(s,NoAmpDeNoisePSNR,NoAmpDeNoisePSNR,NoAmpDeNoiseSSIM,NoAmpDeNoiseSSIM,1)
%% PSNR Different Noise Level (with Amplification)

tempFolder = [resultsDir 'RicianSFactorAmp/'];
mkdir(tempFolder)

DeNoisePSNR = zeros([3,N]);
NoisePSNR = zeros([1,N]);e
DeNoiseSSIM = zeros([3,N]);
NoiseSSIM = zeros([1,N]);
for i = 1:length(s)
    noisyVideo = addRicianNoise(video,s(i));
    ampNoise = run2DaMRI(noisyVideo,s(i),'Noise','NoDenoiser',tempFolder,alpha,sigma);
    NoisePSNR(i) = meanPSNR(ampNoise,ampRef);
    NoiseSSIM(i) = meanSSIM(ampNoise,ampRef);

    for j=1:3
        deNoiseVideo = DeNoise(noisyVideo,Denoise(j),BM3DsFactor(i));
        ampDeNoise = run2DaMRI(deNoiseVideo,s(i),'deNoise',char(Denoise(j)),tempFolder,alpha,sigma);
        DeNoisePSNR(j,i) = meanPSNR(ampDeNoise,ampRef);
        DeNoiseSSIM(j,i) = meanSSIM(ampDeNoise,ampRef);    
    end
end

save([tempFolder 'DeNoisePSNR.mat'],'DeNoisePSNR');
save([tempFolder 'NoisePSNR.mat'],'NoisePSNR');
save([tempFolder 'NoiseSSIM.mat'],'NoiseSSIM');
save([tempFolder 'DeNoiseSSIM.mat'],'DeNoiseSSIM');

generateFigures(s,DeNoisePSNR,NoisePSNR,DeNoiseSSIM,NoiseSSIM,0)
%% PSNR as a function of amplification factor 

tempFolder = [resultsDir 'MagnificationFactor/'];
mkdir(tempFolder)
magnification = [2.5,5,7.5,10,12.5,15,17.5,20];
N = length(magnification);
AmpDeNoisePSNR = zeros([3,N]);
AmpNoisePSNR = zeros([1,N]);
AmpDeNoiseSSIM = zeros([3,N]);
AmpNoiseSSIM = zeros([1,N]);t

for i = 1:length(magnification)
    noisyVideo = addRicianNoise(video,0.025);
    ampNoise = run2DaMRI(noisyVideo,0.025,'Noise','NoDenoiser',tempFolder,magnification(i),sigma);
    AmpNoisePSNR(i) = meanPSNR(ampNoise,ampRef);
    AmpNoiseSSIM(i) = meanSSIM(ampNoise,ampRef);
    for j=1:3
   
        deNoiseVideo = DeNoise(noisyVideo,Denoise(j),0.03);
        ampDeNoise = run2DaMRI(deNoiseVideo,0.025,'deNoise',char(Denoise(j)),tempFolder,magnification(i),sigma);
        
        AmpDeNoisePSNR(j,i) = meanPSNR(ampDeNoise,ampRef);
        AmpDeNoiseSSIM(j,i) = meanSSIM(ampDeNoise,ampRef);
        
    end
end

save([tempFolder '/AmpDeNoisePSNR.mat'],'AmpDeNoisePSNR');
save([tempFolder '/AmpNoisePSNR.mat'],'AmpNoisePSNR');
save([tempFolder '/AmpDeNoiseSSIM.mat'],'AmpDeNoiseSSIM');
save([tempFolder '/AmpNoiseSSIM.mat'],'AmpNoiseSSIM');

generateFigures(magnification,AmpDeNoisePSNR,AmpNoisePSNR,AmpDeNoiseSSIM,AmpNoiseSSIM,0)

%% PSNR as a function of sigma 

tempFolder = [resultsDir 'SigmaFactor/'];
mkdir(tempFolder) 
sigmas = [2.5,5,7.5,10,12.5,15];
N = length(sigmas);
SigDeNoisePSNR = zeros([3,N]);
SigNoisePSNR = zeros([1,N]);
SigDeNoiseSSIM = zeros([3,N]);
SigNoiseSSIM = zeros([1,N]);

for i = 1:length(sigmas)
    noisyVideo = addRicianNoise(video,0.025);
    ampNoise = run2DaMRI(noisyVideo,0.025,'Noise','NoDenoiser',tempFolder,alpha,sigmas(i));
    SigNoisePSNR(i) = meanPSNR(ampNoise,ampRef);
    SigNoiseSSIM(i) = meanSSIM(ampNoise,ampRef);
    for j=1:3
        deNoiseVideo = DeNoise(noisyVideo,Denoise(j),0.03);
        ampDeNoise = run2DaMRI(deNoiseVideo,0.025,'deNoise',char(Denoise(j)),tempFolder,alpha,sigmas(i));
        
        SigDeNoisePSNR(j,i) = meanPSNR(ampDeNoise,ampRef);
        SigDeNoiseSSIM(j,i) = meanSSIM(ampDeNoise,ampRef);    
    end
end

save([tempFolder '/SigDeNoisePSNR.mat'],'SigDeNoisePSNR');
save([tempFolder '/SigNoisePSNR.mat'],'SigNoisePSNR');
save([tempFolder '/SigDeNoiseSSIM.mat'],'SigDeNoiseSSIM');
save([tempFolder '/SigNoiseSSIM.mat'],'SigNoiseSSIM');

generateFigures(sigmas,SigDeNoisePSNR,SigNoisePSNR,SigDeNoiseSSIM,SigNoiseSSIM,0)


















 


