% build per-cluster occ maps
function D_train = func_rep_singleimage(D_train, P, f_render)
% some temporary data to make momery efficient for parfor
temp_D_train.occ = D_train.occ;
temp_D_train.rep_binary = temp_D_train.occ * 0;

%% final note: parfor safe
for i = 1:size(temp_D_train.rep_binary, 3)
    filt = (fspecial('gaussian', 3, 1));
    p_cen = FastPeakFindPadding_CLOrder(temp_D_train.occ(:, :, i), filt, [P.discriminative_peak_bd , P.discriminative_peak_bd ]);
    if ~isempty(p_cen)
        p_idx = sub2ind([size(temp_D_train.rep_binary, 1), size(temp_D_train.rep_binary, 2)], p_cen(2, :), p_cen(1, :)) + size(temp_D_train.rep_binary, 1) * size(temp_D_train.rep_binary, 2) * (i - 1);
        temp_D_train.rep_binary(p_idx) = 1;
        temp_D_train.rep_binary(:, :, i) = temp_D_train.rep_binary(:, :, i) .* (temp_D_train.occ(:, :, i) > P.discriminative_occ2rep);
    end
end

D_train.rep_binary = temp_D_train.rep_binary;

if f_render == 1
    im_cut = D_train.im(D_train.y_range(1):D_train.y_range(2), D_train.x_range(1):D_train.x_range(2), :);
    A = 0 * im_cut;
    for i = 1:size(D_train.rep_binary, 3)
        A(:, :, 1) = imresize(D_train.rep_binary(:, :, i), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
        A(:, :, 2) = imresize(D_train.rep_binary(:, :, i), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
        A(:, :, 3) = imresize(D_train.rep_binary(:, :, i), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
        imwrite([im_cut A], [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_rep_' num2str(i) '.png']);
    end
end

    