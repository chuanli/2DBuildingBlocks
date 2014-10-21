%% A script for rename files
% the current script is to remove the empty space in symbr dataset.
% Otherwise it will cause problem in calling command window programs

warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'Facade';
P.name_data_input = 'Ori_GT';
P.name_data_output = 'Ori_GT';
P.name_prefix = 'Facade';
P.name_format = '.jpg';

Files = dir([P.name_path  P.name_dataset '\' P.name_data_input '\*' 'txt']);
mkdir([P.name_path  P.name_dataset '\' P.name_data_output]);

% Loop through each
for i_img = 1:length(Files)
   % name = Files(i_img, 1).name;
   % name = name(1, 1:end - 4);
    % Get the file name (minus the extension)
%     [~, f] = fileparts(Files(i_img).name);
%     f = [f(1:3) f(5:end)];
   name = 'fac';
   name_Out = 'Facade';
    movefile([P.name_path  P.name_dataset '\' P.name_data_input '\' [name '(' num2str(i_img - 1) ')' P.name_format '.txt']], [P.name_path  P.name_dataset '\' P.name_data_input '\' [name_Out '(' num2str(i_img - 1) ')' P.name_format '.txt']]);
end