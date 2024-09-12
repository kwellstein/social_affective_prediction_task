clc;
clear all;

thisroot = pwd;
images_folder = [pwd,'/SHINE_toolbox/SHINE_OUTPUT/'];
templates_folder = [pwd,'/SHINE_toolbox/SHINE_TEMPLATE/'];
save_folder = [pwd,'/final_stimuli/'];
imgs = dir([images_folder '*.png']);

mask = imread([templates_folder,'template.png']);
mask = mask(:,:,1)>0;

for ii=1:length(imgs)
    img = imread([images_folder imgs(ii).name]);
    img(~mask) = img(1,1);   %the first corner pixel value is written allover the 
                             %background because the background was uniform
                             %anyways. We just overwrote all imperfections
                             %with that pixel value.
    imwrite(img,[save_folder,'/', imgs(ii).name]);
end

