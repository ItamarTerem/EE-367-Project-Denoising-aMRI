# EE-367-Project-Denoising-aMRI
Stanford EE367 / CS448I: Computational Imaging course project

Author: Itamar Terem, 2022 
Contact Information: iterem@stanford.edu
Title: Denoising for amplified Magnetic Resonance Imaging (aMRI)

This repository contain the source codes for the project titiled: "Denoising for amplified Magnetic Resonance Imaging (aMRI)", where different denoising algorithms were evaluated for th ability to improve the results of motion magnification in 'cine' MRI. 

The repository contain the main following files:
1. main.m - The main code will run and generate the results of the report. 
2. video.m - contain the 'cine' MRI data. 
3. 2DaMRI folder - contain the phase based motion magnification code with all the extra necessary files. 
4. Denoisers folder - contain the BM3D algorithm files. 
5. RicianNoise folder - contain the codes for adding Rician noise to the MRI images.
6. Utilities folder - contain the codes for: adding Rician noise, denoisng wrap, generating videos, figures and standard deviation maps, and calculating the PSNR and SSIM.
