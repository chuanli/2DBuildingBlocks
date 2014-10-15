% robust evaluation for individual repetitions

function Detect = func_robust_clean_singleimage(D_train, P)

Detect = [];

if P.robustness_clean == 1
    count_remove_singular = 0;
    count_remove_tiny = 0;
    count_remove_homo = 0;
    count_remove_background = 0;
    count_remove_overlap = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove the singular building blocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mask = logical(ones(1, size(D_train.bb, 2)));
    for i_rep = 1:size(D_train.bb, 2)
        if size(D_train.bb{1, i_rep}, 2) < P.robustness_min_rep_size
            mask(1, i_rep) = 0;
            count_remove_singular = count_remove_singular + size(D_train.bb{1, i_rep}, 2);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove building blocks that are too small
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i_rep = 1:size(D_train.bb, 2)
        if (D_train.bb_w(1, i_rep) < P.robustness_min_block_size || D_train.bb_h(1, i_rep) < P.robustness_min_block_size) & mask(1, i_rep) == 1
            mask(1, i_rep) = 0;
            count_remove_tiny = count_remove_tiny + size(D_train.bb{1, i_rep}, 2);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove the building blocks that have homogeneous color
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i_rep = 1:size(D_train.bb, 2)
        if ~isempty(D_train.bb{1, i_rep})
            acc_c = 0;
            for i_obj = 1:size(D_train.bb{1, i_rep}, 2)
                x_start = D_train.bb{1, i_rep}(1, i_obj);
                y_start = D_train.bb{1, i_rep}(2, i_obj);
                x_end = min(size(D_train.im, 2), x_start + D_train.bb_w(1, i_rep));
                y_end = min(size(D_train.im, 1), y_start + D_train.bb_h(1, i_rep));
                patch = D_train.im(y_start:y_end, x_start:x_end, :);
                mean_c = mean(mean(patch));
                var_c = (mean(mean(abs(patch(:, :, 1) - mean_c(1)))) + mean(mean(abs(patch(:, :, 2) - mean_c(2)))) + mean(mean(abs(patch(:, :, 3) - mean_c(3)))))/3;
                acc_c = acc_c + var_c;
            end
            acc_c = acc_c/size(D_train.bb{1, i_rep}, 2);
            if acc_c < P.robustness_min_color_var & mask(1, i_rep) == 1
                mask(1, i_rep) = 0;
                count_remove_homo = count_remove_homo + size(D_train.bb{1, i_rep}, 2);
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove background
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    se = strel('square', 2 * P.robustness_bgtest_se_dilation + 1);
    for i_rep = 1:size(D_train.bb, 2)
        if ~isempty(D_train.bb{1, i_rep})
            if size(D_train.bb{1, i_rep}, 2) >= P.robustness_bgtest_obj_num % only consider repetition that have enough number of objests
                % make a co-occurrence map within this type of building
                % blocks
                % first try discrete form
                im_site = zeros(size(D_train.im, 1), size(D_train.im, 2));
                idx = sub2ind(size(im_site), D_train.bb{1, i_rep}(2, :), D_train.bb{1, i_rep}(1, :));
                im_site(idx) = 1;
                im_site = imdilate(im_site, se, 'same');
                
                map_w = 2 * (D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding) + 1;
                map_h = 2 * (D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding) + 1;
                map = zeros(map_h, map_w);
                
                % collect date from each site
                for i_obj = 1:size(D_train.bb{1, i_rep}, 2)
                    cen_x = D_train.bb{1, i_rep}(1, i_obj);
                    cen_y = D_train.bb{1, i_rep}(2, i_obj);
                    go_left = min(D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding, cen_x - 1);
                    go_right = min(D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding, size(im_site, 2) - cen_x);
                    go_up = min(D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding, cen_y - 1);
                    go_down = min(D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding, size(im_site, 1) - cen_y);
                    map(D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 - go_up:D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 + go_down, ...
                        D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 - go_left:D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 + go_right) = map(D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 - go_up:D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 + go_down, ...
                        D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 - go_left:D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 + go_right) + im_site(cen_y - go_up:cen_y + go_down, cen_x - go_left:cen_x + go_right);
                end
                
                map(D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 - P.robustness_bgtest_se_dilation :D_train.bb_h(1, i_rep) + P.robustness_bgtest_padding + 1 + P.robustness_bgtest_se_dilation , ...
                    D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 - P.robustness_bgtest_se_dilation :D_train.bb_w(1, i_rep) + P.robustness_bgtest_padding + 1 + P.robustness_bgtest_se_dilation ) = 0;
                row_map = sum(map)';
                row_col = sum(map, 2);
                
                gini_row = gini(ones(size(row_map, 1),1), row_map);
                gini_col = gini(ones(size(row_col, 1),1), row_col);
                
%                 figure;
%                 imshow(map/max(max(map)));
%                 gini_row
%                 gini_col
                
                if (gini_row < P.robustness_bgtest_gini || gini_col < P.robustness_bgtest_gini) & mask(1, i_rep) == 1
                    mask(1, i_rep) = 0;
                    count_remove_background = count_remove_background + size(D_train.bb{1, i_rep}, 2);
                end
            end
        end
    end
    
    D_train.bb = D_train.bb(1, mask);
    D_train.bb_w = D_train.bb_w(1, mask);
    D_train.bb_h = D_train.bb_h(1, mask);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove objects that are overlapped
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mask_rep = logical(ones(1, size(D_train.bb, 2)));
    for i_rep = 1:size(D_train.bb, 2)
        M_adj = zeros(size(D_train.bb{1, i_rep}, 2), size(D_train.bb{1, i_rep}, 2));
        
        % computing the ratio of overlaping between to objects
        area_total = D_train.bb_w(1, i_rep) * D_train.bb_h(1, i_rep);
        patch = cell(1, size(M_adj, 1));
        
        for i = 1:size(M_adj, 1)
            x_start = D_train.bb{1, i_rep}(1, i);
            y_start = D_train.bb{1, i_rep}(2, i);
            x_end = min(size(D_train.im, 2), x_start + D_train.bb_w(1, i_rep));
            y_end = min(size(D_train.im, 1), y_start + D_train.bb_h(1, i_rep));
            patch{1, i} = D_train.im(y_start:y_end, x_start:x_end, :);
            
            for j = i + 1:size(M_adj, 2)
                
                x_max = max(D_train.bb{1, i_rep}(1, i) + D_train.bb_w(1, i_rep), D_train.bb{1, i_rep}(1, j) + D_train.bb_w(1, i_rep));
                x_min = min(D_train.bb{1, i_rep}(1, i), D_train.bb{1, i_rep}(1, j));
                y_max = max(D_train.bb{1, i_rep}(2, i) + D_train.bb_h(1, i_rep), D_train.bb{1, i_rep}(2, j) + D_train.bb_h(1, i_rep));
                y_min = min(D_train.bb{1, i_rep}(2, i), D_train.bb{1, i_rep}(2, j));
                sum_w = D_train.bb_w(1, i_rep) * 2;
                sum_h = D_train.bb_h(1, i_rep) * 2;
                
                if sum_w > x_max - x_min + 1
                    overlap_w = sum_w - (x_max - x_min + 1);
                else
                    overlap_w = 0;
                end
                if sum_h > y_max - y_min + 1
                    overlap_h = sum_h - (y_max - y_min + 1);
                else
                    overlap_h = 0;
                end
                
                M_adj(i, j) = (overlap_w * overlap_h)/area_total;
                M_adj(j, i) =  M_adj(i, j);
            end
        end
        % %
        % %         % for pairs that have overlap ratio that is larger than a threshold
        
        mask_obj = logical(ones(1, size(M_adj, 1)));
        while max(max(M_adj)) > P.robustness_max_overlap
            % %             % find the row, col index of the max value
            [maxc, maxi] = max(M_adj(:));
            [max_row, max_col] = ind2sub(size(M_adj), maxi);
            
            % recalculate the mean_patch
            mean_patch = 0 * patch{1, 1};
            for i = 1:size(mask_obj, 2)
                if mask_obj(1, i) > 0
                    try
                        mean_patch = mean_patch + patch{1, i};
                    catch
                    end
                end
            end
            mean_patch = mean_patch/sum(mask_obj);
            
            %             % choose one from max_row and max_col to remove
            try
                [maxc, maxi] = max([sum(sum(sum(abs(mean_patch - patch{1, max_row})))), sum(sum(sum(abs(mean_patch - patch{1, max_col}))))]);
            catch
                if size(patch{1, max_row}, 1) * size(patch{1, max_row}, 2) > size(patch{1, max_col}, 1) * size(patch{1, max_col}, 2)
                    maxi = 2;
                else
                    maxi = 1;
                end
            end
            if maxi == 1
                % remove max_row
                mask_obj(1, max_row) = 0;
                M_adj(max_row, :) = 0;
            else
                % remove max_col
                mask_obj(1, max_col) = 0;
                M_adj(:, max_col) = 0;
            end
            
        end
        
        
        if sum(mask_obj) < 2
            % the repetition degenerates to a singular object
            mask_rep(1, i_rep) = 0;
            count_remove_overlap = count_remove_overlap + size(mask_obj, 2);
        else
            D_train.bb{1, i_rep} = D_train.bb{1, i_rep}(:, mask_obj);
            count_remove_overlap = count_remove_overlap + size(mask_obj, 2) - sum(mask_obj);
        end
        
    end
    D_train.bb = D_train.bb(1, mask_rep);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convet to "Detect" data structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Detect.rep = cell(1, size(D_train.bb, 2));
Detect.rep_size = zeros(1, size(D_train.bb, 2));
count = 1;
for i_rep = 1:size(D_train.bb, 2)
    Detect.rep{1, count} = [D_train.bb{1, i_rep}; ...
        ones(1, size(D_train.bb{1, i_rep}, 2)) * (D_train.bb_w(1, i_rep) - 1); ...
        ones(1, size(D_train.bb{1, i_rep}, 2)) * (D_train.bb_h(1, i_rep) - 1)];
    Detect.rep_size(1, count) = size(D_train.bb{1, i_rep}, 2);
    count = count + 1;
end
mkdir([P.output_path 'rob']);
save([P.output_path 'rob\'  D_train.img_name '_bfmg' '_rob_' num2str(P.i_rob) '.mat'], 'Detect');

% h = figure;
% set(h, 'Color',[1, 2, 255]/255);
% imshow(D_train.im);
% hold on;
% for i_rep = 1:size(Detect.rep, 2)
%     for i = 1:size(Detect.rep{1, i_rep}, 2)
%         box = repmat(Detect.rep{1, i_rep}(1:2, i), 1, 4) + [0, Detect.rep{1, i_rep}(3, i), Detect.rep{1, i_rep}(3, i), 0; 0, 0, Detect.rep{1, i_rep}(4, i), Detect.rep{1, i_rep}(4, i)];
%         plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', P.label_list(i_rep, :), 'LineWidth', 2);
%     end
% end
% 
% axis off;
% F = im2frame(zbuffer_cdata(h));
% [x, y] = ind2sub([size(F.cdata,1) size(F.cdata,2)], find(F.cdata(:, :, 1) ~= 1 & F.cdata(:, :, 2) ~= 2 & F.cdata(:, :, 3) ~= 255));
% imwrite(F.cdata(min(x):max(x),min(y):max(y),:),  [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_stage_' num2str(P.robustness_input_mode) '_before_merge.png']);
% hold off;
% clf;
% close;



