% robust analysis: merge repetitions from different images

function Merge = func_robust_merge_singleimage(P, name, format)
Merge = [];
im_train = double(imread([P.name_path '\' P.name_dataset '\' P.name_data '\' name format]))/255;
rep = [];
rep_size = [];

% for i_robustness = 1:1   
for i_robustness = 1:P.robustness_num_iter
    %         if exist([P.output_path name '_rob_' num2str(i_robustness) '_stage_' num2str(P.robustness_input_mode) '_before_merge.mat'], 'file')
    if exist([P.output_path 'rob\' name '_bfmg' '_rob_' num2str(i_robustness) '.mat'], 'file')
        Data = load([P.output_path 'rob\' name '_bfmg' '_rob_' num2str(i_robustness) '.mat']);
        Detect = Data.Detect;
        rep = [rep Detect.rep];
        rep_size = [rep_size Detect.rep_size];
    else
        % do nothing
    end
end

compression = zeros(1, size(rep, 2));
robustness = zeros(1, size(rep, 2));

% for each image, evaulate the quality of each repetition based on the
% compression ratio and robustness
% compression ratio
if ~isempty(rep)
    for i_rep = 1:size(rep, 2)
        if ~isempty(rep{1, i_rep})
        pixel_overhead = rep{1, i_rep}(3, 1) * rep{1, i_rep}(4, 1);
        im_compression = zeros(size(im_train(:, :, 1)));
        for i_obj = 1:size(rep{1, i_rep}, 2)
            x_max = min(size(im_compression, 2), rep{1, i_rep}(1, i_obj) + rep{1, i_rep}(3, i_obj));
            x_min = max(1, rep{1, i_rep}(1, i_obj));
            y_max = min(size(im_compression, 1), rep{1, i_rep}(2, i_obj) + rep{1, i_rep}(4, i_obj));
            y_min = max(1, rep{1, i_rep}(2, i_obj));
            im_compression(y_min:y_max, x_min:x_max) = 1;
        end
        compression(1, i_rep) = max(0, sum(sum(im_compression)) - pixel_overhead)/(size(im_compression, 1) * size(im_compression, 2));
        %             figure;
        %             imshow(im_compression);
        else
            compression(1, i_rep) = 0;
        end
    end
    
    
    M_score = zeros(size(rep, 2), size(rep, 2));
    for i_rep = 1:size(rep, 2)
        if ~isempty(rep{1, i_rep})
            for j_rep = 1:size(rep, 2)
                if ~isempty(rep{1, j_rep})
                M_adj = zeros(size(rep{1, i_rep}, 2), size(rep{1, j_rep}, 2));
                for i = 1:size(M_adj, 1)
                    
                    x_max = rep{1, j_rep}(1, :) + rep{1, j_rep}(3, :);
                    x_max(x_max < rep{1, i_rep}(1, i) + rep{1, i_rep}(3, i)) = rep{1, i_rep}(1, i) + rep{1, i_rep}(3, i);
                    
                    x_min = rep{1, j_rep}(1, :);
                    x_min(x_min > rep{1, i_rep}(1, i)) = rep{1, i_rep}(1, i);
                    
                    y_max = rep{1, j_rep}(2, :) + rep{1, j_rep}(4, :);
                    y_max(y_max < rep{1, i_rep}(2, i) + rep{1, i_rep}(4, i)) = rep{1, i_rep}(2, i) + rep{1, i_rep}(4, i);
                    
                    y_min = rep{1, j_rep}(2, :);
                    y_min(y_min > rep{1, i_rep}(2, i)) = rep{1, i_rep}(2, i);
                    
                    sum_w = rep{1, i_rep}(3, 1) + rep{1, j_rep}(3, 1);
                    sum_h = rep{1, i_rep}(4, 1) + rep{1, j_rep}(4, 1);
                    
                    mask = sum_w > x_max - x_min + 1 & sum_h >= y_max - y_min + 1;
                    idx_a = [1:size(mask, 2)];
                    M_adj(i, idx_a(mask)) = 1;
                    
                end
                
                % M_score(i_rep, j_rep) = min(sum(sum(M_adj, 2) > 0), sum(sum(M_adj) > 0))/(size(rep{1, i_rep}, 2) + size(rep{1, j_rep}, 2));
                M_score(i_rep, j_rep) = min(sum(sum(M_adj, 2) > 0), sum(sum(M_adj) > 0))/max(size(rep{1, i_rep}, 2), size(rep{1, j_rep}, 2));
                else
                    M_score(i_rep, j_rep) = 0;
                end
            end
        else
            M_score(i_rep, :) = 0;
        end
    end
    
    
    for i_rep = 1:size(rep, 2)
        temp = sort(M_score(i_rep, :), 'descend');
        robustness(1, i_rep) = mean(temp(1, 1:min(P.robustness_num_iter, size(temp, 2))));
%         robustness(1, i_rep) = mean(temp(1, 1:min(10, size(temp, 2))));
    end
    
    % sort the repetitions by joint consideration of compression and robustness 
    % mode 1: compression times robustness
    % energy = compression.*robustness;
    
    % mode 2: compression only
%     energy = compression;


    % mode 3: robustness only
%     energy = robustness;

    % mode 4: compression plus robustness 
    energy = compression + robustness;    
%     energy = compression + robustness;    
    energy(2, :) = [1:size(robustness, 2)];
    energy = sortrows(energy', 1);
    
    rep_rank = energy(end:-1:1, 2)'; 
    % explain the image using ranked repetitions.

    im_cover = zeros(size(im_train(:, :, 1)));
    Merge = [];
    Merge.rep = [];
    Merge.rep_size = [];
    Merge.percentage = [];
%     for i_rep = 1:1
    for i_rep = 1:size(rep_rank, 2)
        if i_rep == 1
            
            for i_obj = 1:size(rep{1, rep_rank(1, i_rep)}, 2)
                x_max = min(size(im_cover, 2), rep{1, rep_rank(1, i_rep)}(1, i_obj) + rep{1, rep_rank(1, i_rep)}(3, i_obj));
                x_min = max(1, rep{1, rep_rank(1, i_rep)}(1, i_obj));
                y_max = min(size(im_cover, 1), rep{1, rep_rank(1, i_rep)}(2, i_obj) + rep{1, rep_rank(1, i_rep)}(4, i_obj));
                y_min = max(1, rep{1, rep_rank(1, i_rep)}(2, i_obj));
                im_cover(y_min:y_max, x_min:x_max) = 1;
            end
            Merge.rep = [Merge.rep rep(1, rep_rank(1, i_rep))];
            Merge.rep_size = [Merge.rep_size rep_size(1, rep_rank(1, i_rep))];
            Merge.percentage = [Merge.percentage sum(sum(im_cover))/(size(im_cover, 1) * size(im_cover, 2))];
        else
            if ~isempty(rep{1, rep_rank(1, i_rep)})
                im_add = zeros(size(im_train(:, :, 1)));
                
                for i_obj = 1:size(rep{1, rep_rank(1, i_rep)}, 2)
                    x_max = min(size(im_compression, 2), rep{1, rep_rank(1, i_rep)}(1, i_obj) + rep{1, rep_rank(1, i_rep)}(3, i_obj));
                    x_min = max(1, rep{1, rep_rank(1, i_rep)}(1, i_obj));
                    y_max = min(size(im_compression, 1), rep{1, rep_rank(1, i_rep)}(2, i_obj) + rep{1, rep_rank(1, i_rep)}(4, i_obj));
                    y_min = max(1, rep{1, rep_rank(1, i_rep)}(2, i_obj));
                    im_add(y_min:y_max, x_min:x_max) = 1;
                end
                
                if sum(sum(im_add == 1 & im_cover == 1))/sum(sum(im_add)) > P.robustness_max_overlap_add
                    % do nothing
                else
                    %                 sum(sum(im_add == 1 & im_cover == 1))/sum(sum(im_add))
                    % add this repetition into the Merge set
                    Merge.rep = [Merge.rep rep(1, rep_rank(1, i_rep))];
                    Merge.rep_size = [Merge.rep_size rep_size(1, rep_rank(1, i_rep))];
                    Merge.percentage = [Merge.percentage sum(sum(im_cover))/(size(im_cover, 1) * size(im_cover, 2))];
                    im_cover = im_cover | im_add;
                end
            end
        end
    end    
    parsavemerge([P.output_path 'rob\' name  '_afmg.mat'], Merge);
        
%     h = figure;
%     set(h, 'Color',[1, 2, 255]/255);
%     imshow(im_train);
%     hold on;
%     axis off;
%     for i_rep = 1:size(Merge.rep, 2)
%         for i = 1:size(Merge.rep{1, i_rep}, 2)
%             box = repmat(Merge.rep{1, i_rep}(1:2, i), 1, 4) + [0, Merge.rep{1, i_rep}(3, i), Merge.rep{1, i_rep}(3, i), 0; 0, 0, Merge.rep{1, i_rep}(4, i), Merge.rep{1, i_rep}(4, i)];
%             plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', P.label_list(i_rep, :), 'LineWidth', 2);
%         end
%         
%         F = im2frame(zbuffer_cdata(h));
%         [x, y] = ind2sub([size(F.cdata,1) size(F.cdata,2)], find(F.cdata(:, :, 1) ~= 1 & F.cdata(:, :, 2) ~= 2 & F.cdata(:, :, 3) ~= 255));
%     end
%     imwrite(F.cdata(min(x):max(x),min(y):max(y),:),  [P.output_path name '_afmg' '_qlt_' num2str(P.i_qlt) '.png']);
%     hold off;
%     clf;
%     close;    
else
    % no repetition has been found for this image
end




% save([P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_stage_' num2str(P.robustness_input_mode) '_before_merge.mat'], 'Detect');

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
% 


        