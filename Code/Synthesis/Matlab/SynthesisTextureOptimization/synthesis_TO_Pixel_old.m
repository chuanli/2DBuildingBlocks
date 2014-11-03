%% A script for texture optimization
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
P.matlabpool_flag =  0;
P.num_Cores = 4;
% start parallel
if  matlabpool('size') == 0 & P.matlabpool_flag ==1
    matlabpool('open', P.num_Cores);
else if matlabpool('size') > 0 & P.matlabpool_flag ==0
        matlabpool close;
    end
end

global_scaler = [1.5, 1]; 

% parfor i_img = 0:99
for ii_img = 1:size(list, 2)
    i_img = list(ii_img);
%     try
        warning('off','all');
        img_name = ['fac(' num2str(i_img) ')'];
        img_format = '.jpg';
        filename = [img_name img_format];
        P_BDS = [];
        P_BDS.name_path = [cwd(1, 1:2) '\Chuan\local\Data\'];
        P_BDS.name_dataset = 'Kai';
        P_BDS.name_data = 'ALL_Resize';
        P_BDS.name_format = '.jpg';
        P_BDS.output_path = [P_BDS.name_path P_BDS.name_dataset '\' P_BDS.name_data '\resultCOOC\']; mkdir(P_BDS.output_path);
        P_BDS.im_input_fullres = double(imread([P_BDS.name_path '\' P_BDS.name_dataset '\' P_BDS.name_data '\' filename]))/255;
        P_BDS.num_TO_iter = 20;
        
        %         if ~exist( [img_name '_to_pixel_fast_res_' num2str(5) '.png'], 'file')
        row = floor(size(P_BDS.im_input_fullres, 1)/8);
        col = floor(size(P_BDS.im_input_fullres, 2)/8);
        im = imresize(P_BDS.im_input_fullres, [row * 8, col*8]);
        
        A = im;  B = im;
        scaler = [0.125, 0.25, 0.5, 1];
        
        for scale_level = 1:1
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
                
                % [M_A2B, M_B2A] = func_bds(A_rec_gray, B_cur_gray, w);
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

                new_size = [round(global_scaler(2) * size(A_rec_gray, 1)), round(global_scaler(1) * size(A_rec_gray, 2))];
                A_rec_gray = imresize(A_rec_gray, [new_size(1), new_size(2)]);
                
                A_rec_color = imresize(A_rec_color, [size(A_rec_gray, 1), size(A_rec_gray, 2)]);
                
                for i_iter = 1:P_BDS.num_TO_iter
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
                    
                    % bi-direction matching
                    [match_A2B, match_B2A] = func_bds(A_patches, B_patches);
                    
                    % reconstruct
                    A_rec_gray = func_rec_coherence_gray(A_rec_gray, A_num_rows, A_num_cols, h, w, B_patches, match_A2B,  match_B2A);    
                end
            end
            
            A_rec_color = func_rec_coherence_color(A_rec_color, A_num_rows, A_num_cols, B_num_rows, B_num_cols, h, w, B_cur_color, match_A2B,  match_B2A);
            patch_match = 32/(2^(scale_level - 1));
            for i_res = 2:4
                new_A_size = size(A_rec_color(:, :, 1)) * 2;
                A_rec_color = imresize(A_rec_color, [new_A_size(1), new_A_size(2)]);
                
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
            end
            
            im_out = imresize(A_rec_color, 2^(4 - i_res), 'nearest');
            imwrite(im_out,  [cwd(1, 1:2) '\Chuan\Dropbox\Project\2DBuildingBlock\SiggraphAsia\Results\Syn\Baseline\TO_Pixel_onestep\' num2str(scale_level) '\' img_name '_to_pixel_' num2str(global_scaler(1)) '_' num2str(global_scaler(2)) '.png']);

        end
%     catch
%         
%     end
end


if matlabpool('size') > 0
    matlabpool close;
end