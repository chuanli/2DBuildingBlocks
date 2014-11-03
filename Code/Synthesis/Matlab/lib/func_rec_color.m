function A_rec_color = func_rec_color(A_rec_color, A_num_rows, A_num_cols, B_num_rows, B_num_cols, h, w, B_cur_color, match_A2B,  match_B2A)

new_A_rec_color = 0 * A_rec_color;
new_A_rec_count = 0 * A_rec_color(:, :, 1);

for i = 1:size(match_A2B, 1)
    [A_row, A_col] = ind2sub([A_num_rows, A_num_cols], i);
    [B_row, B_col] = ind2sub([B_num_rows, B_num_cols], match_A2B(i));
    new_A_rec_color(A_row:A_row + h - 1, A_col:A_col + w - 1, :) = new_A_rec_color(A_row:A_row + h - 1, A_col:A_col + w - 1, :) + B_cur_color(B_row:B_row + h - 1, B_col:B_col + w - 1, :);
    new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) = new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) + 1;
end

for i = 1:size(match_B2A, 1)
    [A_row, A_col] = ind2sub([A_num_rows, A_num_cols], match_B2A(i));
    [B_row, B_col] = ind2sub([B_num_rows, B_num_cols], i);
    new_A_rec_color(A_row:A_row + h - 1, A_col:A_col + w - 1, :) = new_A_rec_color(A_row:A_row + h - 1, A_col:A_col + w - 1, :) + B_cur_color(B_row:B_row + h - 1, B_col:B_col + w - 1, :);
    new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) = new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) + 1;
end

A_rec_color(:, :, 1) = new_A_rec_color(:, :, 1)./new_A_rec_count;
A_rec_color(:, :, 2) = new_A_rec_color(:, :, 2)./new_A_rec_count;
A_rec_color(:, :, 3) = new_A_rec_color(:, :, 3)./new_A_rec_count;