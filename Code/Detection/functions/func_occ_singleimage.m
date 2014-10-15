% build per-cluster occ maps by firing the svm back to the image
function D_train = func_occ_singleimage(D_buffer, D_train, P, f_render)

% some temporary data to make momery efficient for parfor
temp_D_buffer.hog_key_mean = D_buffer.hog_key_mean;
temp_D_buffer.hog_key_mean_NN = D_buffer.hog_key_mean_NN;
temp_D_buffer.hog_key_mean_KNN = D_buffer.hog_key_mean_KNN;
temp_D_buffer.detector = D_buffer.detector;
temp_D_buffer.cluster = D_buffer.cluster;

randomsample = rand(1, size(D_train.hog_dense, 2))';

% some temporary data to make momery efficient for parfor
temp_D_hog_dense_train.hog_dense = D_train.hog_dense';

% for i = 1:P.num_img_train
if P.discriminative_detection_mode == 1
    %         M_simi_hog = exp(-dist2(temp_D_hog_dense_train.hog_dense, temp_D_buffer.hog_key_mean')/P.exp_ratio);
else if P.discriminative_detection_mode == 2
        temp_dist = dist2(temp_D_hog_dense_train.hog_dense, temp_D_buffer.hog_key_mean_NN');
        M_simi_hog = exp(-temp_dist/P.discriminative_rms_exp_ratio);
    else if P.discriminative_detection_mode == 3
            %                 M_simi_hog = exp(-dist2(temp_D_hog_dense_train.hog_dense, temp_D_buffer.hog_key_mean_KNN')/P.exp_ratio);
        else if P.discriminative_detection_mode == 4
                %                     M_simi_hog = zeros(size(temp_D_hog_dense_train.hog_dense, 1), size(temp_D_buffer.cluster, 2));
                %                     for i_bb = 1:size(M_simi_hog, 2)
                %                         [predicted_label1, accuracy, M_simi_hog(:, i_bb)] = predict(randomsample, sparse(temp_D_hog_dense_train.hog_dense), temp_D_buffer.detector{1, i_bb}, '-q');
                %                     end
                %                     % for svm we need to scale the score a bit
                %                     M_simi_hog = M_simi_hog/max([1, (max(max(M_simi_hog)))]);
            else if P.discriminative_detection_mode== 5
                    M_simi_hog = zeros(size(temp_D_hog_dense_train.hog_dense, 1), size(temp_D_buffer.cluster, 2));
                    
                    %% final note: parfor safe
                    for i_bb = 1:size(M_simi_hog, 2)
                        scaler = size(temp_D_buffer.hog_key_mean, 1)/sum(abs(temp_D_buffer.detector{1, i_bb}.w));
                        % use some temporary data to speed up
                        temp = temp_D_hog_dense_train.hog_dense;
                        temp_w = temp_D_buffer.detector{1, i_bb}.w;
                        for i = 1:size(temp, 2)
                            temp(:, i) = temp(:, i) * temp_w(1, i);
                        end
                        % use NN to attract the meanshifting
                        temp_2 = temp_D_buffer.hog_key_mean_NN(:, i_bb)'.*temp_w;
                        
                        %                             % use KNN to attract the meanshifting
                        %                             temp_2 = temp_D_buffer.hog_key_mean_KNN(:, i_bb)'.*temp_w;
                        
                        %                             % use mean to attract the meanshifting
                        %                             temp_2 = temp_D_buffer.hog_key_mean(:, i_bb)'.*temp_w;
                        
                        temp_dist = dist2(temp, temp_2);
                        M_simi_hog(:, i_bb)= exp(-(temp_dist * scaler)/P.discriminative_svm_exp_ratio);
                    end
                else
                    ;
                end
            end
        end
    end
end

occ = zeros(size([1:P.pre_sample_step_dense:(D_train.y_range(2) - D_train.y_range(1) + 1)], 2), size([1:P.pre_sample_step_dense:(D_train.x_range(2) - D_train.x_range(1) + 1)], 2), D_buffer.nbCluster);

for ii = 1:D_buffer.nbCluster
    occ(:, :, ii) = reshape(M_simi_hog(:, ii), size([1:P.pre_sample_step_dense:(D_train.y_range(2) - D_train.y_range(1) + 1)], 2), size([1:P.pre_sample_step_dense:(D_train.x_range(2) - D_train.x_range(1) + 1)], 2));
end

D_train.occ = occ;

if f_render == 1
    %     im_cut = D_train.im(D_train.y_range(1):D_train.y_range(2), D_train.x_range(1):D_train.x_range(2), :);
    %     A = 0 * im_cut;
    %     for i_bb = 1:size(D_buffer.cluster, 2)
    %         A(:, :, 1) = imresize(D_train.occ(:, :, i_bb), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
    %         A(:, :, 2) = imresize(D_train.occ(:, :, i_bb), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
    %         A(:, :, 3) = imresize(D_train.occ(:, :, i_bb), [size(im_cut, 1), size(im_cut, 2)], 'nearest');
    %         imwrite([A], [P.output_path D_train.img_name '_rob_' num2str(P.i_robustness) '_disc_' num2str(P.i_discriminative) '_occ_' num2str(i_bb)  '.png']);
    %     end
end

end