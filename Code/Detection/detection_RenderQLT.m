% run evaluation on a dataset
close all; clear all; clc; cwd = pwd; addpath(genpath(cwd)); warning('OFF');

% Set default parameters
define_COOC_DefaultParams;

% Set experiment parameters
P.name_path = [cwd(1, 1:3) 'Chuan\data\2DBuildingBlocks\'];
P.name_dataset = 'HoleFilling';
P.name_data = 'Resized';
P.name_prefix = 'HoleFilling';
P.name_format = '.jpg';
P.output_path = [P.name_path P.name_dataset '\' P.name_data '\resultAIO\']; mkdir(P.output_path);

% set experiment mode
P.method = 'rob';

% number of images
P.eva_num_img = 2;

% round for rendering
P.eva_robID = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT CHANGE AFTER THIS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch P.method
    case 'gt'
        disp('Render Ground Truth');
        P.output_path = [P.name_path P.name_dataset '\Resized_GT\'];
    case 'pre'
        disp('Render Preprocess');
    case 'sw'
        disp('Render Sliding Window');
        P.output_path = [P.output_path 'sw\'];
    case 'dl'
        disp('Render Discriminative Learning');
        P.output_path = [P.output_path 'dl\'];
    case 'bb'
        disp('Render Building Blocks');
        P.output_path = [P.output_path 'bb\'];
    case 'gmbb'
        disp('Render Building Blocks with Graph Matching');
        P.output_path = [P.output_path 'gmbb\'];
    case 'nodlbb'
        disp('Render Building Blocks without Discriminative Learning');
        P.output_path = [P.output_path 'nodlbb\'];
    case 'rob'
        disp('Render Robustness Analysis')
        P.output_path = [P.output_path 'rob\'];
    case 'sws'
        disp('Render Sliding Window (Supervised)')
        P.output_path = [P.output_path 'sws\'];
    case 'hoge'
        disp('Render HoG Embedding')
        P.output_path = [P.output_path 'hoge\'];
    case 'sfe'
        disp('Render Symmetry Factor Embedding')
        P.output_path = [P.output_path 'sfe\'];
    case 'ccw'
        disp('Render CCW')
        P.output_path = [P.output_path 'ccw\'];
    case 'grasp'
        disp('Render Grasp')
        P.output_path = [P.output_path 'grasp\'];
    otherwise
        warning('Unexpected methods.');
end

% Set up method
define_SetMethod;

for i_img = 0:P.eva_num_img - 1
    P_cur = P;
    name = [P.name_prefix '(' num2str(i_img) ')']; format = P_cur.name_format ;P_cur.img_name = name;
   
    format = P_cur.name_format ;
    im_train = double(imread([P_cur.name_path '\' P_cur.name_dataset '\' P_cur.name_data '\' name P_cur.name_format]))/255;
    
    switch P.method
        case 'gt'
            disp('Render Ground Truth');
            filename = [P.output_path name '_GT.mat'];
            outputname  = [P.output_path name '_GT.png'];
        case 'pre'
            disp('Render Preprocess');
        case 'sw'
            disp('Render Sliding Window');
            filename = [P.output_path name '_sw' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_sw.png'];
        case 'dl'
            disp('Render Discriminative Learning');
            filename = [P.output_path name '_dl' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_dl.png'];
        case 'bb'
            disp('Render Building Blocks');
            filename = [P.output_path name '_bb' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_bb.png'];
        case 'gmbb'
            disp('Render Building Blocks with Graph Matching');
            filename = [P.output_path name '_gmbb' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_gmbb.png'];
        case 'nodlbb'
            disp('Render Building Blocks without Discriminative Learning');
            filename = [P.output_path name '_nodlbb' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_nodlbb.png'];
        case 'rob'
            disp('Render Robustness Analysis')
            filename = [P.output_path name '_afmg.mat'];
            outputname = [P.output_path name '_afmg.png'];
        case 'sws'
            disp('Render Sliding Window (Supervised)')
            filename = [P.output_path name '_sws' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_sws.png'];
        case 'hoge'
            disp('Render HoG Embedding')
            filename = [P.output_path name '_hoge' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_hoge.png'];
        case 'sfe'
            disp('Render Symmetry Factor Embedding')
            filename = [P.output_path name '_sfe' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_sfe.png'];
        case 'ccw'
            disp('Render CCW')
            filename = [P.output_path name '_ccw.mat'];
            outputname = [P.output_path name '_ccw.png'];
        case 'grasp'
            disp('Render Grasp')
            filename = [P.output_path name '_grasp' '_rob_' num2str(P_cur.eva_robID)  '.mat'];
            outputname = [P.output_path name '_grasp.png'];
        otherwise
            warning('Unexpected methods.');
    end
    
    if exist(filename, 'file')
        bb.rep = [];
        
        load(filename);
        
        switch P.method
            case 'gt'
                bb.rep = GT.rep;
            case 'pre'
                
            case 'sw'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'dl'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'bb'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'gmbb'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'nodlbb'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'rob'
                bb.rep = Merge.rep;
            case 'sws'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'hoge'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'sfe'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            case 'ccw'
                bb.rep = Detect.rep;
            case 'grasp'
                bb.rep = D_train.bb;
                for i = 1:size(bb.rep, 2)
                    bb.rep{1, i}(3, :) = D_train.bb_w(1, i);
                    bb.rep{1, i}(4, :) = D_train.bb_h(1, i);
                end
            otherwise
                warning('Unexpected methods.');
        end
        
        if ~isempty(bb.rep)
            h = figure;
            set(h, 'Color',[1, 2, 255]/255);
            imshow(im_train);
            hold on;
            axis off;
            for i_rep = 1:min(5, size(bb.rep, 2))
                for i = 1:size(bb.rep{1, i_rep}, 2)
                    box = repmat(bb.rep{1, i_rep}(1:2, i), 1, 4) + [0, bb.rep{1, i_rep}(3, i), bb.rep{1, i_rep}(3, i), 0; 0, 0, bb.rep{1, i_rep}(4, i), bb.rep{1, i_rep}(4, i)];
                    plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', 'k', 'LineWidth', 6);
                    plot(box(1, [1:4, 1]), box(2, [1:4, 1]), 'Color', P.label_list(i_rep, :), 'LineWidth', 3);
                end
            end
            F = im2frame(zbuffer_cdata(h));
            [x, y] = ind2sub([size(F.cdata,1) size(F.cdata,2)], find(F.cdata(:, :, 1) ~= 1 & F.cdata(:, :, 2) ~= 2 & F.cdata(:, :, 3) ~= 255));
            imwrite(F.cdata(min(x):max(x),min(y):max(y),:),  outputname);
            hold off;
            clf;
            close;
        else
        end
    else
        
    end
    
end

return;
