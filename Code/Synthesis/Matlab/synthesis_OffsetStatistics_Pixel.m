%% A script to compute offset statistics for pixels
% output two nonMW generators

warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'ShiftMap';
P.name_data = 'Resized';
P.name_prefix = 'ShiftMap';
P.name_format = '.jpg';
P.name_syn = 'Syn';
P.name_syn_input = 'Input';

P.matlabpool_flag = 0;
P.num_Cores = 4;
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end

para.res_scale = 0.25;  % this is for effeciency reason
para.w = para.res_scale * 32; % this is incharge of different things w.r.t thresh_nn
para.h = para.res_scale * 32;
para.gs_sigma = sqrt(3) * (para.res_scale/0.25);
para.gs_w = round(para.gs_sigma * 3) * 2 + 1;
para.thresh_nn = para.res_scale * 32; % preclude pairs that are too close, at the low resolution
para.thresh_nn_far = 3 * para.res_scale * 32; % preclude pairs that are too far , at the low resolution
para.thresh_peak_pro = 0.5; % minimum probability for a positive peak
para.thresh_peak_max_num = 60;
para.thresh_correlation = 0.5;
para.defalt_mag = 0; % a default magnitude for assistant generators
para.min_divergence_cos = 0.95;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir([P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input ]);

for i_img = 0:25
    nameImg = [P.name_path  P.name_dataset  '\' P.name_data '\' P.name_prefix '(' num2str(i_img) ')' P.name_format];
    nameOffsetStatisticsPixelOutput = [P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input '\' P.name_prefix  '(' num2str(i_img) ')OffsetStatisticsPixel.txt'];
   
    % input image
    im = imread(nameImg);

    im_ori = im;
    % scale image 
    im = imresize(im, para.res_scale);
    im_gray = rgb2gray(im);   

    generators = func_generatorFromOffsetStatistics(im_gray, para);
    generators = round(generators/ para.res_scale);
      
    % switch to MW if the generator diverse too much from the principle
    % directions (otherwise incapable of horizontal/vertical retargeting)
    if abs(dot(generators(:, 1), [1, 0])/(norm(generators(:, 1)) * norm([1, 0]))) < para.min_divergence_cos
        generators(:, 1) = [0; 0];
    end
    if abs(dot(generators(:, 2), [0, 1])/(norm(generators(:, 2)) * norm([0, 1]))) < para.min_divergence_cos
        generators(:, 2) = [0; 0];
    end  

    % write generators into txt file
    fileID = fopen(nameOffsetStatisticsPixelOutput,'w');
    fprintf(fileID, '%d \n', size(generators, 2));
    for i = 1:size(generators, 2)
        fprintf(fileID, '%d %d \n', generators(1, i), generators(2, i));
    end
    fclose(fileID);
    
    figure;
    imshow(im_ori);
    hold on;
    p_cen = round([size(im_ori, 2)/2, size(im_ori, 1)/2]);     
    plot([p_cen(1) p_cen(1) + generators(1, 1)], [p_cen(2) p_cen(2) + generators(2, 1)], 'r', 'LineWidth', 3);
    plot([p_cen(1) p_cen(1) + generators(1, 2)], [p_cen(2) p_cen(2) + generators(2, 2)], 'b', 'LineWidth', 3);
end
