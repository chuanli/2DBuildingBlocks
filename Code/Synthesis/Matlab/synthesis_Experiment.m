%% A script for Synthesis experiments
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_cmd = 'C:\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe';
P.name_inputpath = ['C:\Chuan\data\2DBuildingBlocks\Facade\Syn\Input\'];  % argv[1]
P.name_imgInputformat = ['.jpg']; % argv[3]
P.mode_method = 3; % argv[4]
P.mode_sampling = 3; % argv[5]
P.name_detection = ['GT']; % argv[6]
P.totalGeneratorX_scaled = 1.0;
P.totalGeneratorY_scaled = 1.25;
P.scalerRes = 0.25;

for i_img = 0:23
    P.name_imgInput = [ 'Facade' '(' num2str(i_img) ')']; % argv[2]
    CommandStr = [P.name_cmd ' ' P.name_inputpath ' ' P.name_imgInput ' ' P.name_imgInputformat ' ' num2str(P.mode_method) ' ' num2str(P.mode_sampling) ' ' P.name_detection ' ' num2str(P.totalGeneratorX_scaled) ' ' num2str(P.totalGeneratorY_scaled) ' ' num2str(P.scalerRes )];
    system(CommandStr);
end


