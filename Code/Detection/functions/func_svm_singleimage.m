% train supporter vector machine 

function D_buffer = func_svm_singleimage(D_buffer)

idx_all = [1:size(D_buffer.hog_key, 2)];

num_bb = size(D_buffer.cluster, 2);

% some temporary data to make momery efficient for parfor
temp_D_buffer.cluster = D_buffer.cluster;
temp_D_buffer.hog_key = D_buffer.hog_key;
detector = cell(1, num_bb);

%% final note: parfor safe
for i_bb = 1:num_bb
    list_positive = temp_D_buffer.cluster{1, i_bb};
    list_negative = setdiff(idx_all, list_positive);
    hog_SVM = temp_D_buffer.hog_key(:, [list_positive list_negative])';
    label_SVM = [ones(1, size(list_positive, 2)), -ones(1, size(list_negative, 2))]';
    detector{1, i_bb} = train(label_SVM, sparse(hog_SVM), '-c 1 -q');
end

for i_bb = 1:num_bb
    D_buffer.detector{1, i_bb} = detector{1, i_bb};
end

clear temp_D_buffer detector