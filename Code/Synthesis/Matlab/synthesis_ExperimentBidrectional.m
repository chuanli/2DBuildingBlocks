%% A script for Synthesis experiments
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.matlabpool_flag = 1;
P.num_Cores = 4;
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end

if 1 % shiftmap 
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 1; % argv[4]
        mode_sampling = 1; % argv[5]
        name_detection = ['Detection']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1;
        scalerRes = 0.5;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end

if 1 % offset pixel
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 2; % argv[4]
        mode_sampling = 3; % argv[5]
        name_detection = ['Detection']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1;
        scalerRes = 0.5;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end


if 0 % shiftmap + BB
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 3; % argv[4]
        mode_sampling = 1; % argv[5]
        name_detection = ['Detection']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1;
        scalerRes = 0.5;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end

if 0 % pixel offset + BB
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 3; % argv[4]
        mode_sampling = 3; % argv[5]
        name_detection = ['Detection']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1;
        scalerRes = 0.5;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end

if 1 % bb statistics + BB
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 3; % argv[4]
        mode_sampling = 5; % argv[5]
        name_detection = ['Detection']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1;
        scalerRes = 0.5;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end

if 0 % gt
    parfor i_img = 0:4
        name_cmd = [cwd(1, 1:3) '\Chuan\git\2DBuildingBlocks\Code\Synthesis\SynthesisCMD\Release\SynthesisCMD.exe'];
        name_inputpath =  [cwd(1, 1:3) '\Chuan\data\2DBuildingBlocks\Bidrectional\Syn\Input\'];  % argv[1]
        name_imgInputformat = ['.jpg']; % argv[3]
        mode_method = 3; % argv[4]
        mode_sampling = 5; % argv[5]
        name_detection = ['GT']; % argv[6]
        totalGeneratorX_scaled = 1.5;
        totalGeneratorY_scaled = 1.;
        scalerRes = 0.25;
        try
            name_imgInput = [ 'Bidrectional' '(' num2str(i_img) ')']; % argv[2]
            CommandStr = [name_cmd ' ' name_inputpath ' ' name_imgInput ' ' name_imgInputformat ' ' num2str(mode_method) ' ' num2str(mode_sampling) ' ' name_detection ' ' num2str(totalGeneratorX_scaled) ' ' num2str(totalGeneratorY_scaled) ' ' num2str(scalerRes )];
            system(CommandStr);
        catch
        end
    end
end

if matlabpool('size') > 0
    matlabpool close;
end


