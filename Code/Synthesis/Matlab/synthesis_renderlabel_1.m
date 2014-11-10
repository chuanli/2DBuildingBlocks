close all; clear all;

P.label_list_rgb = [102.0 / 255, 153.0 / 255, 255.0 / 255; ...
    255.0 / 255, 204.0 / 255, 102.0 / 255; ...
    102.0 / 255, 255.0 / 255, 127.0 / 255; ...
    255.0 / 255, 127.0 / 255, 102.0 / 255; ...
    102.0 / 255, 230.0 / 255, 255.0 / 255; ...
    41.0 / 255, 112.0 / 255, 255.0 / 255; ...
    255.0 / 255, 184.0 / 255, 41.0 / 255; ...
    235.0 / 255, 156.0 / 255, 0.0 / 255; ...
    0.0 / 255, 78.0 / 255, 235.0 / 255]; % colors for different labels
P.label_list_hsv = rgb2hsv(P.label_list_rgb);


P.ini_v = 0.5;
name_dataset = 'Bidrectional';
max_numbb = 3;

for sel_id = 0:4
    nameDetection = ['C:\Chuan\data\2DBuildingBlocks\' name_dataset '\Resized\resultAIO\rob\' name_dataset '(' num2str(sel_id) ')_afmg.mat'];
    Detection = [];
    
    if exist(nameDetection, 'file')
        load(nameDetection);
        Detection = Merge;
    else
        Detection.rep = [];
    end
    
    im = imread(['C:\Chuan\data\2DBuildingBlocks\' name_dataset '\Resized\' name_dataset '(' num2str(sel_id) ').jpg']);
    im_out = ones(size(im));
    for i = 1:min(max_numbb, size(Detection.rep, 2))
        for j = 1:size(Detection.rep{1, i}, 2)
            x_start = Detection.rep{1, i}(1, j);
            y_start = Detection.rep{1, i}(2, j);
            x_end = x_start + Detection.rep{1, i}(3, j) - 1;
            y_end = y_start + Detection.rep{1, i}(4, j) - 1;
            x_end = min(x_end, size(im_out, 2));
            y_end = min(y_end, size(im_out, 1));
            
            % do some rendering here
            h = P.label_list_hsv(i, 1);
            s = P.label_list_hsv(i, 2);
            for r = y_start:y_end
                for c = x_start:x_end
                    v1 =(r - y_start + 1)/(y_end - y_start + 1);
                    v2 = (c - x_start + 1)/(x_end - x_start + 1);
                    v = P.ini_v  + (1 - P.ini_v ) * (v1 + v2)/2;
                    rgb = hsv2rgb([h, s, v]);
                    im_out(r, c, 1) = rgb(1);
                    im_out(r, c, 2) = rgb(2);
                    im_out(r, c, 3) = rgb(3);
                end
            end
        end
    end
    
    imwrite(im_out, [name_dataset '(' num2str(sel_id) ')_label.png']);
end
