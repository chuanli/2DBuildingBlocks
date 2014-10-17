function list_shift = func_offsetstatistics(im, para)

w = para.w;
h = para.h;
thresh_nn = para.thresh_nn;
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
%
% detect statistics peaks
% first, preclude pairs that are too close (32 pixel as suggested in the paper)
mask_nn = M_loc <= thresh_nn;
M_pixel(mask_nn) = inf;
[minc, match] = min(M_pixel,  [], 2);
% format match to offset
match_offset = zeros(2, size(match, 1));
[row_source, col_source] = ind2sub([num_rows, num_cols], [1:size(match, 1)]);
[row_target, col_target] = ind2sub([num_rows, num_cols], match');
match_offset = [col_target - col_source; row_target - row_source];

%         figure;
%         hold on;
%         plot(match_offset(1, :), match_offset(2, :), 'bo');
%         axis equal;

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
map_pro = map_pro/max(max(map_pro));
%         map_pro = 100*map_pro/max(max(map_pro));
%         [X, Y] = meshgrid(1:size(map_pro, 2), 1:size(map_pro, 1));
%         figure;
%         surf(X, Y, map_pro);
%         axis equal;
%         colormap('hsv');

% run peak detection
p_cen = FastPeakFindPadding_CLOrder(map_pro, [h, w]); % acturally it is 2*(3 - 1) + 1 for checking local peaks
p_idx = sub2ind(size(map_pro), p_cen(2, :), p_cen(1, :));
mask = map_pro(p_idx) >= thresh_peak_pro;
p_cen = p_cen(:, mask);
p_idx = p_idx(:, mask);

% select the strongest thresh_peak_max_num peaks
if size(p_idx, 2) > thresh_peak_max_num
    temp = [map_pro(p_idx); [1:size(p_idx, 2)]];
    temp = sortrows(temp', 2);
    p_cen = p_cen(:, temp(1:thresh_peak_max_num, 2));
    p_idx = p_idx(:, temp(1:thresh_peak_max_num, 2));
end

[X, Y] = meshgrid(1:size(map_pro, 2), 1:size(map_pro, 1));
figure;
hold on;
surf(X, Y, map_pro);
plot3(p_cen(1, :), p_cen(2, :), map_pro(p_idx), 'o');
colormap('hsv');
view(3);

% figure;
% imshow(im);
% imwrite(im, 'temp.png');
% format peaks into shift
list_shift = p_cen - repmat([num_cols; num_rows], 1, size(p_cen, 2));

