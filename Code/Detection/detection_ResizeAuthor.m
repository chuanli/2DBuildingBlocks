%% A script for detection experiments
%% change paths according to your data storage 
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

% Set default parameters
define_COOC_DefaultParams;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'TextureOptimization';
P.name_data_input = 'Ori';
P.name_data_output = 'Resized';
P.name_format = 'bmp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Files = dir([P.name_path  [P.name_dataset '\' P.name_data_input '\*' P.name_format]]);
mkdir([P.name_path  P.name_dataset '\' P.name_data_output]);

for i_img = 1:size(Files, 1)
      name = Files(i_img, 1).name;  
      format = name(1, end - 3:end);
      name = name(1, 1:end - 4);
      im_original = double(imread([P.name_path P.name_dataset '\' P.name_data_input '\' name format]))/255;
      im_author = double(imread(['C:\Chuan\data\2DBuildingBlocks\TextureOptimization\Authors' '\' name '.bmp']))/255;
%       resize it to multiplicate of P.pre_hog_cell_size
      scaler = sqrt(P.pre_img_size_standard(1) * P.pre_img_size_standard(2)/(size(im_original, 1) * size(im_original, 2)));
      new_w = round(size(im_author, 2) * scaler/P.pre_hog_cell_size) * P.pre_hog_cell_size;
      new_h = round(size(im_author, 1) * scaler/P.pre_hog_cell_size) * P.pre_hog_cell_size;
      im_resize = imresize(im_author, [new_h, new_w]);
      imwrite(im_resize, ['C:\Chuan\data\2DBuildingBlocks\TextureOptimization\Authors' '\' name '_TO.bmp']);
      
end