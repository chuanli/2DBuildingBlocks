%% A script to compute offset statistics for detection
% output generators

warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'OffsetStatistics';
P.name_data = 'Resized';
P.name_prefix = 'OffsetStatistics';
P.name_format = '.jpg';
P.name_syn = 'Syn';
P.name_syn_input = 'Input';

max_num_bb_type = 3;

P.matlabpool_flag = 0;
P.num_Cores = 4;
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end

% parameters for statistics analysis
para.res_scale = 0.25;  % this is for effeciency reason
para.w = para.res_scale * 32; % this is incharge of different things w.r.t thresh_nn
para.h = para.res_scale * 32;
para.gs_sigma = sqrt(3) * (para.res_scale/0.25);
para.gs_w = round(para.gs_sigma * 3) * 2 + 1;
para.thresh_nn = para.res_scale * 32; % preclude pairs that are too close, at the low resolution
para.thresh_nn_far = 3 * para.res_scale * 32; % preclude pairs that are too far , at the low resolution
para.thresh_peak_pro = 0.5; % minimum probability for a positive peak
para.thresh_peak_max_num = 10;
para.thresh_correlation = 0.5;
para.defalt_mag = 0; % a default magnitude for assistant generators

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir([P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input ]);

for i_img = 0:20
    nameImg = [P.name_path  P.name_dataset  '\' P.name_data '\' P.name_prefix '(' num2str(i_img) ')' P.name_format];
    nameRep = [P.name_path  P.name_dataset  '\' P.name_data '\resultAIO\rob\' P.name_prefix  '(' num2str(i_img) ')_afmg.mat'];
    nameOffsetStatisticsDetectionOutput = [P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input '\' P.name_prefix  '(' num2str(i_img) ')OffsetStatisticsDetectionMW.txt'];
    
    % input image & repitition
    im = imread(nameImg);
    im_ori = im;
    
    Rep = [];
    if exist(nameRep, 'file')
        load(nameRep);
        Rep = Merge;
    else
        Rep.rep = [];
    end

    num_bb_type = min(max_num_bb_type, size(Rep.rep, 2));
    
    % scale image and detection
    im = imresize(im, para.res_scale);
    for i_rep = 1:num_bb_type
        Rep.rep{1, i_rep} = round(Rep.rep{1, i_rep} * para.res_scale);
    end
    
%     func_generatorFromGT;
    generators = func_generatorFromBB(im, Rep, para);
    generators = round(generators/ para.res_scale);
    generators(2, 1) = 0;
    generators(1, 2) = 0;
    
    % write generators into txt file
    fileID = fopen(nameOffsetStatisticsDetectionOutput,'w');
    fprintf(fileID, '%d \n', size(generators, 2));
    for i = 1:size(generators, 2)
        fprintf(fileID, '%d %d \n', generators(1, i), generators(2, i));
    end
    fclose(fileID);
    
%     figure;
%     imshow(im_ori);
%     hold on;
%     p_cen = round([size(im_ori, 2)/2, size(im_ori, 1)/2]);     
%     plot([p_cen(1) p_cen(1) + generators(1, 1)], [p_cen(2) p_cen(2) + generators(2, 1)], 'r', 'LineWidth', 3);
%     plot([p_cen(1) p_cen(1) + generators(1, 2)], [p_cen(2) p_cen(2) + generators(2, 2)], 'b', 'LineWidth', 3);
end
