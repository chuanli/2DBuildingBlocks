function A_rec_gray = func_rec_coherence_gray(A_rec_gray, A_num_rows, A_num_cols, h, w, B_patches, match_A2B,  match_B2A)

new_A_rec_gray = 0 * A_rec_gray;
new_A_rec_count = 0 * A_rec_gray;

for i = 1:size(match_A2B, 1)
    [A_row, A_col] = ind2sub([A_num_rows, A_num_cols], i);
    new_A_rec_gray(A_row:A_row + h - 1, A_col:A_col + w - 1) = new_A_rec_gray(A_row:A_row + h - 1, A_col:A_col + w - 1) + reshape(B_patches(match_A2B(i), :), h, w);
    new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) = new_A_rec_count(A_row:A_row + h - 1, A_col:A_col + w - 1) + 1;
end

A_rec_gray = new_A_rec_gray./new_A_rec_count;