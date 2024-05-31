%% createStimuli_fMRI.m 
%  This script demonstrates how to apply wavestrapping to disrupt natural
%  image structure at specific spatial scales. The procedure outlined here 
%  was used to construct the stimuli used in the fMRI experiment described 
%  in Section 3 of the following paper:
%  Puckett AM, Schira MM, Isherwood ZJ, Victor JD, Roberts JA, and 
%  Breakspear M. (2020) "Manipulating the structure of natural scenes using
%  wavelets to study the functional architecture of perceptual hierarchies 
%  in the brain" NeuroImage. 
%  https://www.sciencedirect.com/science/article/pii/S1053811920306595

%  Written by A.M.P. sometime back in 2013/2014. Revised 2020.

%% Clear and set
clear
dwtmode('per') 

%% Input
% This is demonstrated using a single image from the Zurich Natural Image
% Database (https://www.tu-chemnitz.de/physik/PHKP/ZurichNatImgDB.html.en).

% Note that it is set up to run over all 50 of the images used in our study. 
imName = {'DSCN2188';'F07_NE-HA_output01';'F33_NE-HA_output01';'F11_NE-HA_output01';...
    'F11_NE-HA_output31'};

% Define wavestrapping parameters
wv = 'db12'; % Which wavelet: use 6th order Daubechies wavelet
cz = 1; % Which resampling scheme: 1 = permute, 2 = rotate

% Now define spatial scale levels
% Images that are 1536x1536 (like that used here) appear to be affected up
% to level 10. We will be targeting different levels to construct our stimuli.
nNoise = 1:5;% [1 2 3 4 5 6 7 8 9 10]; % So to destroy ALL structure, must target all 10 scales
nS1 = 3; % Fine scale (see publication for more details)
nS2 = 5; % Coarse scale
nS12 = [3 5]; % Both fine and coarse scale
nAllButS12 = [1 2 4 6 7 8 9 10]; % All scales except fine and coarse

rads=[230 220];%[230 172];

origImageDim = [464 464];% [1536 1536]; %image dimensions of original
N = 464;%768; % will end up resizing to 768 x 768

%% Create stimuli
for j = 3:5 % Can be used to loop over all stimuli listed above. Here only using one image. 
    
    %Read image in, convert to grayscale, and make square. 
    inImage = imread(strcat('stimuli_fMRI/',imName{j},'.PNG'));
    template = imread(strcat('stimuli_fMRI/template.PNG'));
    template = template(:,:,1)~=0;
    %inImage = rgb2gray(inImage);
    imageOrig = im2double(inImage);
    imageOrig = imageOrig.*template;
    template = template(:,round((size(imageOrig,2)-origImageDim(1))/2):size(imageOrig,2)-round((size(imageOrig,2)-origImageDim(2))/2)-1);
    imageOrig = imageOrig(:,round((size(imageOrig,2)-origImageDim(1))/2):size(imageOrig,2)-round((size(imageOrig,2)-origImageDim(2))/2)-1);
    

    % Now we start to construct the stimuli for the different experimental
    % blocks ('B' used to denote different blocks). 
    
    % B1, B2_1, B7_1
    imageOrigResize = imageOrig;
    %imageOrigResize = imageOrig(111:1426,111:1426);
    %imageOrigResize = imresize(imageOrigResize,0.5835);
    imwrite(im2uint8(imageOrigResize),strcat('stimuli_fMRI/B1/N1S0F0R0_',num2str(j),'_1.tiff'))
    imwrite(im2uint8(imageOrigResize),strcat('stimuli_fMRI/B2/N1S1F1R1_',num2str(j),'_1.tiff'))
    imwrite(im2uint8(imageOrigResize),strcat('stimuli_fMRI/B7/N1S2F1R1_',num2str(j),'_1.tiff'))

    % B2_2
    %imageN1S1F1R1 = rectsurr2(imageOrig, nS1, wv, cz, 19/20); % wavestrap using rectsurr2
    % rectsur2 resampled a central rectangular region. Here we are resampling the
    % inner 19/20ths while leaving a 1/20 border untouched. Then we crop.
    % This approach was chosen due to issues with edge artifacts. 
    imageN1S1F1R1 = elipsurr2(imageOrig, nS1, wv, cz, rads);
    %imageN1S1F1R1Resize = imageN1S1F1R1(111:1426,111:1426); %Crop
    %imageN1S1F1R1Resize = imresize(imageN1S1F1R1Resize,0.5835); %Now resize
    imageN1S1F1R1Resize = imageN1S1F1R1;

    %Adjust amplitudes so histogram of wavestrapped image matches original
    X=imageOrigResize(:);           
    sX=imageN1S1F1R1Resize(:); %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N); %surrogate image with amplitude spectra of natural one
        Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    %Write out image and clear some variables
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B2/N1S1F1R1_',num2str(j),'_2.tiff'))
    clear sX M Y

    % B3
    for k = 1:16
        imageN1S1F2R1 = rectsurr2(imageOrig, nS1, wv, cz, 19/20);
        %imageN1S1F2R1Resize = imageN1S1F2R1(111:1426,111:1426); 
        %imageN1S1F2R1Resize = imresize(imageN1S1F2R1Resize,0.5835);
        imageN1S1F2R1Resize = imageN1S1F2R1;

        %Adjust amplitudes so histogram of degraded iamge matches natural
        sX=imageN1S1F2R1Resize(:);       
        M(:,1)=sX; M(:,2)=1:N^2;
        M=sortrows(M,1);
        M(:,1)=sortrows(X);
        M=sortrows(M,2);
        Y=reshape(M(:,1),N,N);   
        Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
        imwrite(im2uint8(Y),strcat('stimuli_fMRI/B3/N1S1F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        clear sX M Y
    end

    % B7_2
    imageN1S2F1R1 = rectsurr2(imageOrig, nS2, wv, cz, 19/20);
    %imageN1S2F1R1Resize = imageN1S2F1R1(111:1426,111:1426); 
    %imageN1S2F1R1Resize = imresize(imageN1S2F1R1Resize,0.5835);
    imageN1S2F1R1Resize = imageN1S2F1R1;
    
    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageN1S2F1R1Resize(:);      
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B7/N1S2F1R1_',num2str(j),'_2.tiff'))
    clear sX M Y

    % B8
    for k = 1:16
        imageN1S2F2R1 = rectsurr2(imageOrig, nS2, wv, cz, 19/20);
        %imageN1S2F2R1Resize = imageN1S2F2R1(111:1426,111:1426); 
        %imageN1S2F2R1Resize = imresize(imageN1S2F2R1Resize,0.5835);
        imageN1S2F2R1Resize = imageN1S2F2R1;

        %Adjust amplitudes so histogram of degraded iamge matches natural
        sX=imageN1S2F2R1Resize(:);       
        M(:,1)=sX; M(:,2)=1:N^2;
        M=sortrows(M,1);
        M(:,1)=sortrows(X);
        M=sortrows(M,2);
        Y=reshape(M(:,1),N,N);   
        Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
        imwrite(im2uint8(Y),strcat('stimuli_fMRI/B8/N1S2F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        clear sX M Y
    end

    % ----------------

    % All noise blocks:
    % imageNoiseAllButS12 = rectsurr2(imageOrig, nNoise, wv, cz, 19.6/20);  %it is mixing ALL scales
    imageNoiseAllButS12 = elipsurr2(imageOrig, nNoise, wv, cz, rads);
    
    %Adjust amplitude so histogram of degraded image matches natural
    X_notResized=imageOrig(:);           
    sX=imageNoiseAllButS12(:);      
    M(:,1)=sX; M(:,2)=1:origImageDim(1)*origImageDim(2);
    M=sortrows(M,1);
    M(:,1)=sortrows(X_notResized);
    M=sortrows(M,2);
    Y=reshape(M(:,1),origImageDim(1),origImageDim(2));   
      %  Y=Y.*template;
      %  Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/imageNoiseAllButS12_',num2str(j),'_Father.tiff'))
    clear sX M Y

    imageNoise = rectsurr2(imageNoiseAllButS12, nS12, wv, cz, 19/20);
    %imageNoise = elipsurr2(imageNoiseAllButS12, nS12, wv, cz, rads);
    %Adjust amplitude so histogram of degraded image matches natural
    sX=imageNoise(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:origImageDim(1)*origImageDim(2);
    M=sortrows(M,1);
    M(:,1)=sortrows(X_notResized);
    M=sortrows(M,2);
    Y=reshape(M(:,1),origImageDim(1),origImageDim(2));   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B12/imageNoise_',num2str(j),'_Father.tiff'))
    clear sX M Y

    %B4 and B5
    for k = 1:16
        imageN2S1F2R1_Child = rectsurr2(imageNoise, nS1, wv, cz, 19/20);
        %imageN2S1F2R1_Child = elipsurr2(imageNoise, nS1, wv, cz, rads);
        %imageN2S1F2R1_ChildResize = imageN2S1F2R1_Child(111:1426,111:1426); %This will be region to crop to...
        %imageN2S1F2R1_ChildResize = imresize(imageN2S1F2R1_ChildResize,0.5835);
        imageN2S1F2R1_ChildResize = imageN2S1F2R1_Child;

        %Adjust amplitudes so histogram of degraded iamge matches natural
        sX=imageN2S1F2R1_ChildResize(:);       %wavelet shuffled image
        M(:,1)=sX; M(:,2)=1:N^2;
        M=sortrows(M,1);
        M(:,1)=sortrows(X);
        M=sortrows(M,2);
        Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
        Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
        if k == 1 || k == 2
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B4/N2S1F1R1_',num2str(j),'_',num2str(k),'.tiff'))
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B5/N2S1F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        else
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B5/N2S1F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        end
        clear sX M Y
    end

    % B6
    imageN3S1F1R1_Father = rectsurr2(imageNoiseAllButS12, nS2, wv, cz, 19/20);
    %imageN3S1F1R1_Father = elipsurr2(imageNoiseAllButS12, nS2, wv, cz, rads);
    %Adjust amplitude so histogram of degraded image matches natural
    sX=imageN3S1F1R1_Father(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:origImageDim(1)*origImageDim(2);
    M=sortrows(M,1);
    M(:,1)=sortrows(X_notResized);
    M=sortrows(M,2);
    Y=reshape(M(:,1),origImageDim(1),origImageDim(2));   %surrogate image with amplitude spectra of natural one
                Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B6/N3S1F1R1_',num2str(j),'_Father.tiff'))
    clear sX M Y
    
    %imageN3S1F1R1_FatherResize = imageN3S1F1R1_Father(111:1426,111:1426); 
    %imageN3S1F1R1_FatherResize = imresize(imageN3S1F1R1_FatherResize,0.5835);
    imageN3S1F1R1_FatherResize = imageN3S1F1R1_Father;

    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageN3S1F1R1_FatherResize(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
                Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B6/N3S1F1R1_',num2str(j),'_1.tiff'))
    clear sX M Y

    imageN3S1F1R1_Child = rectsurr2(imageN3S1F1R1_Father, nS1, wv, cz, 19/20);
    %imageN3S1F1R1_Child = elipsurr2(imageN3S1F1R1_Father, nS1, wv, cz, rads);
    %imageN3S1F1R1_ChildResize = imageN3S1F1R1_Child(111:1426,111:1426); 
    %imageN3S1F1R1_ChildResize = imresize(imageN3S1F1R1_ChildResize,0.5835);
    imageN3S1F1R1_ChildResize = imageN3S1F1R1_Child

    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageN3S1F1R1_ChildResize(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B6/N3S1F1R1_',num2str(j),'_2.tiff'))
    clear sX M Y
    
    
    % B9 and B10 
    for k = 1:16
        imageN2S2F2R1_Child = rectsurr2(imageNoise, nS2, wv, cz, 19/20);
        %imageN2S2F2R1_Child = elipsurr2(imageNoise, nS2, wv, cz, rads);
        %imageN2S2F2R1_ChildResize = imageN2S2F2R1_Child(111:1426,111:1426); 
        %imageN2S2F2R1_ChildResize = imresize(imageN2S2F2R1_ChildResize,0.5835);
        imageN2S2F2R1_ChildResize = imageN2S2F2R1_Child;

        %Adjust amplitudes so histogram of degraded iamge matches natural
        sX=imageN2S2F2R1_ChildResize(:);       %wavelet shuffled image
        M(:,1)=sX; M(:,2)=1:N^2;
        M=sortrows(M,1);
        M(:,1)=sortrows(X);
        M=sortrows(M,2);
        Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
 %                       Y=Y.*template;
  %      Y=Y+mean(mean(Y)).*~template;
        if k == 1 || k == 2
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B9/N2S2F1R1_',num2str(j),'_',num2str(k),'.tiff'))
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B10/N2S2F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        else
            imwrite(im2uint8(Y),strcat('stimuli_fMRI/B10/N2S2F2R1_',num2str(j),'_',num2str(k),'.tiff'))
        end
        clear sX M Y
    end

    % B11 
    imageN3S2F1R1_Father = rectsurr2(imageNoiseAllButS12, nS1, wv, cz, 19/20);
    %imageN3S2F1R1_Father = elipsurr2(imageNoiseAllButS12, nS1, wv, cz, rads);
    %Adjust amplitude so histogram of degraded image matches natural
    sX=imageN3S2F1R1_Father(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:origImageDim(1)*origImageDim(2);
    M=sortrows(M,1);
    M(:,1)=sortrows(X_notResized);
    M=sortrows(M,2);
    Y=reshape(M(:,1),origImageDim(1),origImageDim(2));   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B11/N3S2F1R1_',num2str(j),'_Father.tiff'))
    clear sX M Y
    
    %imageN3S2F1R1_FatherResize = imageN3S2F1R1_Father(111:1426,111:1426); 
    %imageN3S2F1R1_FatherResize = imresize(imageN3S2F1R1_FatherResize,0.5835);
    imageN3S2F1R1_FatherResize = imageN3S2F1R1_Father;

    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageN3S2F1R1_FatherResize(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B11/N3S2F1R1_',num2str(j),'_1.tiff'))
    clear sX M Y
    
    imageN3S2F1R1_Child = rectsurr2(imageN3S2F1R1_Father, nS2, wv, cz, 19/20);
    %imageN3S2F1R1_Child = elipsurr2(imageN3S2F1R1_Father, nS2, wv, cz, rads);
    %imageN3S2F1R1_ChildResize = imageN3S2F1R1_Child(111:1426,111:1426); 
    %imageN3S2F1R1_ChildResize = imresize(imageN3S2F1R1_ChildResize,0.5835);
    imageN3S2F1R1_ChildResize = imageN3S2F1R1_Child;
    
    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageN3S2F1R1_ChildResize(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B11/N3S2F1R1_',num2str(j),'_2.tiff'))
    clear sX M Y
    
    % B12
    %imageNoiseResize = imageNoise(111:1426,111:1426); 
    %imageNoiseResize = imresize(imageNoiseResize,0.5835);
    imageNoiseResize = imageNoise;
    
    %Adjust amplitudes so histogram of degraded iamge matches natural
    sX=imageNoiseResize(:);       %wavelet shuffled image
    M(:,1)=sX; M(:,2)=1:N^2;
    M=sortrows(M,1);
    M(:,1)=sortrows(X);
    M=sortrows(M,2);
    Y=reshape(M(:,1),N,N);   %surrogate image with amplitude spectra of natural one
            Y=Y.*template;
        Y=Y+mean(mean(Y)).*~template;
    imwrite(im2uint8(Y),strcat('stimuli_fMRI/B12/N2S0F0R0_',num2str(j),'_1.tiff'))

    clear X sX M Y X_notResized
end