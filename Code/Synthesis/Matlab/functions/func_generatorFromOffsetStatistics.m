function generators = func_generatorFromOffsetStatistics(im, para)

generators = [];
generators_pro = [];

w = para.w;
h = para.h;
thresh_nn = para.thresh_nn;
thresh_nn_far = para.thresh_nn_far;
thresh_peak_pro = para.thresh_peak_pro;
thresh_peak_max_num = para.thresh_peak_max_num;
gs_sigma = para.gs_sigma;
gs_w = para.gs_w;

% shift list (Statistics)
% sample image patches
num_rows = size(im, 1) - h + 1;
num_cols = size(im, 2) - w + 1;
num_patches = num_rows * num_cols;
patches_pixel = zeros(num_patches, h * w);
patches_loc = zeros(num_patches, 2); % [x, y]
for i = 1:num_cols
    for j = 1:num_rows
        idx = (i - 1) * num_rows + j;
        patches_pixel(idx, :) = reshape(im(j:j + h -1, i:i + w - 1), 1, []);
        patches_loc(idx, :) = [i, j];
    end
end
tic
M_pixel = pdist2(patches_pixel, patches_pixel);
M_loc = pdist2(patches_loc, patches_loc);
toc

% detect statistics peaks
% first, preclude pairs that are too close (32 pixel as suggested in the paper)
mask_nn = M_loc <= thresh_nn;
mask_nn_far = M_loc >= thresh_nn_far;
M_pixel(mask_nn) = inf;
M_pixel(mask_nn_far) = inf;
[minc, match] = min(M_pixel,  [], 2);
% format match to offset
match_offset = zeros(2, size(match, 1));
[row_source, col_source] = ind2sub([num_rows, num_cols], [1:size(match, 1)]);
[row_target, col_target] = ind2sub([num_rows, num_cols], match');
match_offset = [col_target - col_source; row_target - row_source];

% generate a smoothed probability maps
map_pro = zeros(2 * num_rows + 1, 2 * num_cols + 1);
match_offset_central = match_offset + repmat([num_cols; num_rows], 1, size(match_offset, 2));
match_central = sub2ind(size(map_pro), match_offset_central(2, :), match_offset_central(1, :));
for i = 1:size(match_central, 2)
    map_pro(match_central(i)) = map_pro(match_central(i)) + 1;
end

% gaussian smooth as suggested
ker = fspecial('gaussian', gs_w, gs_sigma);
map_pro = imfilter(map_pro, ker, 'circular', 'same');

map_pro = map_pro/(max(max(map_pro)) + 0.001);

% run peak detection
p_cen = FastPeakFindPadding_CLOrder(map_pro, [h, w]); % acturally it is 2*(3 - 1) + 1 for checking local peaks

if isempty(p_cen)
    % set a regular sampler
    generators = [generators [para.defalt_mag; 0] [0; para.defalt_mag]];
    generators_pro = [0.0, 0.0];
    return;
end


p_idx = sub2ind(size(map_pro), p_cen(2, :), p_cen(1, :));
mask = map_pro(p_idx) >= thresh_peak_pro;
p_cen = p_cen(:, mask);
p_cen = p_cen - repmat([num_cols; num_rows], 1, size(p_cen, 2));
p_idx = p_idx(:, mask);
p_pro = map_pro(p_idx(mask));

% compute two de-correlated generators
% select the strongest generator

if isempty(p_cen)
    % set a regular sampler
    generators = [generators [para.defalt_mag; 0] [0; para.defalt_mag]];
    generators_pro = [0, 0];
    return;
end


if ~isempty(p_cen)
    generators = [generators p_cen(:, 1)];
    generators_pro = [generators_pro p_pro(1, 1)];
    for i = 2:size(p_cen, 2)
        % see if p_cen(:, i) is decorrelatd with all existing generators
        flag_suc = 1;
        for j = 1:size(generators, 2)
            if abs(dot(generators(:, j), p_cen(:, i))/(norm(generators(:, j)) * norm(p_cen(:, i)))) > para.thresh_correlation
                flag_suc = 0;
                break;
            end
        end
        if flag_suc == 1
             generators = [generators p_cen(:, i)];
             generators_pro = [generators_pro p_pro(i)];
             break;
        end
    end
    
     if size(generators, 2) == 1
           % set a regular sampler in the normal direction
           v_p = [0, -1; 1, 0] * generators;
           v_p = para.defalt_mag * v_p/norm(v_p);
           generators = [generators v_p];
           generators_pro = [generators_pro 0];
     end
     
     % reorder generator if it is necessary
     if abs(generators(1, 1)) < abs(generators(2, 1))
         temp = generators(:, 1);
         generators(:, 1) = generators(:, 2);
         generators(:, 2) = temp;
         
         temp_pro = generators_pro(:, 1);
         generators_pro(:, 1) = generators_pro(:, 2);
         generators_pro(:, 2) = temp_pro;
     end
         
end 

[X, Y] = meshgrid([1:size(map_pro, 2)] - num_cols, [1:size(map_pro, 1)] - num_rows);

figure;
hold on;
surf(X, Y, map_pro);
plot3(generators(1, :), generators(2, :), generators_pro(1, :), 'y.', 'MarkerSize', 60, 'LineWidth', 10);
colormap (hsv);
view(3);
daspect([50, 50, 1]);


