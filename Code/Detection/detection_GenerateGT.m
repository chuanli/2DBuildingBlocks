%% A script for convert GT from txt to mat
close all; clear all; clc; cwd = pwd; addpath(genpath(cwd));

% Set default parameters
Script_COOC_DefaultParams;

P.name_path = [cwd(1, 1:3) 'Chuan\TOG\Data\'];
P.name_dataset = 'Facade';
P.name_data_input = 'Ori';
P.name_gt_input = 'Ori_GT';
P.name_data_output = 'Resized';
P.name_gt_output = 'Resized_GT';

P.name_format = '.jpg';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir([P.name_path P.name_dataset '\' P.name_data_output]);
mkdir([P.name_path P.name_dataset '\' P.name_gt_output]);
name_path_img = [P.name_path P.name_dataset '\' P.name_data_input ];
name_path_gt = [P.name_path P.name_dataset '\' P.name_gt_input ];

Files = dir([name_path_img '\*' P.name_format]);
num_img = size(Files, 1);

for i_img = 1:num_img
    name = Files(i_img).name;
    format = name(1, end - 3:end);
    name = name(1, 1:end - 4);
    im = double(imread([name_path_img '\' name format]))/255;    
    
    name_box_pattern = [name_path_gt '\' name format '.txt'];
    string = textread(name_box_pattern, '%s', 1, 'headerlines', 1);
    num_boxes = str2num(string{1, 1});
    data_boxes = zeros(5, num_boxes);
    for i_box = 1:num_boxes
        string = textread(name_box_pattern, '%s', 5, 'headerlines', 1 + i_box);
        for i = 1:size(string, 1)
            data_boxes(i, i_box) = str2num(string{i, 1});
        end
    end
    
    label_rep = unique(data_boxes(end, :));
    GT.rep = cell(1, size(label_rep, 2));
    GT.rep_size = zeros(1, size(label_rep, 2));
    for i_rep = 1:size(label_rep, 2)
        mask = data_boxes(end, :) == label_rep(1, i_rep);
        GT.rep{1, i_rep} = data_boxes(1:4, mask);
        GT.rep_size(1, i_rep) = sum(mask);
    end
    mask = GT.rep_size > 1;
    GT.rep = GT.rep(1, mask);
    GT.rep_size = GT.rep_size(1, mask);
    
    % need to scale the locations according to img_size_standard
    num_pixel_input = size(im, 1) * size(im, 2);
    num_pixel_standard = P.pre_img_size_standard(1) * P.pre_img_size_standard(2);
    scaler_img = sqrt(num_pixel_standard/num_pixel_input);
    im2 = imresize(im, scaler_img);
    for i_rep = 1:size(GT.rep, 2)
        GT.rep{1, i_rep}([1, 3], :) = ceil(GT.rep{1, i_rep}([1, 3], :) * size(im2, 2)/size(im, 2));
        GT.rep{1, i_rep}([2, 4], :) = ceil(GT.rep{1, i_rep}([2, 4], :) * size(im2, 1)/size(im, 1));
    end

%     h = figure;
%     imshow(im2);
%     hold on;
%     for i_rep = 1:size(GT.rep, 2)
%         for i = 1:size(GT.rep{1, i_rep}, 2)
%             box = repmat(GT.rep{1, i_rep}(1:2, i), 1, 4) + [0, GT.rep{1, i_rep}(3, i), GT.rep{1, i_rep}(3, i), 0; 0, 0, GT.rep{1, i_rep}(4, i), GT.rep{1, i_rep}(4, i)];
%             plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', P.label_list(i_rep, :), 'LineWidth', 2);
%         end
%     end
%     F = im2frame(zbuffer_cdata(h));
%     f_size = size(F.cdata(1:end - 1,1:end - 1,:));
%     imwrite(F.cdata(1:f_size(1),1:f_size(2),:), [name_path_gt  '\' name '_boxes.png']);    
    
     save([P.name_path P.name_dataset '\' P.name_gt_output '\' name '_GT.mat'], 'GT');
end



return;

