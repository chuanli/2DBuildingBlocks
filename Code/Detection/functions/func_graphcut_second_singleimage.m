function D_train = func_graphcut_second_singleimage(D_train, P)

% h = figure;
% set(h, 'Color',[1, 2, 255]/255);
% imshow(im_train);
% hold on;
% for i_rep = 1:size(D_train.hypothesis, 2)
%     plot(D_train.bb{1, D_train.hypothesis_cen(1, i_rep)}(1, :), D_train.bb{1, D_train.hypothesis_cen(1, i_rep)}(2, :), 'Color', P.label_list(i_rep, :), 'Marker', '.', 'MarkerSize', 20, 'LineStyle', 'none');
% end
% F = im2frame(zbuffer_cdata(h));
% [x, y] = ind2sub([size(F.cdata,1) size(F.cdata,2)], find(F.cdata(:, :, 1) ~= 1 & F.cdata(:, :, 2) ~= 2 & F.cdata(:, :, 3) ~= 255));
% imwrite(F.cdata(min(x):max(x),min(y):max(y),:),  [name '_test.png']);
% hold off;
% clf;
% close;


num_label = size(D_train.hypothesis_cen, 2) + 1;
hard_label = cell(1, num_label - 1);
num_pixel = D_train.graphcut_map_size(1) * D_train.graphcut_map_size(2);
idx_all_pixel = [1:num_pixel];

D_train.bb = cell(1, num_label - 1);
D_train.bb_w = zeros(1, num_label - 1);
D_train.bb_h = zeros(1, num_label - 1);
D_train.grid_w = zeros(1, num_label - 1);
D_train.grid_h = zeros(1, num_label - 1);

im_red = ones(D_train.graphcut_map_size(1), D_train.graphcut_map_size(2));
im_green = ones(D_train.graphcut_map_size(1), D_train.graphcut_map_size(2));
im_blue = ones(D_train.graphcut_map_size(1), D_train.graphcut_map_size(2));

for i_label = 1:num_label - 1
    if sum(D_train.label_first == i_label) > 0 & ~isempty(D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)})
        num_obj = size(D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)}, 2);
        map_obj_all = 2 * P.bblock_graphcut_p_ini * ones(D_train.graphcut_map_size(1), D_train.graphcut_map_size(2), num_obj + 1);
        foreground_idx = idx_all_pixel(D_train.label_first == i_label);
        background_idx = idx_all_pixel(D_train.label_first ~= i_label);
        
        for i_obj = 1:num_obj
            
            map_obj = map_obj_all(:, :, i_obj);
            
            % now move the clique and only record the cost for the current
            % site
            for off_x = -P.bblock_graphcut_obj_size(1):P.bblock_graphcut_obj_size(1)
                for off_y = -P.bblock_graphcut_obj_size(2):P.bblock_graphcut_obj_size(2)
                    loc_x = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)}(1, :) + off_x + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
                    loc_y = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)}(2, :) + off_y + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
                    loc_x_current = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)}(1, i_obj) + off_x + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
                    loc_y_current = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)}(2, i_obj) + off_y + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
                    
                    % test if the shifting move any cell outside of the image
                    % boundary
                    mask = loc_x > 0 & loc_x <= D_train.graphcut_map_size(2) & loc_y > 0 & loc_y <= D_train.graphcut_map_size(1);
                    mask_current = loc_x_current > 0 & loc_x_current <= D_train.graphcut_map_size(2) & loc_y_current > 0 & loc_y_current <= D_train.graphcut_map_size(1);
                    if sum(mask) < size(mask, 2)
                        if mask_current > 0
                            % give very high penalty to this shift
                            map_obj(loc_y_current, loc_x_current) = P.bblock_graphcut_p_outside;
                        else
                            % do nothing
                        end
                        
                    else
                        %                             % all cells are inside of the image boundary. In this
                        %                             % case we calculate the hog distance to the mean
                        loc_valid = [loc_x; loc_y];
                        idx_valid = sub2ind([D_train.graphcut_map_size(1), D_train.graphcut_map_size(2)], loc_valid(2, :), loc_valid(1, :));
                        hog_valid = D_train.hog_cell(:, idx_valid);
                        hog_mean = mean(hog_valid, 2);
                        M_cell = dist2(hog_valid', hog_mean');
                        map_obj(loc_y_current, loc_x_current) = round(mean(M_cell) * P.bblock_graphcut_p_scaler);
                    end
                end
            end
            
            
            map_obj(background_idx) = P.bblock_graphcut_p_wrong_label;
            map_obj_all(:, :, i_obj) = map_obj;
        end
        for i_obj = num_obj + 1:num_obj + 1
            map_obj = map_obj_all(:, :, i_obj);
            map_obj(background_idx) = P.bblock_graphcut_P_correct_label;
            map_obj(foreground_idx) = P.bblock_graphcut_p_ini;
            map_obj_all(:, :, i_obj) = map_obj;
        end
        
        % now, build a graph
        num_pixel = size(map_obj_all, 1) * size(map_obj_all, 2);
        num_obj_label = size(map_obj_all, 3);
        cost_unary = zeros(num_obj_label, num_pixel);
        cost_smooth = zeros(num_obj_label, num_obj_label);
        
        h = GCO_Create(num_pixel, num_obj_label);   % Create new object
        
        for i_obj_label = 1:num_obj_label
            cost_unary(i_obj_label, :) = reshape(map_obj_all(:, :, i_obj_label), 1, []);
        end
        
        for i_obj_label = 1:num_obj_label
            for j_obj_label = 1:num_obj_label
                if i_obj_label ~= j_obj_label
                    cost_smooth(i_obj_label, j_obj_label) = 5;
                end
            end
        end
        
        GCO_SetDataCost(h, int32(cost_unary));
        
        GCO_SetSmoothCost(h, int32(cost_smooth));
        
        GCO_SetNeighbors(h, D_train.weight_neighbors);
        
        [E1 D1 S1] = GCO_ComputeEnergy(h);
        GCO_Expansion(h, P.bblock_graphcut_num_iter);
        [E2 D2 S2] = GCO_ComputeEnergy(h);
        obj_label = GCO_GetLabeling(h);
        
        % use the average bounding box instead of enforcing the exactly same
        % shape. This avoids fragment shapes -- as the number of site increase
        % there is very high probability that only a few cells are shared across
        % all sites, hence the fragment happens
        
        % compute the average offset for the sites
        idx_all = [1:size(obj_label, 1)];
        off_set = zeros(4, num_obj);
        %         loc_site = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)};
        loc_site = D_train.rep_site_loc{1, D_train.hypothesis_cen(1, i_label)} + (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense));
        for i_obj = 1:num_obj
            mask = obj_label == i_obj;
            if sum(mask) > 0
                add_color = (rand(1, 3) - 0.5)/5;
                [row_obj, col_obj] = ind2sub(size(map_obj), idx_all(mask));
                off_set(:, i_obj) = [min(col_obj) - loc_site(1, i_obj); max(col_obj) - loc_site(1, i_obj); min(row_obj) - loc_site(2, i_obj); max(row_obj) - loc_site(2, i_obj)];
                im_red(idx_all(mask)) = P.label_list(i_label, 1) + add_color(1);
                im_green(idx_all(mask)) = P.label_list(i_label, 2) + add_color(2);
                im_blue(idx_all(mask)) = P.label_list(i_label, 3) + add_color(3);
            else
                off_set(:, i_obj) = 0;
            end
        end
        
        ave_off_set = ceil(mean(off_set, 2));
        D_train.bb{1, i_label} = (loc_site + repmat([ave_off_set(1); ave_off_set(3)], 1, num_obj)) * P.pre_sample_step_dense;
        %         D_train.bb{1, i_label} = (loc_site +  (P.pre_hog_patch_size * P.pre_hog_cell_size/(2 * P.pre_sample_step_dense)) - 1 + repmat([ave_off_set(1); ave_off_set(3)], 1, num_obj)) * P.pre_sample_step_dense;
        D_train.bb_w(1, i_label) = max(1, (ave_off_set(2) - ave_off_set(1) + 1)) * P.pre_sample_step_dense;
        D_train.bb_h(1, i_label) = max(1, (ave_off_set(4) - ave_off_set(3) + 1)) * P.pre_sample_step_dense;
    else
        ;
    end
end

mask = ones(1, size(D_train.bb, 2));
for i = 1:size(D_train.bb, 2)
    if isempty(D_train.bb{1, i})
        mask(1, i) = 0;
    end
end

mask = logical(mask);
D_train.bb = D_train.bb(1, mask);
D_train.bb_w = D_train.bb_w(1, mask);
D_train.bb_h = D_train.bb_h(1, mask);

im_seg = cat(3, im_red, im_green, im_blue);
if P.gm_flag == 1
    mkdir([P.output_path 'gmbb\']);
    parsave_cut([P.output_path 'gmbb\' D_train.img_name '_gmbb' '_rob_' num2str(P.i_rob) '.mat'], D_train);
else if P.bblock_nodl_flag == 1
        mkdir([P.output_path 'nodlbb\']);
        parsave_cut([P.output_path 'nodlbb\' D_train.img_name '_nodlbb' '_rob_' num2str(P.i_rob)  '.mat'], D_train);
    else
        mkdir([P.output_path 'bb\']);
        parsave_cut([P.output_path 'bb\' D_train.img_name '_bb' '_rob_' num2str(P.i_rob)  '.mat'], D_train);
    end
end

% parsave_cut([P.output_path D_train.img_name '_gmbb' '_rob_' num2str(P.i_rob) '.mat'], D_train);
% imwrite(imresize(im_seg, 4, 'nearest'), [D_train.img_name 'graphcut_2_rob_' num2str(P.i_rob)  '.png']);



% h = figure;
% set(h, 'Color',[1, 2, 255]/255);
% imshow(im_train);
% hold on;
% for i_rep = 1:size(D_train.bb, 2)
%     for i = 1:size(D_train.bb{1, i_rep}, 2)
%         box = repmat(D_train.bb{1, i_rep}(1:2, i), 1, 4) + [0, D_train.bb_w(1, i_rep), D_train.bb_w(1, i_rep), 0; 0, 0, D_train.bb_h(1, i_rep), D_train.bb_h(1, i_rep)];
%         plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', 'k', 'LineWidth', 3);
%         plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', P.label_list(i_rep, :), 'LineWidth', 1);
%     end
% end
% F = im2frame(zbuffer_cdata(h));
% [x, y] = ind2sub([size(F.cdata,1) size(F.cdata,2)], find(F.cdata(:, :, 1) ~= 1 & F.cdata(:, :, 2) ~= 2 & F.cdata(:, :, 3) ~= 255));
% imwrite(F.cdata(min(x):max(x),min(y):max(y),:),  [name '_test2.png']);
% hold off;
% clf;
% close;



