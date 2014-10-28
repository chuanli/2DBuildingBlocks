function flag_done = func_detection(P)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up method
define_SetMethod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if P.detection_flag == 1
    for i_rob = 0:P.robustness_num_iter
        parfor i_img = 0:P.eva_num_img - 1
            try
                warning('off','all'); P_cur = P; D_train = []; D_buffer = []; P_cur.i_rob = i_rob;
                name = [P.name_prefix '(' num2str(i_img) ')']; format = P_cur.name_format ;P_cur.img_name = name;
                im_train = double(imread([P_cur.name_path '\' P_cur.name_dataset '\' P_cur.name_data '\' name P_cur.name_format]))/255;                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Embedding based methods
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if P.sfe_flag == 1
                    D_train = func_detection_sfe(im_train, name, P_cur);
                end
                if P.hoge_flag == 1
                    D_train = func_detection_hoge(im_train, name, P_cur);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % parse input image
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                D_train = func_build_parseImg_singleimage(im_train, P_cur, 0);
                D_train.img_name = name;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Pre process: bulid initial dictionary
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if P.pre_flag == 1 % build dictionary on the fly
                    D_buffer = func_ini_dictionary_singleimage(D_buffer, D_train, P_cur, 1, P_cur.pre_flag_render);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Iteratively improve detectors
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if P_cur.detectorimprove_flag == 1 % iterate dl on the fly
                    if P_cur.detectorimprove_supervision == 1 % use supervised detectors
                        Data = load([P_cur.output_path 'sample_detector.mat']); D_buffer = Data.D_buffer;
                    else % use unsupervised detectors
                        Data = load([P_cur.output_path name '_dict' '_rob_' num2str(P_cur.i_rob) '.mat']); D_buffer = Data.D_buffer;
                    end
                    P_cur.i_discriminative = 0;
                    
                    for i_iter = 1:P_cur.detectorimprove_num_iter
                        P_cur.i_detectorimprove = i_iter;
                        
                        if P_cur.discriminative_flag == 1 % train one-vs-all svms if necessary
                            D_buffer = func_svm_singleimage(D_buffer);
                        end
                        
                        % test detectors on the image
                        D_train = func_occ_singleimage(D_buffer, D_train, P_cur, P_cur.discriminative_flag_render);
                        
                        % repetition detection for occ maps
                        D_train = func_rep_singleimage(D_train, P_cur, P_cur.discriminative_flag_render);
                        
                        % resample from the detection
                        [D_buffer, D_train] = func_resample_singleimage(D_buffer, D_train, P_cur, P_cur.discriminative_flag_render);
                    end
                    D_train = func_detection2rep(D_train, P_cur); % recoganize the detection result into repetition
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % BB
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if P_cur.bblock_flag == 1 % perform bb detection on the fly
                    if P.bblock_nodl_flag == 1
                        Data = load([P_cur.output_path 'sw\' name  '_sw' '_rob_' num2str(P_cur.i_rob)  '.mat']); D_train = Data.D_train;
                    else
                        Data = load([P_cur.output_path 'dl\' name  '_dl' '_rob_' num2str(P_cur.i_rob)  '.mat']); D_train = Data.D_train;
                    end
                    
                    D_train = func_cooc_singleimage(D_train, P_cur);
                    
                    if P.gm_flag == 1 % use graph matching for pattern generation
                        D_train = func_cooc_gm(D_train, P_cur);
                    else
                        ;
                    end
                    % cut out objects using graph cut
                    D_train = func_graphcut_first_singleimage(D_train, P_cur);
                    D_train = func_graphcut_second_singleimage(D_train, P_cur);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Grasp
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if P_cur.grasp_flag == 1 % perform grasp on the fly
                    Data = load([P_cur.output_path 'dl\' name  '_dl' '_rob_' num2str(P_cur.i_rob)  '.mat']); D_train = Data.D_train;
                    D_train = func_detection_grasp(D_train, P_cur);
                end
                
            catch
                ;
            end
            
        end % parfor i_img = 0:P.eva_num_img - 1
    end % for for i_rob = 0:0
end % if P.detection_flag == 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robustness Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if P.robustness_flag == 1
    disp(['Robustness analysis starts ...']);
     for i_img = 0:P.eva_num_img - 1
        try
            warning('off','all');
            P_cur = P; D_train = []; D_buffer = [];
            name = [P.name_prefix '(' num2str(i_img) ')']; format = P_cur.name_format ;P_cur.img_name = name;
            %         name = ['fac(' num2str(i_img) ')'];  format = P_cur.name_format ;
            im_train = double(imread([P_cur.name_path '\' P_cur.name_dataset '\' P_cur.name_data '\' name P_cur.name_format]))/255;
            % evaluate individual repetitions
            for i_rob =  0:P.robustness_num_iter
                P_cur.i_rob = i_rob;
                if exist([P_cur.output_path 'bb\' name '_bb' '_rob_' num2str(P_cur.i_rob) '.mat'], 'file')
                    Data = load([P_cur.output_path 'bb\' name '_bb' '_rob_' num2str(P_cur.i_rob)  '.mat']);
                    D_train = Data.D_train;
                    Detect = func_robust_clean_singleimage(D_train, P_cur);
                else
                    %                     skip this image
                end
            end % for i_rob = 2:P.robustness_num_iter
            Merge = func_robust_merge_singleimage(P_cur, name, format);
        catch
            ;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CCW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if P.ccw_flag == 1
    disp(['CCW starts ...']);
    parfor i_img = 0:P.eva_num_img - 1
        warning('off','all');
        P_cur = P; D_train = []; D_buffer = [];
        Detect = func_detection_ccw(P_cur, i_img);
    end
end

flag_done = true;
