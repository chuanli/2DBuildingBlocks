% Initialize dictionary for single images

function D_buffer = func_ini_dictionary_singleimage(D_buffer, D_train, P, f_output, f_render)

D_buffer.hog_key = D_train.hog_key;
D_buffer.loc_key = D_train.loc_key;
D_buffer.hog_key_img_id = ones(1, size(D_train.hog_key, 2)); % image id is always set to one for single-image detection

hog = D_buffer.hog_key;
if P.pre_dictionary_mode == 0
    cluster = cell(1, size(D_buffer.hog_key, 2));
    for i = 1:size(cluster, 2)
        cluster{1, i} = i;
    end
    cluster_size = ones(1, size(D_buffer.hog_key, 2));
    nbCluster = size(D_buffer.hog_key, 2);
    
else
    % the number of building blocks clusters is decided as the smaller number
    % between P.max_numberof_BB and a experience based estimation.
    d4D = P.pre_dictionary_d4D;
    min_cluster_size = P.pre_dictionary_cluster_size;
    nbCluster = min(P.pre_dictionary_max_cluster_num, round(size(hog, 2)/d4D));
    options.K = nbCluster;
    options.max_ite = 50;
    options.num_threads = 2;
    record = cell(1, P.discriminative_iter_kmeans);
    record_sumd = zeros(1, P.discriminative_iter_kmeans);
    record_cendis = cell(1, P.discriminative_iter_kmeans);
    M_dist = pdist(hog', 'euclidean');
    
    if P.pre_dictionary_mode == 1
        feat = hog;
    else if P.pre_dictionary_mode == 2 % spectural embedding
            [feat_mds, e] = cmdscale(M_dist);
            dim_mds_img = min(size(feat_mds, 2), P.pre_dictionary_spect_dim);
            if dim_mds_img > 1
                feat_mds = feat_mds(:, 1:dim_mds_img)';
            else
            end
            feat = feat_mds;
        end
    end
    
    for i = 1:P.discriminative_iter_kmeans
        try
            rng('shuffle');
            %             [centroids, dis, assign , nassign , qerr]  = yael_kmeans(hog, options);
            [centroids, dis, assign , nassign , qerr]  = yael_kmeans(feat, options);
            record{1, i}.IDX = assign';
            record_sumd(1, i) = sum(dis);
            for j = 1:nbCluster
                record_cendis{1, i}(1, j) = sum(dis(assign == j));
            end
        catch
            record{1, i}.IDX = [];
            record_sumd(1, i) = inf;
            record_cendis{1, i} = inf;
        end
    end
    
    [cmin, imin] = min(record_sumd);
    
    IDX = record{1, imin}.IDX;
    idx_all = [1:size(hog, 2)];
    cluster = cell(1, nbCluster);
    cluster_size = zeros(1, nbCluster);
    for i = 1:nbCluster
        idx = idx_all(1, IDX == i);
        cluster_size(1, i) = size(idx, 2);
        cluster{1, i} = idx;
    end
    cendist = record_cendis{1, imin};
    
    % % get rid off the clusters that are too small
    mask = cluster_size >= min_cluster_size;
    cluster = cluster(1, mask);
    cluster_size = cluster_size(1, mask);
    cendist = cendist(1, mask);
    nbCluster = size(cluster, 2);
end

% collect data for output
hog_key_mean = zeros(size(D_buffer.hog_key, 1), nbCluster);
% Get the mean,  NN and KNN to the mean
for i = 1:nbCluster
    hog_key_mean(:, i) = mean(D_buffer.hog_key(:, cluster{1, i}), 2);
    
    temp_dist = dist2(D_buffer.hog_key(:, cluster{1, i})', hog_key_mean(:, i)');
    [cmin, imin] = min(temp_dist);
    hog_key_mean_NN(:, i) = D_buffer.hog_key(:, cluster{1, i}(1, imin));
    
    temp_dist(:, 2) = [1:size(temp_dist, 1)];
    temp_dist = sortrows(temp_dist, 1);
    hog_key_mean_KNN(:, i) = mean(D_buffer.hog_key(:, cluster{1, i}(1, temp_dist(1:(min([P.discriminative_KNN, size(cluster{1, i}, 2)])), 2))), 2);
end

% initialize a identity detector
detector = cell(1, nbCluster);
for i = 1:nbCluster
    detector{1, i}.w = ones(size(D_buffer.hog_key, 1), 1);
end

D_buffer.cluster = cluster;
D_buffer.cluster_size = cluster_size;
D_buffer.nbCluster = nbCluster;
D_buffer.detector = detector;
D_buffer.hog_key_mean = hog_key_mean;
D_buffer.hog_key_mean_NN = hog_key_mean_NN;
D_buffer.hog_key_mean_KNN = hog_key_mean_KNN;
D_buffer.bb_mean = cell(1, size(D_buffer.cluster, 2));
D_buffer.bb_mean_NN = cell(1, size(D_buffer.cluster, 2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collecting image patches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bb_img_count = zeros(1, size(D_buffer.cluster, 2));
D_buffer.bb_mean = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));
D_buffer.bb_mean_NN = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));
D_buffer.bb_mean_KNN = repmat({zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size , 3)}, 1, size(D_buffer.cluster, 2));

for i = 1:D_buffer.nbCluster
    cur_idx = D_buffer.cluster{1, i};
    if ~isempty(cur_idx)
        bb_img_count(1, i) = bb_img_count(1, i) + size(cur_idx, 2);
    end
end

bb_img_collection = cell(1, size(D_buffer.cluster, 2));
for i = 1:D_buffer.nbCluster
    bb_img_collection{1, i} = zeros(3 * P.pre_hog_cell_size * P.pre_hog_patch_size * P.pre_hog_cell_size * P.pre_hog_patch_size, bb_img_count(1, i));
end

for i = 1:D_buffer.nbCluster
    bb_temp = zeros(P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
    count_bb = 0;
    cur_idx = D_buffer.cluster{1, i};
    if ~isempty(cur_idx)
        loc = D_buffer.loc_key(:, cur_idx);
        for j = 1:size(loc, 2)
            bb_range_temp = [loc(1, j) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2) - 1); ...
                loc(1, j) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2 ); ...
                loc(2, j) - (P.pre_hog_cell_size * (P.pre_hog_patch_size/2 ) - 1); ...
                loc(2, j) + P.pre_hog_cell_size * (P.pre_hog_patch_size/2)];
            bb_img_collection{1, i}(:, count_bb + 1) = reshape(D_train.im(bb_range_temp(3):bb_range_temp(4), bb_range_temp(1):bb_range_temp(2), :), [], 1);
            count_bb = count_bb + 1;
        end
    end
end

for i = 1:D_buffer.nbCluster
    D_buffer.bb_mean{1, i} = reshape(mean(bb_img_collection{1, i}, 2), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
    
    temp_dist = dist2(D_buffer.hog_key(:, D_buffer.cluster{1, i})', hog_key_mean(:, i)');
    [cmin, imin] = min(temp_dist);
    D_buffer.bb_mean_NN{1, i} = reshape(bb_img_collection{1, i}(:, imin), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
    
    temp_dist(:, 2) = [1:size(temp_dist, 1)];
    temp_dist = sortrows(temp_dist, 1);
    D_buffer.bb_mean_KNN{1, i} = reshape(mean(bb_img_collection{1, i}(:, temp_dist(1:min([P.discriminative_KNN, size(D_buffer.cluster{1, i}, 2)]), 2)), 2), P.pre_hog_cell_size * P.pre_hog_patch_size, P.pre_hog_cell_size * P.pre_hog_patch_size, 3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output the building blocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if f_output == 1
    parsave_ini_D_buffer([P.output_path D_train.img_name '_dict' '_rob_' num2str(P.i_rob) '.mat'], D_buffer);
end

% if f_render == 1
%     for i = 1:size(D_buffer.bb_mean, 2)
%         imwrite(D_buffer.bb_mean{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_cluster_mean_' num2str(i) '.png']);
%     end
%     for i = 1:size(D_buffer.bb_mean_NN, 2)
%         imwrite(D_buffer.bb_mean_NN{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_cluster_mean_NN_' num2str(i) '.png']);
%     end
%     for i = 1:size(D_buffer.bb_mean_NN, 2)
%         imwrite(D_buffer.bb_mean_KNN{1, i}, [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_cluster_mean_KNN_' num2str(i) '.png']);
%     end
% end


return;
