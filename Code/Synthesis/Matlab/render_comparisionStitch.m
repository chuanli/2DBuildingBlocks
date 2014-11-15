warning('off','all');close all; clear all; cwd = pwd; addpath(genpath(cwd));clc;

P.name_path = [cwd(1, 1:3) 'Chuan\svn_statgeo\papers\TOG2015_2DBuildingBlocks\Results\'];
nameLatexOutput = ['latex.txt'];
fileID = fopen(nameLatexOutput,'w');

 P.name_dataset = 'Facade';
 for i_img =7:599
     if mod(i_img - 7, 8) == 0
         fprintf(fileID, '\\begin{figure*}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, '\\begin{tabular}{cccc}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, 'input &\n');
         fprintf(fileID, '\\protected{\\shortcite{Pritch09ICCV}} &\n');
         fprintf(fileID, '\\protected{\\shortcite{He2012PO}} &\n');
         fprintf(fileID, 'ours \\\\\n');
     end

     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.16\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ').jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_1_1_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_2_3_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_3_5_Detection.jpg} \\\\\n']);
         
     if mod(i_img - 7, 8) == 7
          fprintf(fileID, '\\end{tabular} \n');
          fprintf(fileID, '\\end{figure*} \n');
          if i_img~= 599
          fprintf(fileID, '\\clearpage \n');
          end
     end
     
 end
 
 
 if mod(i_img - 7, 8) ~= 7
     fprintf(fileID, '\\end{tabular} \n');
      fprintf(fileID, '\\end{figure*} \n');
 end
 
  
P.name_dataset = 'Shiftmap';
  for i_img =0:25
     if mod(i_img, 8) == 0
         fprintf(fileID, '\\begin{figure*}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, '\\begin{tabular}{cccc}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, 'input &\n');
         fprintf(fileID, '\\protected{\\shortcite{Pritch09ICCV}} &\n');
         fprintf(fileID, '\\protected{\\shortcite{He2012PO}} &\n');
         fprintf(fileID, 'ours \\\\\n');
     end

     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.16\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ').jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_1_1_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_2_2_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_3_4_Detection.jpg} \\\\\n']);
         
     if mod(i_img , 8) == 7
          fprintf(fileID, '\\end{tabular} \n');
          fprintf(fileID, '\\end{figure*} \n');
          if i_img~= 25
          fprintf(fileID, '\\clearpage \n');
          end
     end
     
 end
 
 if mod(i_img , 8) ~= 7
     fprintf(fileID, '\\end{tabular} \n');
      fprintf(fileID, '\\end{figure*} \n');
 end

  
P.name_dataset = 'OffsetStatistics';
  for i_img =0:20
     if mod(i_img, 8) == 0
         fprintf(fileID, '\\begin{figure*}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, '\\begin{tabular}{cccc}\n');
         fprintf(fileID, '\\centering\n');
         fprintf(fileID, 'input &\n');
         fprintf(fileID, '\\protected{\\shortcite{Pritch09ICCV}} &\n');
         fprintf(fileID, '\\protected{\\shortcite{He2012PO}} &\n');
         fprintf(fileID, 'ours \\\\\n');
     end

     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.16\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ').jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_1_1_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_2_2_Detection.jpg} &\n']);
     fprintf(fileID, ['\\includegraphics[height= 0.1\\textheight, width=.24\\columnwidth, keepaspectratio]{Fig/' P.name_dataset '/' P.name_dataset '(' num2str(i_img) ')_syn_3_4_Detection.jpg} \\\\\n']);
         
     if mod(i_img , 8) == 7
          fprintf(fileID, '\\end{tabular} \n');
          fprintf(fileID, '\\end{figure*} \n');
          if i_img~= 20
          fprintf(fileID, '\\clearpage \n');
          end
     end
     
 end
 
 if mod(i_img , 8) ~= 7
     fprintf(fileID, '\\end{tabular} \n');
      fprintf(fileID, '\\end{figure*} \n');
 end

 
 fclose(fileID);
 
 