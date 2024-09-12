%% createStimuli_color.m 
%  This script demonstrates how to apply wavestrapping to color images.
%  The procedure outlined here is described in section 2.3 of the following paper:
%  Puckett AM, Schira MM, Isherwood ZJ, Victor JD, Roberts JA, and 
%  Breakspear M. (2020) "Manipulating the structure of natural scenes using
%  wavelets to study the functional architecture of perceptual hierarchies 
%  in the brain" NeuroImage. 
%  https://www.sciencedirect.com/science/article/pii/S1053811920306595

%  Written by A.M.P. 2019.

%% Input
inImage = imread(strcat('stimuli_color/wombat.JPG'));

% Make image square 1536 x 1536
N = 1536; 
inImage = inImage(1:N, :,:);

% Split out color components
inR_square = inImage(:,:,1);
inG_square = inImage(:,:,2);
inB_square = inImage(:,:,3);

%% Wavestrap each channel independently --> will mix up color pallete across space
inR_wav=wavesurr2(inR_square,[2 4 6],'db6',1,0);   
inG_wav=wavesurr2(inG_square,[2 4 6],'db6',1,0); 
inB_wav=wavesurr2(inB_square,[2 4 6],'db6',1,0); 

%Adjust so histogram of wavestrapped iamge matches original
XR=inR_square(:);           
sX=inR_wav(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XR);
M=sortrows(M,2);
YR=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one

XG=inG_square(:);          
sX=inG_wav(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XG);
M=sortrows(M,2);
YG=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one

XB=inB_square(:);           
sX=inB_wav(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XB);
M=sortrows(M,2);
YB=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
    
inR_wav = uint8(YR);
inG_wav = uint8(YG);
inB_wav = uint8(YB);

% Output wavestrapped image
outImage = cat(3,inR_wav,inG_wav,inB_wav);
imwrite(im2uint8(outImage),strcat('stimuli_color/wombat_wavestrapped_randomSeed.tiff'))

%% Wavestrap each channel with the same seed --> will retain original color pallete across space

inR_wavC=wavesurr2(inR_square,[2 4 6],'db6',1,1);
inG_wavC=wavesurr2(inG_square,[2 4 6],'db6',1,1); 
inB_wavC=wavesurr2(inB_square,[2 4 6],'db6',1,1); 

%Adjust so histogram of wavestrapped iamge matches original
XR=inR_square(:);           
sX=inR_wavC(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XR);
M=sortrows(M,2);
YRC=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one

XG=inG_square(:);           
sX=inG_wavC(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XG);
M=sortrows(M,2);
YGC=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one

XB=inB_square(:);           
sX=inB_wavC(:);       %wavelet shuffled image
M(:,1)=sX; M(:,2)=1:N^2;
M=sortrows(M,1);
M(:,1)=sortrows(XB);
M=sortrows(M,2);
YBC=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one

inR_wavC = uint8(YRC);
inG_wavC = uint8(YGC);
inB_wavC = uint8(YBC);

% Output wavestrapped image
outImageC = cat(3,inR_wavC,inG_wavC,inB_wavC);
imwrite(im2uint8(outImageC),strcat('stimuli_color/wombat_wavestrapped_constantSeed.tiff'))