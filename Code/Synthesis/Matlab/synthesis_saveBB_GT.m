%% A script to save GT result in a text file
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'Facade';
P.name_data = 'Resized';
P.name_prefix = 'Facade';
P.name_format = '.jpg';
P.name_syn = 'Syn';
P.name_syn_input = 'Input';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir([P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input ]);

for i_img = 0:599
    nameGT = [P.name_path  P.name_dataset  '\' P.name_data '_GT\' P.name_prefix  '(' num2str(i_img) ')_GT.mat'];
    nameGTOutput = [P.name_path  P.name_dataset  '\' P.name_syn '\' P.name_syn_input '\' P.name_prefix  '(' num2str(i_img) ')GT.txt'];
    Detection = [];
    
    if exist(nameGT, 'file')
        load(nameGT);
        Detection = GT;
    else
        Detection.rep = [];
    end    
    
    fileID = fopen(nameGTOutput,'w');
        
    num_bb_type = min(5, size(Detection.rep, 2));
    fprintf(fileID, '%d \n',round(num_bb_type));
    num_bb = zeros(1, num_bb_type);
    for i = 1:num_bb_type
        num_bb(1, i) = size(Detection.rep{1, i}, 2);
        fprintf(fileID, '%d \n',round(num_bb(1, i)));
    end
    for i = 1:num_bb_type
        for j = 1:size(Detection.rep{1, i}, 2)
            fprintf(fileID, '%d %d %d %d \n', round(Detection.rep{1, i}(1, j)), round(Detection.rep{1, i}(2, j)), round(Detection.rep{1, i}(3, j)), round(Detection.rep{1, i}(4, j)));
        end
    end
    fclose(fileID);
    
end
