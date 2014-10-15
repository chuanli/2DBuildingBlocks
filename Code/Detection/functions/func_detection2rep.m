function  D_train = func_detection2rep(D_train, P)

D_train.bb = D_train.rep_pixel_loc;

im_cover = zeros(size(D_train.im, 1), size(D_train.im, 2));
count = 0;
for i_bb = 1:size(D_train.bb, 2)
    if ~isempty(D_train.bb{1, i_bb})
        for i_obj = 1:size(D_train.bb{1, i_bb}, 2)
            x_start = D_train.bb{1, i_bb}(1, i_obj);
            y_start = D_train.bb{1, i_bb}(2, i_obj);
            x_end = min(size(im_cover, 2), x_start + P.pre_hog_cell_size * P.pre_hog_patch_size);
            y_end = min(size(im_cover, 1), y_start + P.pre_hog_cell_size * P.pre_hog_patch_size);
            im_cover(y_start:y_end, x_start:x_end) = 1;
            count = count + 1;
        end
    end
end
% figure;
% imshow(im_cover)
% The area of a building block is approximated as the total_covered_pixel/num_obj 
D_train.bb_w = ones(1, size(D_train.bb, 2)) * max(1, round(sqrt(sum(sum(im_cover))/count)) - 1);
D_train.bb_h = D_train.bb_w;

% sift bb to the top left corner
for i_bb = 1:size(D_train.bb, 2)
    if ~isempty(D_train.bb{1, i_bb})
        D_train.bb{1, i_bb}(1, :) =  D_train.bb{1, i_bb}(1, :) - max(1, floor(D_train.bb_w(1, i_bb)/2));
        D_train.bb{1, i_bb}(2, :) =  D_train.bb{1, i_bb}(2, :) - max(1, floor(D_train.bb_h(1, i_bb)/2));
    end
end

if P.discriminative_detection_mode == 5
    mkdir([P.output_path 'dl\']);
    parsave_discriminative([P.output_path 'dl\' D_train.img_name '_dl' '_rob_' num2str(P.i_rob)  '.mat'], D_train);
else if P.discriminative_detection_mode == 2
        if P.detectorimprove_supervision == 1
            mkdir([P.output_path 'sws\']);
            parsave_discriminative([P.output_path 'sws\' D_train.img_name '_sws' '_rob_' num2str(P.i_rob)  '.mat'], D_train);
        else
            mkdir([P.output_path 'sw\']);
            parsave_discriminative([P.output_path 'sw\' D_train.img_name '_sw' '_rob_' num2str(P.i_rob)  '.mat'], D_train);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compue the average size of building blocks for DL only detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mask = zeros(1, D_buffer.nbCluster);
% for i_bb = 1:size(D_train.rep_binary, 3)
%     if sum(sum(D_train.rep_binary(:, :, i_bb))) >= P.discriminative_min_sample
%         mask(1, i_bb) = 1;
%     end
% end
% 
% mask = logical(mask);
% D_buffer.cluster = D_buffer.cluster(1, mask);
% D_buffer.cluster_size = D_buffer.cluster_size(1, mask);
% D_buffer.nbCluster = sum(mask);
% D_buffer.detector = D_buffer.detector(1, mask);
% D_buffer.hog_key_mean = D_buffer.hog_key_mean(:, mask);
% D_buffer.hog_key_mean_NN = D_buffer.hog_key_mean_NN(:, mask);
% D_buffer.hog_key_mean_KNN = D_buffer.hog_key_mean_KNN(:, mask);
% D_buffer.bb_mean = D_buffer.bb_mean(:, mask);
% D_buffer.bb_mean_NN = D_buffer.bb_mean_NN(:, mask);
% D_buffer.bb_mean_KNN = D_buffer.bb_mean_KNN(:, mask);
% 
% D_train.occ = D_train.occ(:, :, mask);
% D_train.rep_binary = D_train.rep_binary(:, :, mask);
% 
% mask2 = zeros(1, size(D_buffer.hog_key, 2));
% for i_bb = 1:size(D_buffer.cluster, 2)
%     mask2(1, D_buffer.cluster{1, i_bb}) = 1;
% end
% mask2 = logical(mask2);
% D_buffer.hog_key = D_buffer.hog_key(:, mask2);
% D_buffer.loc_key = D_buffer.loc_key(:, mask2);
% D_buffer.hog_key_img_id = D_buffer.hog_key_img_id(:, mask2);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % some temporary data to make momery efficient for parfor
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     temp_D_train.x_range = D_train.x_range;
%     temp_D_train.y_range = D_train.y_range;
%     temp_D_train.rep_binary = D_train.rep_binary;
% 
% %% final note: parfor safe
% temp_D_train.rep_site_loc = cell(1, size(temp_D_train.rep_binary, 3));
% temp_D_train.rep_pixel_loc = cell(1, size(temp_D_train.rep_binary, 3));
% temp_D_train.rep_site_num = zeros(1, size(temp_D_train.rep_binary, 3));
% idx_all = [1:size(temp_D_train.rep_binary, 1) * size(temp_D_train.rep_binary, 2)];
% 
% for i_bb = 1:size(temp_D_train.rep_binary, 3)
%     if sum(sum(temp_D_train.rep_binary(:, :, i_bb))) > 0
%         % map the location from rep_binary to full resolution
%         A = logical(temp_D_train.rep_binary(:, :, i_bb));
%         [y_coord, x_coord] = ind2sub([size(temp_D_train.rep_binary(:, :, i_bb), 1), size(temp_D_train.rep_binary(:, :, i_bb), 2)], idx_all(A(:)));
%         temp_D_train.rep_site_loc{1, i_bb} = [x_coord; y_coord];
%         loc_site = [x_coord; y_coord];
%         loc_site(1, :) = (loc_site(1, :)  - 1) *  P.pre_sample_step_dense + 1 + temp_D_train.x_range(1) - 1;
%         loc_site(2, :) = (loc_site(2, :)  - 1) *  P.pre_sample_step_dense + 1 + temp_D_train.y_range(1) - 1;
%         temp_D_train.rep_pixel_loc{1, i_bb} = loc_site;
%         temp_D_train.rep_site_num(1, i_bb) = size(loc_site, 2);
%     else
%         ;
%     end
% end
% 
% 
% D_train.rep_site_loc = temp_D_train.rep_site_loc;
% D_train.rep_pixel_loc = temp_D_train.rep_pixel_loc;
% D_train.rep_site_num = temp_D_train.rep_site_num;
% 
% 
% D_temp = [];
% max_num_site = 0;
% if ~isempty(D_train.rep_site_num)
%     max_num_site = max([max_num_site, D_train.rep_site_num]);
% end
% 
% D_temp.bb_range = cell(1, size(D_buffer.cluster, 2));
% for i = 1:size(D_temp.bb_range, 2)
%     D_temp.bb_range{1, i} = zeros(4, max_num_site);
% end
% D_temp.new_cluster = cell(1, size(D_buffer.cluster, 2));
% D_temp.new_cluster_size  = zeros(1, size(D_buffer.cluster, 2));
% D_temp.new_nbCluster = size(D_buffer.cluster, 2);
% D_temp.new_hog_key_mean = zeros(size(D_buffer.hog_key_mean, 1), size(D_buffer.cluster, 2));
% D_temp.new_hog_key_mean_NN = zeros(size(D_buffer.hog_key_mean, 1), size(D_buffer.cluster, 2));
% D_temp.new_hog_key_mean_KNN = zeros(size(D_buffer.hog_key_mean, 1), size(D_buffer.cluster, 2));
% D_temp.new_loc_key = zeros(2, size(D_buffer.cluster, 2) * max_num_site);
% D_temp.new_hog_key_img_id = zeros(1, size(D_buffer.cluster, 2) * max_num_site);
% D_temp.new_hog_key_dense_id = zeros(1, size(D_buffer.cluster, 2) * max_num_site);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % sample new hog features at the repetition
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% count_hog = 1;
% im_render_red = D_train.im(:, :, 1);
% im_render_green = D_train.im(:, :, 2);
% im_render_blue = D_train.im(:, :, 3);
% for i_bb = 1:size(D_train.rep_binary, 3)
%     count_bb = 1;
%     if ~isempty(D_train.rep_pixel_loc{1, i_bb})
%         for i_site = 1:size(D_train.rep_site_loc{1, i_bb}, 2)
%             bb_range_temp = [D_train.rep_pixel_loc{1, i_bb}(1, i_site) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2) - 1); ...
%                 D_train.rep_pixel_loc{1, i_bb}(1, i_site) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2); ...
%                 D_train.rep_pixel_loc{1, i_bb}(2, i_site) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2) - 1); ...
%                 D_train.rep_pixel_loc{1, i_bb}(2, i_site) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2)];
%             
%             x = D_train.rep_site_loc{1, i_bb}(1, i_site);
%             y = D_train.rep_site_loc{1, i_bb}(2, i_site);
%             idx_rep_site = sub2ind([size(D_train.rep_binary, 1), size(D_train.rep_binary, 2)], y, x);
%             D_temp.new_hog_key_dense_id(:, count_hog) = idx_rep_site;
%             D_temp.new_hog_key_img_id(:, count_hog) = 1;
%             D_temp.new_loc_key(:, count_hog) = [D_train.rep_pixel_loc{1, i_bb}(1, i_site); D_train.rep_pixel_loc{1, i_bb}(2, i_site)];
%             D_temp.new_cluster{1, i_bb} = [D_temp.new_cluster{1, i_bb} count_hog];
%             count_hog = count_hog + 1;
%             D_temp.bb_range{1, i_bb}(:, count_bb) = bb_range_temp;
%             count_bb = count_bb + 1;
%         end
%     end
% end
% 
% 
% 
% num_hog_total = 0;
% mask = D_temp.new_hog_key_dense_id ~= 0;
% D_temp.new_hog_key_dense_id = D_temp.new_hog_key_dense_id(1, mask);
% D_temp.new_hog_key_img_id = D_temp.new_hog_key_img_id(:, mask);
% D_temp.new_loc_key = D_temp.new_loc_key(:, mask);
% 
% num_hog_total = num_hog_total + size(D_temp.new_loc_key, 2);
% 
% D_temp.new_hog_key = D_train.hog_dense(:, D_temp.new_hog_key_dense_id);
% D_temp.num_hog_key = size(D_temp.new_hog_key, 2);
% 
% 
% D_temp.bb = cell(1, size(D_buffer.cluster, 2));
% for i_bb = 1:size(D_temp.bb_range, 2)
%     mask = sum(D_temp.bb_range{1, i_bb}) ~= 0;
%     D_temp.bb_range{1, i_bb} = D_temp.bb_range{1, i_bb}(:, mask);
%     D_temp.bb{1, i_bb} = cell(1, size(D_temp.bb_range{1, i_bb}, 2));
%     for j = 1:size(D_temp.bb{1, i_bb}, 2)
%         D_temp.bb{1, i_bb}{1, j} = D_train.im(D_temp.bb_range{1, i_bb}(3, j):D_temp.bb_range{1, i_bb}(4, j), D_temp.bb_range{1, i_bb}(1, j):D_temp.bb_range{1, i_bb}(2, j), :);
%     end
% end
% 
% D_buffer.new_hog_key = zeros(size(D_buffer.hog_key_mean, 1), num_hog_total);
% D_buffer.new_hog_key_img_id = zeros(1, num_hog_total);
% 
% pre_count = 0;
% cluster_idx = cell(1, size(D_buffer.cluster, 2));
% D_buffer.new_hog_key(:, pre_count + 1:pre_count + D_temp.num_hog_key) = D_temp.new_hog_key;
% D_buffer.new_hog_key_img_id(1, pre_count + 1:pre_count + D_temp.num_hog_key) = D_temp.new_hog_key_img_id;
% D_buffer.new_loc_key(:, pre_count + 1:pre_count + D_temp.num_hog_key) = D_temp.new_loc_key;
% 
% for i_bb = 1:size(D_buffer.cluster, 2)
%     cluster_idx{1, i_bb} = [cluster_idx{1, i_bb} D_temp.new_cluster{1, i_bb} + pre_count];
% end
% pre_count = pre_count + D_temp.num_hog_key;
% 
% 
% D_buffer.new_cluster = cluster_idx;
% D_buffer.new_cluster_size = zeros(1, size(D_buffer.new_cluster, 2));
% D_buffer.new_nbCluster = size(D_buffer.new_cluster, 2);
% 
% for i_bb = 1:size(D_buffer.new_cluster, 2)
%     if ~isempty(D_buffer.new_cluster{1, i_bb})
%         D_buffer.new_cluster_size(1, i_bb) = size(D_buffer.new_cluster{1, i_bb}, 2);
%     end
% end
% 
% D_buffer.new_hog_key_mean = D_buffer.hog_key_mean;
% D_buffer.new_hog_key_mean_NN = D_buffer.hog_key_mean_NN;
% D_buffer.new_hog_key_mean_KNN = D_buffer.hog_key_mean_KNN;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % new_hog_key_mean, new_hog_key_mean_NN and new_hog_key_mean_KNN
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for i_bb = 1:D_buffer.new_nbCluster
%     if ~isempty(D_buffer.new_cluster{1, i_bb})
%         D_buffer.new_hog_key_mean(:, i_bb) = mean(D_buffer.new_hog_key(:, D_buffer.new_cluster{1, i_bb}), 2);
%         
%         temp_dist = dist2(D_buffer.new_hog_key(:, D_buffer.new_cluster{1, i_bb})', D_buffer.new_hog_key_mean(:, i_bb)');
%         [cmin, imin] = min(temp_dist);
%         D_buffer.new_hog_key_mean_NN(:, i_bb) = D_buffer.new_hog_key(:, D_buffer.new_cluster{1, i_bb}(1, imin));
%         
%         temp_dist(:, 2) = [1:size(temp_dist, 1)];
%         temp_dist = sortrows(temp_dist, 1);
%         D_buffer.new_hog_key_mean_KNN(:, i_bb) = mean(D_buffer.new_hog_key(:, D_buffer.new_cluster{1, i_bb}(1, temp_dist(1:(min([P.discriminative_KNN, size(D_buffer.new_cluster{1, i_bb}, 2)])), 2))), 2);
%     else
%         D_buffer.new_hog_key_mean_NN(:, i_bb) = 0;
%         D_buffer.new_hog_key_mean_KNN(:, i_bb) = 0;
%     end
% end
% 
% 
% D_buffer.bb = cell(1, size(D_buffer.new_cluster, 2));
% for i_bb = 1:size(D_temp.bb, 2)
%     D_buffer.bb{1, i_bb} = [D_buffer.bb{1, i_bb} D_temp.bb{1, i_bb}];
% end
% 
% 
% D_buffer.cluster = D_buffer.new_cluster;
% D_buffer.cluster_size = D_buffer.new_cluster_size;
% D_buffer.hog_key_mean = D_buffer.new_hog_key_mean;
% D_buffer.hog_key_mean_NN = D_buffer.new_hog_key_mean_NN;
% D_buffer.hog_key_mean_KNN = D_buffer.new_hog_key_mean_KNN;
% D_buffer.nbCluster = D_buffer.new_nbCluster;
% D_buffer.hog_key  = D_buffer.new_hog_key;
% D_buffer.loc_key  = D_buffer.new_loc_key;
% D_buffer.hog_key_img_id  = D_buffer.new_hog_key_img_id;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % collecting image patches
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bb_img_count = zeros(1, size(D_buffer.cluster, 2));
% D_buffer.bb_mean = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));
% D_buffer.bb_mean_NN = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));
% D_buffer.bb_mean_KNN = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));
% 
% for i = 1:D_buffer.nbCluster
%     cur_idx = D_buffer.cluster{1, i}(1, D_buffer.hog_key_img_id(1, D_buffer.cluster{1, i}) == 1);
%     if ~isempty(cur_idx)
%         bb_img_count(1, i) = bb_img_count(1, i) + size(cur_idx, 2);
%     end
% end
% 
% bb_img_collection = cell(1, size(D_buffer.cluster, 2));
% for i = 1:D_buffer.nbCluster
%     bb_img_collection{1, i} = zeros(3 * P.pre_hog_cell_size * P.pre_hog_patch_size * P.pre_hog_cell_size * P.pre_hog_patch_size, bb_img_count(1, i));
% end
% 
% for i = 1:D_buffer.nbCluster
%     bb_temp = zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
%     count_bb = 0;
%     cur_idx = D_buffer.cluster{1, i};
%     if ~isempty(cur_idx)
%         loc = D_buffer.loc_key(:, cur_idx);
%         for j = 1:size(loc, 2)
%             bb_range_temp = [loc(1, j) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2) - 1); ...
%                 loc(1, j) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2 ); ...
%                 loc(2, j) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2 ) - 1); ...
%                 loc(2, j) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2)];
%             bb_img_collection{1, i}(:, count_bb + 1) = reshape(D_train.im(bb_range_temp(3):bb_range_temp(4), bb_range_temp(1):bb_range_temp(2), :), [], 1);
%             count_bb = count_bb + 1;
%         end
%     end
% end
% 
% for i = 1:D_buffer.nbCluster
%     D_buffer.bb_mean{1, i} = reshape(mean(bb_img_collection{1, i}, 2), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
%     
%     temp_dist = dist2(D_buffer.hog_key(:, D_buffer.cluster{1, i})', D_buffer.hog_key_mean(:, i)');
%     [cmin, imin] = min(temp_dist);
%     D_buffer.bb_mean_NN{1, i} = reshape(bb_img_collection{1, i}(:, imin), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
%     
%     temp_dist(:, 2) = [1:size(temp_dist, 1)];
%     temp_dist = sortrows(temp_dist, 1);
%     D_buffer.bb_mean_KNN{1, i} = reshape(mean(bb_img_collection{1, i}(:, temp_dist(1:min([P.discriminative_KNN, size(D_buffer.cluster{1, i}, 2)]), 2)), 2), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % output the building blocks
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if f_render == 1
%     for i = 1:D_buffer.nbCluster
%         imwrite(D_buffer.bb_mean{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_BB_mean_' num2str(i) '.png']);
%     end
%     for i = 1:D_buffer.nbCluster
%         imwrite(D_buffer.bb_mean_NN{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_BB_mean_NN_' num2str(i) '.png']);
%     end
%     for i = 1:D_buffer.nbCluster
%         imwrite(D_buffer.bb_mean_KNN{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_BB_mean_KNN_' num2str(i) '.png']);
%     end
% end
