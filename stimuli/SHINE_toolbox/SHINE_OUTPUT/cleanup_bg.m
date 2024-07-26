clc;
clear all;

path = 'C:\Users\ripho\social_affective_prediction_task\stimuli\SHINE_toolbox\SHINE_OUTPUT\test_26-Jul-2024';
imgs = dir([path '*.png']);

mask = imread('template.png');
mask = mask(:,:,1)>0;

for ii=1:length(imgs)
    img = imread([path imgs(ii).name]);
    img(~mask) = img(1,1);     %the first corner pixel value is written allover the 
                             %background because the background was uniform
                             %anyways. We just overwrote all imperfections
                             %with that pixel value.
    imwrite(img,['cleaned' imgs(ii).name]);
end

