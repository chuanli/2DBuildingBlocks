function D_train = func_build_parseImg_singleimage(im, P, f_disp)

% corner detection
C = corner(rgb2gray(im), 'Harris', P.pre_harris_max_num, 'QualityLevel', P.pre_harris_QualityLevel, 'SensitivityFactor', P.pre_harris_SensitivityFactor);
C = round(unique(C, 'rows')');

% make a binary corner map
idx_cor = sub2ind([size(im, 1) size(im, 2)], C(2, :), C(1, :));
map_cor = zeros(size(im, 1), size(im, 2));
map_cor(idx_cor) = 1;

% dense HoG feature detection 
% hog = dense_hog(im, P.hog_cell_size);
hog = dense_hog_CL(im, P.pre_hog_cell_size, P.pre_flag_hog_norm); % with the option of not using normalization

% find the dimension of occ maps
x_range = [(P.pre_hog_patch_size/2) * P.pre_hog_cell_size + 1, size(hog, 2) - (P.pre_hog_patch_size/2) * P.pre_hog_cell_size];
y_range = [(P.pre_hog_patch_size/2) * P.pre_hog_cell_size + 1, size(hog, 1) - (P.pre_hog_patch_size/2) * P.pre_hog_cell_size];
num_patch_dense = (x_range(2) - x_range(1) + 1) * (y_range(2) - y_range(1) + 1);

hog_dense = zeros(P.pre_hog_dim, num_patch_dense);
loc_dense = zeros(2, num_patch_dense);
mask_key = zeros(1, num_patch_dense);

shift = P.pre_hog_patch_size/2;
temp = zeros(P.pre_hog_patch_size * P.pre_hog_cell_size, P.pre_hog_patch_size * P.pre_hog_cell_size, 31);

count = 1;
for i = x_range(1):x_range(2)
    for j = y_range(1):y_range(2)
        if map_cor(j, i) == 1
            mask_key(1, count) = 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SLOW: Indexing into hog is slow. Should be optimized in the
        % future
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        temp = hog(shift + j - shift * P.pre_hog_cell_size:P.pre_hog_cell_size:shift + j + (shift - 1) * P.pre_hog_cell_size, ...
                        shift + i - shift * P.pre_hog_cell_size:P.pre_hog_cell_size:shift + i + (shift - 1) * P.pre_hog_cell_size, ...
                        :);
        hog_dense(:, count) = temp(:);
        loc_dense(:, count) = [i, j];
        count = count + 1;
    end
end

switch P.pre_keyhog_sample_mode
    case 1
        % use evenly sparse sample
        idx_all = 1:num_patch_dense;
        M_idx = reshape(idx_all, (y_range(2) - y_range(1) + 1), (x_range(2) - x_range(1) + 1));
        M_idx = M_idx(1:P.pre_sample_step_key:end, 1:P.pre_sample_step_key:end);
        idx_all = M_idx(:)';
        hog_key = hog_dense(:, idx_all);
        loc_key = loc_dense(:, idx_all);
        num_patch_key = size(hog_key, 2);
    case 2
        % use corners
        hog_key = hog_dense(:, logical(mask_key));
        loc_key = loc_dense(:, logical(mask_key));
        num_patch_key = size(hog_key, 2);
    case 3
        % use random locations
        rng('shuffle');
        temp = 1:num_patch_dense;
        idx_all = [rand(1, size(temp, 2)); temp];
        idx_all = sortrows(idx_all', 1);
        hog_key = hog_dense(:, idx_all(1:min(100, size(hog_dense, 2)), 2));
        loc_key = loc_dense(:, idx_all(1:min(100, size(hog_dense, 2)), 2));
        num_patch_key = size(hog_key, 2);        
    otherwise
end

% subsample dense HoGs for speeding up later operation with occ maps
idx_all = 1:num_patch_dense;
M_idx = reshape(idx_all, (y_range(2) - y_range(1) + 1), (x_range(2) - x_range(1) + 1));
M_idx = M_idx(1:P.pre_sample_step_dense:end, 1:P.pre_sample_step_dense:end);
idx_all = M_idx(:)';
hog_dense = hog_dense(:, idx_all);
loc_dense = loc_dense(:, idx_all);
num_patch_dense = size(hog_dense, 2);

D_train.im = im;
D_train.hog_dense = hog_dense;
D_train.loc_dense = loc_dense;
D_train.num_patch_dense = num_patch_dense;

D_train.hog_key = hog_key;
D_train.loc_key = loc_key;
D_train.num_patch_key = num_patch_key;

D_train.x_range = x_range;
D_train.y_range = y_range;
D_train.hog_cell_map = hog;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interative display of initial HoG features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if f_disp == 1
%     im_cut = D_train.im(D_train.y_range(1):D_train.y_range(2), D_train.x_range(1):D_train.x_range(2), :);
%     scrsz = get(0,'ScreenSize');
%     figure('Position',[100 scrsz(4)/2 - 100 scrsz(3)/2 scrsz(4)/2],'Color',[1 1 1], 'name', 'clusters');
%     subplot(1, 2, 1);
%     imshow(im_cut);
%     hold on;
%     plot(D_train.loc_key(1, :) - D_train.x_range(1) + 1, D_train.loc_key(2, :) - D_train.y_range(1) + 1, 'ro');
%     
%     but = 1;
%     while but == 1
%         [xi,yi,but] = ginput(1);
%         if but == 1
%             temp = dist2(D_train.loc_key' - repmat([D_train.x_range(1), D_train.y_range(1)], size(D_train.loc_key, 2), 1) + 1, [xi, yi]);
%             [minc, mini] = min(temp);
%             hold on;
%             subplot(1, 2, 2);
%             subimage(D_train.occ_key(:, :, mini)/max(max(D_train.occ_key(:, :, mini))));
%         end
%     end
% end

