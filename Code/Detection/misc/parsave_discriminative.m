function parsave_discriminative(fname, D_train)
D_train.hog_dense = [];
D_train.loc_dense = [];
D_train.num_patch_dense = [];
D_train.hog_key = [];
D_train.loc_key = [];
D_train.num_patch_key = [];
D_train.x_range = [];
D_train.y_range = [];
D_train.hog_cell_map = [];
% D_train.occ = [];
% D_train.rep_binary = [];
% D_train.rep_site_loc = [];
% D_train.rep_pixel_loc = [];
% D_train.rep_site_num = [];
save(fname, 'D_train');
end