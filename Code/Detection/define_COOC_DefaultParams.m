%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up default parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% system
P.num_Cores = 4;
P.scrsz = get(0,'ScreenSize');  
P.label_list = [102.0 / 255, 153.0 / 255, 255.0 / 255; ... 
                255.0 / 255, 204.0 / 255, 102.0 / 255; ... 
                102.0 / 255, 255.0 / 255, 127.0 / 255; ... 
                255.0 / 255, 127.0 / 255, 102.0 / 255; ...                 
                102.0 / 255, 230.0 / 255, 255.0 / 255; ... 
                41.0 / 255, 112.0 / 255, 255.0 / 255; ... 
                255.0 / 255, 184.0 / 255, 41.0 / 255; ... 
                235.0 / 255, 156.0 / 255, 0.0 / 255; ... 
                0.0 / 255, 78.0 / 255, 235.0 / 255; ...                
                255.0 / 255, 102.0 / 255, 230.0 / 255; ... 
                153.0 / 255, 255.0 / 255, 102.0 / 255; ... 
                127.0 / 255, 102.0 / 255, 255.0 / 255; ... 
                230.0 / 255, 255.0 / 255, 102.0 / 255; ... 
                102.0 / 255, 255.0 / 255, 204.0 / 255; ... 
                255.0 / 255, 102.0 / 255, 153.0 / 255; ... 
                204.0 / 255, 102.0 / 255, 255.0 / 255; ...
                200.0 / 255, 130.0 / 255, 130.0 / 255; ...
                0.0 / 255, 0.0 / 255, 0.0 / 255; ...
                50.0 / 255, 50.0 / 255, 50.0 / 255; ...
                100.0 / 255, 100.0 / 255, 100.0 / 255; ...
                150.0 / 255, 150.0 / 255, 150.0 / 255; ...
                200.0 / 255, 200.0 / 255, 200.0 / 255; ...
                255.0 / 255, 255.0 / 255, 255.0 / 255;
                rand(100, 3)]; % colors for different labels
P.label_list(4:end, :) = P.label_list(4:end, :)/1.25;


P.key_label_list = [250/255, 100/255, 100/255; ...
                    100/255, 250/255, 100/255; ...
                    100/255, 100/255, 250/255;];
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
% preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.pre_img_size_standard = [300, 300]; % resize image into a standard size (the total number of pixels will be P.img_size_standard(1) * P.img_size_standard(2))
P.pre_keyhog_sample_mode = 1; % sampling key hog features from input image. set 1 for evenly sparse sampling, 2 for harris corner sampling, 3 for random sampling
P.pre_harris_max_num = 100; % Harris Cornner parameter
P.pre_harris_QualityLevel = 0.0001; % Harris Cornner parameter
P.pre_harris_SensitivityFactor = 0.0001; % Harris Cornner parameter
% HoG detection and clustering
P.pre_hog_cell_size = 8; % size for HoG feature cell (pixel unit). (has to be even). Default 8.
P.pre_hog_patch_size = 8; % size for HoG feature patch (hog cells unit). (has to be even). Default 8.
P.pre_hog_dim = 31 * (P.pre_hog_patch_size)^2; % Feature dimension of a HoG patch.
P.pre_sample_step_dense = P.pre_hog_cell_size/2; % sampling step (pixel unit) for sampling dense HoG features. It decides the resolution of occ maps. Default 4.
P.pre_sample_step_key = (P.pre_hog_cell_size * P.pre_hog_patch_size)/2 - 1; % sampling step (pixel unit) for initializing key HoG features. Default 31.
P.pre_flag_hog_norm = 1; % flag for normalizing hog features. Default 1, meaning use normalization.
% dictionary initialization
P.pre_dictionary_d4D = 2; % controls the number of clusters. Default 2. (Singh's paper used 4 for large dataset)
P.pre_dictionary_cluster_size = 2; % the minimum number of points per cluster. Default 2. meaning two similar hog features are needed to make a valid word. (Singh's paper used 3 for large dataset)
P.pre_dictionary_spect_dim = 50; % the dimension kept for spectural clustering. Default 50.
P.pre_dictionary_max_cluster_num = 100; % maximum number of words in the dictionary. This is only useful for cross-image detection. 
P.pre_dictionary_mode = 2; % dictionary initialization model. Default 2. 0: no clustering, each key hog feature is a word; 1: kmeans + key hog features; 2: kmeans + spectural embedded key hog features.
P.pre_flag_render = 0; % a flag to turn on/off rendering in preprocessing


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iterative improve detector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.detectorimprove_flag = 0;
P.detectorimprove_supervision = 0;
P.detectorimprove_num_iter = 1; % iteration of learning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% discriminative learning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.discriminative_detection_mode = 5;  % set to 1 for Euclidean_mean,  % set 2 for Euclidean_mean_NN,  % set 3 for Ecludean_mean_KNN,  % set 4 for SVM score % set 5 for SVM score w.r.t mean_NN
P.discriminative_svm_exp_ratio = 10; % scaling factor for occ map computed using SVM. The larger the brighter the probability map.
P.discriminative_rms_exp_ratio = 7.5; % scaling factor for occ map computed using RMS. Optimal at half P.discriminative_svm_exp_ratio. set to 7.5 for sws, set to 5 for sw.
P.discriminative_peak_bd = 4; % bandwidth for repetition detection (cell unit). Default 4. 
P.discriminative_occ2rep = 0.5; % threshold for repetition detection (peasks in averaged occ maps). Default 0.5. Will be assigned from P.qlt_list  for PR curve 
P.discriminative_min_sample = 4; % minimum number of positive samples for a valid detection. Default 4. 
P.discriminative_KNN = 5; %number of nearest neighbour for bb_mean_KNN; 
P.discriminative_iter_kmeans = 10; % number of attemps for kmeans
P.discriminative_bb_w_default = 32; % the default width of building block  if no object cut is used
P.discriminative_bb_h_default = 32; % the default height of building block if no object cut is used
P.discriminative_flag_render = 0; % a flag to turn on/off rendering in discriminative learning
P.discriminative_flag = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building Block Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.bblock_dim_mds = 50; % the dimension of mds embedding
P.bblock_num_iter_MS = 500; % the number of iteration for meanshift
P.bblock_bandwidth_MS = 0.5; % bandwidth for meanshift
P.bblock_min_sample = P.discriminative_min_sample; % minimum number of site in a valid repetition
P.bblock_MNCC_shift_bd = floor((P.pre_hog_cell_size * P.pre_hog_patch_size)/(P.pre_sample_step_dense * 2)); % the maximum shift for computing MNCC


P.bblock_graphcut_obj_size = [7, 7]; % the maximum search of object's size notice this is in the resolution of occurrence map
P.bblock_graphcut_p_scaler = 100;
P.bblock_graphcut_p_ini = 1 * P.bblock_graphcut_p_scaler;
P.bblock_graphcut_p_outside = 1 * P.bblock_graphcut_p_scaler;
P.bblock_graphcut_background = 0.5 * P.bblock_graphcut_p_scaler;
P.bblock_graphcut_pairwise = 0.1 * P.bblock_graphcut_p_scaler;
P.bblock_graphcut_weight_neighbour = 1;
P.bblock_graphcut_num_iter = 1;
P.bblock_graphcut_p_wrong_label = 100 * P.bblock_graphcut_p_scaler;
P.bblock_graphcut_P_correct_label = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robustness analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.robustness_min_rep_size = 2; % the minimum number of instances for a valid buiding block. Default 2, meaning it needs to have at least two repetitive instances. 
P.robustness_min_block_size = 8; % the minimum size of a valid building block, in resolution of pixels. Default 8, meaning it needs to be at least 8-by-8 pixels big. 
P.robustness_min_color_var = 0.05; % the minimum color variance of a valid building block. Default 0.05, meaning the minimum color variance within a building block needs to be at least 0.05.
P.robustness_bgtest_obj_num = 10; % the minmum number of objects for a building block to do background test, Default 10, meaning building blocks that have more than nine instances will be tested for background.
P.robustness_bgtest_padding = 10; % the padding for background test. Default 10, meaning 2*10 pixels will be added to each dimension.
P.robustness_bgtest_se_dilation = 2; % the size of the dilation kernel for background test. Default 2, meaning 2*2 + 1 will be the kernel size.
P.robustness_bgtest_gini = 0.75; % the minium gini index for background test. Default 0.5, meaning the gini indice of both dimensions have to be larger than 0.5. 
P.robustness_max_overlap = 0.3; % the maximum overlapping ratio between two instance. Default 0.3, meaing a instance pair that has more than 0.3 overlapping will have one instance removed.
P.robustness_max_overlap_add = 0.25; % the maximum overlap for a repetition to be added into the current abstraction
% P.robustness_max_overlap = 0.5; % the maximum overlapping ratio between two instance. Default 0.5, meaing a instance pair that has more than 0.3 overlapping will have one instance removed.
% P.robustness_max_overlap_add = 0.5; % the maximum overlap for a repetition to be added into the current abstraction
P.robustness_clean = 1;
P.robustness_flag = 0; % a flag to choose between doing robustness analysis or not
P.robustness_num_iter = 1; % iteration of robustness analysis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PR curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.qlt_list = [0.25:0.05:0.75]; % a list of values for P.discriminative_occ2rep. Use it to generate PR curve
P.qlt_number = size(P.qlt_list, 2); % number of values in P.qlt_list
P.eva_min_overlap = 0.0; % The minimum overlapping ratio for two boxes to be matched. Set to a fairly small number due to the imperfection of manual label
P.eva_num_step = 99; % number of steps for interpolating PR curve


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SFE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.sfe_numClusterDefault = 10; % default number of clusters for segmentation based methods
P.sfe_minoverlap = 0.1; % minimum ratio of overlapping hog features for a valid entry in the SFD matrix
P.sfe_maxhogdist = 0.5; % maximum hog distance for two hog features to overlap
P.sfe_bw_n = 4;
P.sfe_list_numCluster = [1:P.qlt_number] + 2;
P.sfe_sample_step = 9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HOGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.hoge_sample_step = 9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grasp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.grasp_numMove = 50;
P.grasp_scale_2D = 1;
P.grasp_scale_M2 = 1;
P.grasp_scale_angle = 1;
P.grasp_tol = 0.05;
P.grasp_minNumWord = 3;
P.grasp_minNumObj = 3;
P.grasp_minEdgeScore = 0.25;