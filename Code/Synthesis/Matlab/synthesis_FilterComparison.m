%% A script for discarding results that are too similar
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;
list_numdiff = zeros(1, 21);
for i_img = 0:599
        name_outpath =  ['C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Results\Fig\Facade\'];  % argv[1]
        name_outputformat = ['.jpg']; % argv[3]

        mode1_method = 2; % argv[4]
        mode1_sampling = 3; % argv[5]
        name1_detection = ['Detection']; % argv[6]                
        mode2_method = 3; % argv[4]
        mode2_sampling = 5; % argv[5]
        name2_detection = ['Detection']; % argv[6]
       
        name1_imgOutput = [ name_outpath 'Facade' '(' num2str(i_img) ')_syn_' num2str(mode1_method) '_' num2str(mode1_sampling) '_' name1_detection name_outputformat]; % argv[2]
        name2_imgOutput = [ name_outpath 'Facade' '(' num2str(i_img) ')_syn_' num2str(mode2_method) '_' num2str(mode2_sampling) '_' name1_detection name_outputformat]; % argv[2]
        
        im1 = double(imread(name1_imgOutput))/255;
        im2 = double(imread(name2_imgOutput))/255;
        imdiff = sum(abs(im1 - im2), 3);
        mask = imdiff > 0.1;
        list_numdiff(1, i_img + 1) = sum(sum(mask));
end
    
sum(list_numdiff >= 10000)
list_id = [0:599; list_numdiff];
list_id = list_id(:, list_numdiff >= 10000)


% list_picked = [5, 10, 22, 31, 32, 35, 37, 40, 43, 44, 46, 47, 48, 52, 55, 59, 68, 70, 71, 81, 82, 89, 101, 109, 119, 126, 134, 140, 147, 154, 161, 163, 166, 173, 178, 181, 183, 185, 193, 205, 206, 207, 212, 213, 214, 219, 228, 229, 230, 231, 232, 234];