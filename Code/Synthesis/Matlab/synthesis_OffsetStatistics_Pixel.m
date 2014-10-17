%% A script to compute offset statistics for pixels
% output two lists of step for shifting, in x and y direction respectively

warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'NonFacade';
P.name_data = 'Resized';
P.name_prefix = 'NonFacade';
P.name_format = '.jpg';
P.name_syn = 'Syn';
P.name_syn_input = 'Input';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir([P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input ]);

for i_img = 0:0
    nameImg = [P.name_path  P.name_dataset  '\' P.name_data '\' P.name_prefix '(' num2str(i_img) ')' P.name_format];
    nameOffsetStatisticsPixelOutput = [P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input '\' P.name_prefix  '(' num2str(i_img) ')OffsetStatisticsPixel.txt'];
    
    para.res_scale = 0.25;  % this is for effeciency reason
    para.w = 4; 
    para.h = 4;
    para.gs_sigma = sqrt(1);
    para.gs_w = round(para.gs_sigma * 3) * 2 + 1;
    para.thresh_nn = 4; % preclude pairs that are too close 
    para.thresh_peak_pro = 0.1; % minimum probability for a positive peak
    para.thresh_peak_max_num = 60;
    para.thresh_correlation = 0.5;
    para.defalt_mag = 6; % a default magnitude for assistant generators 
    % input image
    im = imread(nameImg);
   
    % scale image 
    im = imresize(im, para.res_scale);
    im_gray = rgb2gray(im);   
    generators = func_generatorFromOffsetStatistics(im_gray, para);
    generators = round(generators/ para.res_scale);
    
    % write generators into txt file
    fileID = fopen(nameOffsetStatisticsPixelOutput,'w');
    fprintf(fileID, '%d \n', size(generators, 2));
    for i = 1:size(generators, 2)
        fprintf(fileID, '%d %d \n', generators(1, i), generators(2, i));
    end
    fclose(fileID);
    
end
