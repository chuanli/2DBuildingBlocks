%% A script for detection experiments -- BDS + Exaustive search
warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

%% set up input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_iter = 5; % number of interation in Patch Match
cores = 1;    % Use more cores for more speed
w_A2B = 1;
w_B2A = 1;

if cores==1
    algo = 'cpu';
else
    algo = 'cputiled';
end

% parallel
P.matlabpool_flag = 0;
P.num_Cores = 4;
% start parallel
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end


% global_scaler = [1.5, 1]; % fac(570)
% list = [570];


% global_scaler = [1.35, 1.35]; % Chuan(8)
% list = [8];

global_scaler = [1.5, 1]; % Chuan(17)
list = [17];

% parfor i_img = 0:99
for ii_img = 1:size(list, 2)
    i_img = list(ii_img);
    % parfor i_img = 502:502
    % parfor i_img = 0:7
    %     try
    warning('off','all');
    img_name = ['Chuan(' num2str(i_img) ')'];
    img_format = '.jpg';
    filename = [img_name img_format];
    P_BDS = [];
    P_BDS.name_path = [cwd(1, 1:2) '\Chuan\local\Data\'];
    P_BDS.name_dataset = 'Chuan';
    P_BDS.name_data = 'ALL_Resize';
    P_BDS.name_format = '.jpg';
    P_BDS.output_path = [P_BDS.name_path P_BDS.name_dataset '\' P_BDS.name_data '\resultCOOC\']; mkdir(P_BDS.output_path);
    P_BDS.im_input_fullres = double(imread([P_BDS.name_path '\' P_BDS.name_dataset '\' P_BDS.name_data '\' filename]))/255;
    
    row = floor(size(P_BDS.im_input_fullres, 1)/8);
    col = floor(size(P_BDS.im_input_fullres, 2)/8);
    im = imresize(P_BDS.im_input_fullres, [row * 8, col*8]);
    
    A = im;
    B = im;
    scaler = [0.125, 0.25, 0.5, 1];
    bd = 6;
    
    for scale_level = 2:2
        patch_w = 0;
        ann = [];
        A_rec_color = imresize(A, scaler(1));
        
        w = min([32/(2^(scale_level - 1)), round(size(A_rec_color, 2)/(2^(scale_level - 1)))]);
        h = min(32/(2^(scale_level - 1)), round(size(A_rec_color, 1)/(2^(scale_level - 1))));
        
        for i_res = 1:1
            % get the correct resolution for A and B
            A_rec_color = imresize(A, scaler(i_res));
            B_cur_color = imresize(B, scaler(i_res));
            A_rec_gray = rgb2gray(A_rec_color);
            B_cur_gray = rgb2gray(B_cur_color);
            
            % i need to find all patches in B
            B_num_rows = size(B_cur_color, 1) - h + 1;
            B_num_cols = size(B_cur_color, 2) - w + 1;
            B_num_patches = B_num_rows * B_num_cols;
            B_patches = zeros(B_num_patches, h * w);
            
            for i = 1:B_num_cols
                for j = 1:B_num_rows
                    idx = (i - 1) * B_num_rows + j;
                    B_patches(idx, :) = reshape(B_cur_gray(j:j + h -1, i:i + w - 1), 1, []);
                end
            end
            
            %             num_round = max(round(size(A_rec_gray, 2)/2), round(size(A_rec_gray, 1)/2));
            %         num_round = 10;
            new_size = [round(global_scaler(2) * size(A_rec_gray, 1)), round(global_scaler(1) * size(A_rec_gray, 2))];
            num_round = max(new_size);
%             num_round = round(size(A_rec_gray, 2)/2);
            
            for i_round = 1:num_round
                
                if size(A_rec_gray, 1) + 1 > new_size(1)
                    new_h = new_size(1);
                else
                    new_h = size(A_rec_gray, 1) + 1;
                end
                if size(A_rec_gray, 2) + 1 > new_size(2)
                    new_w = new_size(2);
                else
                    new_w = size(A_rec_gray, 2) + 1;
                end                
                
                A_rec_gray = imresize(A_rec_gray, [new_h, new_w]);
                %                 A_rec_gray = imresize(A_rec_gray, [size(A_rec_gray, 1) + 1, size(A_rec_gray, 2) + 1]);
                A_rec_color = imresize(A_rec_color, [size(A_rec_gray, 1), size(A_rec_gray, 2)]);
                A_bd_gray = A_rec_gray;
                
                A_num_rows = size(A_rec_gray, 1) - h + 1;
                A_num_cols = size(A_rec_gray, 2) - w + 1;
                A_num_patches = A_num_rows * A_num_cols;
                A_patches = zeros(A_num_patches, h * w);
                for i = 1:A_num_cols
                    for j = 1:A_num_rows
                        idx = (i - 1) * A_num_rows + j;
                        A_patches(idx, :) = reshape(A_rec_gray(j:j + h -1, i:i + w - 1), 1, []);
                    end
                end
                
                % bidirectional matching
                [match_A2B, match_B2A] = func_bds(A_patches, B_patches);
                
                % reconstruct
                A_rec_gray = func_rec_gray(A_rec_gray, A_num_rows, A_num_cols, h, w, B_patches, match_A2B,  match_B2A);
                
                % fixed boundary
                A_rec_gray(1:bd, :) = A_bd_gray(1:bd, :);
                A_rec_gray(:, 1:bd) = A_bd_gray(:, 1:bd);
                A_rec_gray(end - bd + 1:end, :) = A_bd_gray(end - bd + 1:end, :);
                A_rec_gray(:, end - bd + 1:end) = A_bd_gray(:, end - bd + 1:end);

                %              % can, use PM to reconstruct color image for
                %              % comparison
                %              ann = nnmex(A_rec_color, B_cur_color, algo, w, num_iter, [], [], [], [], cores);
                %              bnn = nnmex(B_cur_color, A_rec_color, algo, w, num_iter, [], [], [], [], cores);
                %              A_rec_color = votemex(B_cur_color, ann, bnn,  algo, w);
            end
        end
        
        A_rec_color = func_rec_color(A_rec_color, A_num_rows, A_num_cols, B_num_rows, B_num_cols, h, w, B_cur_color, match_A2B,  match_B2A);
        
%         im_out = imresize(A_rec_color, 8, 'nearest');
%         imwrite(im_out,  [cwd(1, 1:2) '\Chuan\Dropbox\Project\2DBuildingBlock\SiggraphAsia\Results\Syn\Baseline\BDS_Pixel_onestep\' num2str(scale_level) '\' img_name '_bds_pixel_scale_' num2str(scale_level) '_res_' num2str(i_res) '.png']);
      
        patch_match = 32/(2^(scale_level - 1));
        
        for i_res = 2:4
            
            new_A_size = size(A_rec_color(:, :, 1)) * 2;
            A_rec_color = imresize(A_rec_color, [new_A_size(1), new_A_size(2)]);
            %             A_bd_color = round(A_rec_color * 255);
            
            if size(A_rec_color, 1) <= patch_match
                patch_match = round(patch_match/2);
            end
            if size(A_rec_color, 2) <= patch_match
                patch_match = round(patch_match/2);
            end
            
            new_B_size = size(B_cur_color(:, :, 1)) * 2;
            B_cur_color = imresize(B, new_B_size);
            
            ann = nnmex(A_rec_color, B_cur_color, algo, patch_match, num_iter, [], [], [], [], cores);
            bnn = nnmex(B_cur_color, A_rec_color, algo, patch_match, num_iter, [], [], [], [], cores);
            A_rec_color = votemex(B_cur_color, ann, bnn,  algo, patch_match);
            
%             im_out = imresize(A_rec_color, 2^(4 - i_res), 'nearest');
%             imwrite(im_out,  [cwd(1, 1:2) '\Chuan\Dropbox\Project\2DBuildingBlock\SiggraphAsia\Results\Syn\Baseline\BDS_Pixel_onestep\' num2str(scale_level) '\' img_name '_bds_pixel_scale_' num2str(scale_level) '_res_' num2str(i_res) '.png']);
%             
            %             if i_res < 4
            %                 A_rec_color(1:bd * 2^(i_res - 1) , :) = A_bd_color(1:bd * 2^(i_res - 1), :);
            %                 A_rec_color(:, 1:bd * 2^(i_res - 1), :) = A_bd_color(:, 1:bd * 2^(i_res - 1), :);
            %                 A_rec_color(end - bd * 2^(i_res - 1) + 1:end, :) = A_bd_color(end - bd * 2^(i_res - 1) + 1:end, :);
            %                 A_rec_color(:, end - bd * 2^(i_res - 1) + 1:end, :) = A_bd_color(:, end - bd * 2^(i_res - 1) + 1:end, :);
            %             end
            %             A_rec_color = double(A_rec_color)/255;
        end
        
        im_out = imresize(A_rec_color, 2^(4 - i_res), 'nearest');
        imwrite(im_out,  [cwd(1, 1:2) '\Chuan\Dropbox\Project\2DBuildingBlock\SiggraphAsia\Results\Syn\Baseline\BDS_Pixel_onestep\' num2str(scale_level) '\' img_name '_bds_pixel_' num2str(global_scaler(1)) '_' num2str(global_scaler(2)) '.png']);
  
    end
    %     catch
    %
    %     end
end


if matlabpool('size') > 0
    matlabpool close;
end
