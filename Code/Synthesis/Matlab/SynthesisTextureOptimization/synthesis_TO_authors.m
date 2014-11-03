%% A script for texture optimization
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

path_3_4 = 'C:\Chuan\data\2DBuildingBlocks\TextureOptimization\Syn\output\';
path_TO = 'C:\Chuan\data\2DBuildingBlocks\TextureOptimization\Authors\';
name = 'TextureOptimization';
path_output = 'C:\Chuan\data\2DBuildingBlocks\TextureOptimization\Syn\comparison\';
for i_img = 0:37
    im_3_4 = imread([path_3_4 name '(' num2str(i_img) ')_syn_1.5_1_3_4_Detection' '.jpg' ]);
    im_TO = imread([path_TO name '(' num2str(i_img) ')' '_TO.bmp' ]);
    cut_size = [min(size(im_3_4, 1), size(im_TO, 1)), min(size(im_3_4, 2), size(im_TO, 2))];
    im_3_4 = im_3_4(1:cut_size(1), 1:cut_size(2), :);
    im_TO = im_TO(1:cut_size(1), 1:cut_size(2), :);
    imwrite(im_3_4, [path_output name '(' num2str(i_img) ')_syn_1.5_1_3_4_Detection' '.png']);
    imwrite(im_TO, [path_output name '(' num2str(i_img) ')_syn_TO' '.png']);
end

