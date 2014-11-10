close all; clear all;

name_im1 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332).jpg';
name_im2 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_label.png';
name_im3 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_syn_1.5_1_1_1_Detection.jpg';
name_im4 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_synRenderlabel_1.5_1_1_1_Detection.png';
name_im5 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_syn_1.5_1_3_1_Detection.jpg';
name_im6 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_synRenderlabel_1.5_1_3_1_Detection.png';
name_im7 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_syn_1.5_1_3_5_Detection.jpg';
name_im8 = 'C:\Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Paper\Fig\Fig12\Facade(332)_synRenderlabel_1.5_1_3_5_Detection.png';

im1= imread(name_im1);
im2= imread(name_im2);
im3= imread(name_im3);
im4= imread(name_im4);
im5= imread(name_im5);
im6= imread(name_im6);
im7= imread(name_im7);
im8= imread(name_im8);

% name_prefix = '1';
% region12 = [65, 270, 100, 100];
% region34 = [175, 270, 100, 100];
% region56 =  [185, 270, 100, 100];
% region78 =  [140, 270, 100, 100];
% 
% im1 = im1(region12(2):region12(2) + region12(4), region12(1):region12(1) + region12(3), :);
% im2 = im2(region12(2):region12(2) + region12(4), region12(1):region12(1) + region12(3), :);
% im3 = im3(region34(2):region34(2) + region34(4), region34(1):region34(1) + region34(3), :);
% im4 = im4(region34(2):region34(2) + region34(4), region34(1):region34(1) + region34(3), :);
% im5 = im5(region56(2):region56(2) + region56(4), region56(1):region56(1) + region56(3), :);
% im6 = im6(region56(2):region56(2) + region56(4), region56(1):region56(1) + region56(3), :);
% im7 = im7(region78(2):region78(2) + region78(4), region78(1):region78(1) + region78(3), :);
% im8 = im8(region78(2):region78(2) + region78(4), region78(1):region78(1) + region78(3), :);
% 
% imwrite(im1, [name_prefix '_1.png']);
% imwrite(im2, [name_prefix '_2.png']);
% imwrite(im3, [name_prefix '_3.png']);
% imwrite(im4, [name_prefix '_4.png']);
% imwrite(im5, [name_prefix '_5.png']);
% imwrite(im6, [name_prefix '_6.png']);
% imwrite(im7, [name_prefix '_7.png']);
% imwrite(im8, [name_prefix '_8.png']);


name_prefix = '2';
region12 = [55, 128, 100, 100];
region34 = [145, 128, 100, 100];
region56 =  [118, 128, 100, 100];
region78 =  [128, 128, 100, 100];

im1 = im1(region12(2):region12(2) + region12(4), region12(1):region12(1) + region12(3), :);
im2 = im2(region12(2):region12(2) + region12(4), region12(1):region12(1) + region12(3), :);
im3 = im3(region34(2):region34(2) + region34(4), region34(1):region34(1) + region34(3), :);
im4 = im4(region34(2):region34(2) + region34(4), region34(1):region34(1) + region34(3), :);
im5 = im5(region56(2):region56(2) + region56(4), region56(1):region56(1) + region56(3), :);
im6 = im6(region56(2):region56(2) + region56(4), region56(1):region56(1) + region56(3), :);
im7 = im7(region78(2):region78(2) + region78(4), region78(1):region78(1) + region78(3), :);
im8 = im8(region78(2):region78(2) + region78(4), region78(1):region78(1) + region78(3), :);

imwrite(im1, [name_prefix '_1.png']);
imwrite(im2, [name_prefix '_2.png']);
imwrite(im3, [name_prefix '_3.png']);
imwrite(im4, [name_prefix '_4.png']);
imwrite(im5, [name_prefix '_5.png']);
imwrite(im6, [name_prefix '_6.png']);
imwrite(im7, [name_prefix '_7.png']);
imwrite(im8, [name_prefix '_8.png']);

