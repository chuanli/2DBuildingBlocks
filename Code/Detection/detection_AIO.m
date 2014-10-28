%% A script for AIO detection 
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

% Set default parameters
define_COOC_DefaultParams;

% Set experiment parameters
P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'Facade';
P.name_data = 'Resized';
P.name_prefix = 'Facade';
P.name_format = '.jpg';
P.output_path = [P.name_path P.name_dataset '\' P.name_data '\resultAIO\']; mkdir(P.output_path);
P.eva_num_img = 4;
P.robustness_num_iter = 20;

% parallel
P.matlabpool_flag = 1;
P.num_Cores = 4;
% start parallel
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end

P.method = 'pre';
flag_done = func_detection(P);

P.method = 'dl';
flag_done = func_detection(P);

P.method = 'bb';
flag_done = func_detection(P);

P.method = 'rob';
flag_done = func_detection(P);

if matlabpool('size') > 0
    matlabpool close;
end