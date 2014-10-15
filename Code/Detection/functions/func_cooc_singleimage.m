% Use occurrence between different detectors to get robust repetition
% hypothesis

function D_train = func_cooc_singleimage(D_train, P)

dim_mds = P.bblock_dim_mds;
num_iter_MS = P.bblock_num_iter_MS;
% MS_bandwidth = P.bblock_bandwidth_MS;
% MS_bandwidth = max(P.bblock_bandwidth_MS, 1- P.i_qlt/P.qlt_number);
% MS_bandwidth = max(P.bblock_bandwidth_MS, 1- P.i_qlt/P.qlt_number);
MS_bandwidth = P.bblock_bandwidth_MS;
D_train.hypothesis = [];
D_train.hypothesis_size = [];
D_train.hypothesis_cen = [];

% find the occ that are valid, basic, we choose any occ that has result
% in a certain number of postive detections
mask = sum(sum(D_train.rep_binary)) >= P.bblock_min_sample;
mask = reshape(mask, 1, []);

if sum(mask) > 0
    idx_valid = [1:size(D_train.rep_binary, 3)];
    idx_valid = idx_valid(1, logical(mask));
    occ_valid = D_train.occ(:, :, idx_valid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate MNNC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    M_similarity_NXCORR2 = zeros(size(occ_valid, 3), size(occ_valid, 3));
    M_list = cell(1, size(occ_valid, 3));
    
    for ii = 1:size(occ_valid, 3)
        for jj = ii:size(occ_valid, 3)
            M_temp = normxcorr2_general_CL(occ_valid(:, :, ii), occ_valid(:, :, jj), P.bblock_MNCC_shift_bd);
            [cmax, imax] = max((M_temp(:)));
            M_list{1, ii}(1, jj - ii + 1) = max(M_temp(:));
        end
    end
    
    for ii = 1:size(occ_valid, 3)
        M_similarity_NXCORR2(ii, ii:end) = M_list{1, ii};
        M_similarity_NXCORR2(ii:end, ii) = M_list{1, ii}';
    end
    M_similarity_NXCORR2(logical(eye(size(M_similarity_NXCORR2)))) = 1;
    M_similarity_NXCORR2(M_similarity_NXCORR2 >=1 ) = 1;
    D_train.M_similarity_NXCORR2 = M_similarity_NXCORR2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MDS embedding
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [feat_mds, e] = cmdscale(M_similarity_NXCORR2);
    dim_mds_img = min(size(feat_mds, 2), dim_mds);
    
    if dim_mds_img > 1
        feat_mds = feat_mds(:, 1:dim_mds_img)';
        D_train.feat_mds = feat_mds;
        rng('shuffle');
        [clustCent, point2cluster, clustMembsCell] = MeanShiftCluster(feat_mds, MS_bandwidth);
        
        % print out the distance from point to center
        
        mask = ones(1, size(clustMembsCell, 2));
        D_train.hypothesis = clustMembsCell';
        for i = 1:size(D_train.hypothesis, 2)
            mask(1, i) = ~isempty(D_train.hypothesis{1, i});
        end
        D_train.hypothesis = D_train.hypothesis(1, logical(mask));
        D_train.hypothesis_size = zeros(1, size(D_train.hypothesis, 2));
        for i = 1:size(D_train.hypothesis, 2)
            D_train.hypothesis_size(1, i) = size(D_train.hypothesis{1, i}, 2);
        end
        
        % for each hypothesis find its center
        for i = 1:size(D_train.hypothesis, 2)
            [cmax, iimax] = max(sum(M_similarity_NXCORR2(D_train.hypothesis{1, i}, D_train.hypothesis{1, i})));
            D_train.hypothesis_cen(1, i) = D_train.hypothesis{1, i}(1, iimax);
        end
        
        for i = 1:size(D_train.hypothesis, 2)
            D_train.hypothesis{1, i} = idx_valid(D_train.hypothesis{1, i});
            D_train.hypothesis_cen(1, i) = idx_valid(D_train.hypothesis_cen(1, i));
        end
        
    else
        D_train.hypothesis = idx_valid;
        D_train.hypothesis_cen = idx_valid;
        D_train.hypothesis_size = 1;
    end
else
    ;
end


