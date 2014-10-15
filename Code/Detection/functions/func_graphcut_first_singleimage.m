function D_train = func_graphcut_first_singleimage(D_train, P)

hog = dense_hog_CL(D_train.im, P.pre_hog_cell_size, P.pre_flag_hog_norm);
x_range = [1, size(hog, 2)];
y_range = [1, size(hog, 1)];
num_patch_dense = x_range(2) * y_range(2);
idx_all = [1:num_patch_dense];
M_idx = reshape(idx_all, (y_range(2) - y_range(1) + 1), (x_range(2) - x_range(1) + 1));
M_idx = M_idx(1:P.pre_sample_step_dense:end, 1:P.pre_sample_step_dense:end);
idx_all = M_idx(:)';
[i_row, i_col] = ind2sub([size(hog, 1), size(hog, 2)], idx_all);
D_train.hog_cell = zeros(31, size(idx_all, 2));
for i = 1:size(D_train.hog_cell, 2)
    D_train.hog_cell(:, i) = reshape(hog(i_row(1, i), i_col(1, i), :), [], 1);
end
D_train.graphcut_map_size = [size(M_idx, 1), size(M_idx, 2)];

    
% compute unary cost for assigning different labels to each cell
map_unary_all = zeros(D_train.graphcut_map_size(1), D_train.graphcut_map_size(2), size(D_train.hypothesis_cen, 2) + 1);

for i_hypo = 1:size(D_train.hypothesis_cen, 2)
    map_unary = P.bblock_graphcut_p_ini * ones(D_train.graphcut_map_size);
    max_off_x = max(1, round(D_train.bb_w(1, D_train.hypothesis_cen(1, i_hypo))/(2 * P.pre_sample_step_dense)));
    max_off_y = max(1, round(D_train.bb_h(1, D_train.hypothesis_cen(1, i_hypo))/(2 * P.pre_sample_step_dense)));
%     [max_off_x max_off_y]
    for off_x = -P.bblock_graphcut_obj_size(1):P.bblock_graphcut_obj_size(1)
        for off_y = -P.bblock_graphcut_obj_size(2):P.bblock_graphcut_obj_size(2)
%     for off_x = -max_off_x:max_off_x
%         for off_y = -max_off_y:max_off_y
            loc_x = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(1, :) + off_x + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
            loc_y = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(2, :) + off_y + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
            
            % test if the shifting move any cell outside of the image
            % boundary
            
            mask = loc_x > 0 & loc_x <= D_train.graphcut_map_size(2) & loc_y > 0 & loc_y <= D_train.graphcut_map_size(1);
            if sum(mask) < size(mask, 2)
                % some cell has been moved outside of the image
                % boundary. In this case we put very high penalty on these
                % shifted cells
                if sum(mask) > 0
                    loc_valid = [loc_x(mask); loc_y(mask)];
                    idx_valid = sub2ind(size(M_idx), loc_valid(2, :), loc_valid(1, :));
                    
                    % only replace the cost if the new one is smaller
                    % than the old one
                    mask2 = map_unary(idx_valid) > P.bblock_graphcut_p_outside;
                    map_unary(idx_valid(mask2)) = P.bblock_graphcut_p_outside;
                end
            else
                % all cells are inside of the image boundary. In this
                % case we calculate the hog distance to the mean
                loc_valid = [loc_x; loc_y];
                idx_valid = sub2ind(D_train.graphcut_map_size, loc_valid(2, :), loc_valid(1, :));
                hog_valid = D_train.hog_cell(:, idx_valid);
                hog_mean = mean(hog_valid, 2);
                M_cell = dist2(hog_valid', hog_mean');
                % here use the size of the pattern as a inverse weight
                mask2 = map_unary(idx_valid) > round(mean(M_cell) * P.bblock_graphcut_p_scaler/sum(mask));
                map_unary(idx_valid(mask2)) = round(mean(M_cell) * P.bblock_graphcut_p_scaler/sum(mask));
%                 mask2 = map_unary(idx_valid) > round(mean(M_cell) * P.bblock_graphcut_p_scaler);
%                 map_unary(idx_valid(mask2)) = round(mean(M_cell) * P.bblock_graphcut_p_scaler);
                
            end
        end
    end
    map_unary_all(:, :, i_hypo) = map_unary;
    
%     figure;
%     imshow(imresize(5 * map_unary/max(max(map_unary)), 4, 'nearest'));
    
end

map_unary_all(:, :, end) = P.bblock_graphcut_background;

num_pixel = size(map_unary_all, 1) * size(map_unary_all, 2);
num_label = size(map_unary_all, 3);
cost_unary = zeros(num_label, num_pixel);
cost_smooth = zeros(num_label, num_label);
weight_neighbors = zeros(num_pixel, num_pixel);

h = GCO_Create(num_pixel, num_label);   % Create new object

for i_label = 1:num_label
    cost_unary(i_label, :) = reshape(map_unary_all(:, :, i_label), 1, []);
end

for i_label = 1:num_label
    for j_label = 1:num_label
        if i_label ~= j_label
            cost_smooth(i_label, j_label) = P.bblock_graphcut_pairwise;
        end
    end
end

idx_all_pixel = [1:num_pixel];
[row_pixel, col_pixel] = ind2sub([D_train.graphcut_map_size(1), D_train.graphcut_map_size(2)], idx_all_pixel);

% up and down ([x; y])
sub_up = [col_pixel; row_pixel];
sub_up(2, :) = sub_up(2, :) - 1;
mask = sub_up(2, :) > 0;
idx_all_up(1, :) = idx_all_pixel(mask);
idx_all_up(2, :) = sub2ind([D_train.graphcut_map_size(1), D_train.graphcut_map_size(2)], sub_up(2, mask), sub_up(1, mask));
for i = 1:size(idx_all_up, 2)
    weight_neighbors(idx_all_up(1, i), idx_all_up(2, i)) = P.bblock_graphcut_weight_neighbour;
    weight_neighbors(idx_all_up(2, i), idx_all_up(1, i)) = P.bblock_graphcut_weight_neighbour;
end

%     % left and right
sub_left = [col_pixel; row_pixel];
sub_left(1, :) = sub_left(1, :) - 1;
mask = sub_left(1, :) > 0;
idx_all_left(1, :) = idx_all_pixel(mask);
idx_all_left(2, :) = sub2ind([D_train.graphcut_map_size(1), D_train.graphcut_map_size(2)], sub_left(2, mask), sub_left(1, mask));
for i = 1:size(idx_all_left, 2)
    weight_neighbors(idx_all_left(1, i), idx_all_left(2, i)) = P.bblock_graphcut_weight_neighbour;
    weight_neighbors(idx_all_left(2, i), idx_all_left(1, i)) = P.bblock_graphcut_weight_neighbour;
end

GCO_SetDataCost(h, int32(cost_unary));

GCO_SetSmoothCost(h, int32(cost_smooth));
%         %
GCO_SetNeighbors(h, weight_neighbors);

[E1 D1 S1] = GCO_ComputeEnergy(h);
GCO_Expansion(h, P.bblock_graphcut_num_iter);
[E2 D2 S2] = GCO_ComputeEnergy(h);

D_train.label_first = GCO_GetLabeling(h);
D_train.weight_neighbors = weight_neighbors;

im_label = zeros(size(map_unary_all, 1), size(map_unary_all, 2));
im_red = ones(size(map_unary_all, 1), size(map_unary_all, 2));
im_green = ones(size(map_unary_all, 1), size(map_unary_all, 2));
im_blue = ones(size(map_unary_all, 1), size(map_unary_all, 2));
im_red = im_red(:);
im_green = im_green(:);
im_blue = im_blue(:);

im_red_seg = im_red;
im_green_seg = im_green;
im_blue_seg = im_blue;

for i_label = 1:num_label - 1
    good_idx = idx_all_pixel(D_train.label_first == i_label);
    im_red_seg(good_idx) = P.label_list(i_label, 1);
    im_green_seg(good_idx) = P.label_list(i_label, 2);
    im_blue_seg(good_idx) = P.label_list(i_label, 3);
    im_label(good_idx) = i_label;
end
D_train.im_label = im_label;
im_red_seg = reshape(im_red_seg, size(map_unary_all, 1), size(map_unary_all, 2));
im_green_seg = reshape(im_green_seg, size(map_unary_all, 1), size(map_unary_all, 2));
im_blue_seg = reshape(im_blue_seg, size(map_unary_all, 1), size(map_unary_all, 2));

im_seg = cat(3, im_red_seg, im_green_seg, im_blue_seg);
% imwrite(imresize(im_seg, 4, 'nearest'), [P.output_path D_train.img_name 'graphcut_1_rob_' num2str(P.i_rob) '_qlt_' num2str(P.i_qlt) '.png']);
% imwrite(imresize(im_seg, 4, 'nearest'), [D_train.img_name 'graphcut_1_rob_' num2str(P.i_rob)  '.png']);

% important, after the first round of graph cut, we need to remove
% the site that are completed covered by other building blocks.
% Otherwise one mis-covered site will force the removal of all sites
% belong to the same building block in the second round -- when all
% objects are foreced to have the same size

for i_hypo = 1:size(D_train.hypothesis_cen, 2)
    idx = sub2ind(size(D_train.im_label), D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(2, :) + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense)), D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(1, :) + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense)));
%     idx = sub2ind(size(D_train.im_label), D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(2, :) + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense)), D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(1, :) + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense)));
    mask = D_train.im_label(idx) == i_hypo;
    D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)} = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_hypo)}(:, mask);
end

% improvement, need to set a minmum threshold for number of valid neighours
% for a valid site, otherwise the site will be too small.. but first, there
% is some bug still 



