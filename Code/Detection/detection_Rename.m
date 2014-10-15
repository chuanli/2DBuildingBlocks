%% A script for rename files
% the current script is to remove the empty space in symbr dataset.
% Otherwise it will cause problem in calling command window programs

warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

% Set default parameters
Script_COOC_DefaultParams;

P.name_path = [cwd(1, 1:3) 'Chuan\TOG\Data\'];
P.name_dataset = 'TextureOptimization';
P.name_data_input = 'Ori';
P.name_data_output = 'Ori';
P.name_prefix = 'TextureOptimization';
P.name_format = '.jpg';

Files = dir([P.name_path  P.name_dataset '\' P.name_data_input '\*' P.name_format]);
mkdir([P.name_path  P.name_dataset '\' P.name_data_output]);

% Loop through each
for i_img = 1:length(Files)
    name = Files(i_img, 1).name;
    name = name(1, 1:end - 4);
    
    % Get the file name (minus the extension)
    [~, f] = fileparts(Files(i_img).name);
    f = [f(1:3) f(5:end)];
    movefile([P.name_path  P.name_dataset '\' P.name_data_input '\' Files(i_img).name], [P.name_path  P.name_dataset '\' P.name_data_output '\' P.name_prefix '(' num2str(i_img - 1) ')' P.name_format]);
end