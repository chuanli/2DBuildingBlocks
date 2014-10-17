function  [cent, varargout]=FastPeakFindPadding_CLOrder(d, edg)
% Analyze noisy 2D images and find peaks to 1 pixel accuracy.
% The code is desinged to be as fast as possible, so I kept it pretty basic.
% The code assumes that the peaks are relatively sparse, test whether there
% is too much pile up and set threshold or user defined filter accordingly.
%
% Inputs:
%   d           The 2D data raw image - assumes a Double\Single-precision
%               floating-point, uint8 or unit16 array. Please note that the code
%               casts the raw image to uint16 if needed.  If the image dynamic range is
%               between 0 and 1, I multiplied to fit uint16. This might not be optimal for
%               generic use, so modify according to your needs.
%   threshold   A number between 0 and max(raw_image(:)) to remove  background
%   filt        A filter matrix used to smooth the image. The filter size
%               should correspond the characteristic size of the peaks
%   edg         A number>1 for skipping the first few and the last few 'edge' pixels
%   fid         In case the user would like to save the peak positions to
%               a file, the code assumes a "fid = fopen([filename], 'w+');" line
%               in the script that uses this function.
%
% Optional Outputs:
%   cent        a 1xN vector of coordinates of peaks (y1,x1,y2,x2,...
%   [cent cm]   in addition to cent, cm is a binary matrix  of size(d)
%               with 1's for peak positions.
%
%   Example:
%
%   p=FastPeakFind(image);
%   imagesc(image); hold on
%   plot(p(2:2:end),p(1:2:end),'r+')
%
%
%   Natan (nate2718281828@gmail.com)
%   Ver 1.61 , Date: June 5th 2013
%
%
%% defaults

if (nargin < 2)
    edg = [3, 3];
end

% d = padarray(d, edg, 'replicate', 'both');
d = padarray(d, edg, 'both');
% figure;
% imshow(d);
%% Analyze image
if any(d(:))  ; %for the case of non zero raw image
    %     figure;
    %     imshow(d);
    
    %     d = medfilt2(d,[3,3]);
    %     figure;
    %     imshow(d);
    
    %     % apply threshold
    %     if isa(d,'uint8')
    %     d=d.*uint8(d>threshold);
    %     else
    %     d=d.*uint16(d>threshold);
    %     end
    
    if any(d(:))   ; %for the case of the image is still non zero
        
        % smooth image
        %         d=conv2(single(d),filt,'same') ;
        
        %         figure;
        %         imshow(d);
        % Apply again threshold (and change if needed according to SNR)
        %         d=d.*(d>0.9*threshold);
        %         figure;
        %         imshow(d);
        
        % peak find - using the local maxima approach - 1 pixle resolution
        % d will be noisy on the edges, since no hits are expected there anyway we'll skip 'edge' pixels.
        sd=size(d);
        [x y]=find(d(edg(1):sd(1)-edg(1),edg(2):sd(2)-edg(2)));

        idx = sub2ind(size(d(edg(1):sd(1)-edg(1),edg(2):sd(2)-edg(2))), x, y);
        k = d(edg(1):sd(1)-edg(1),edg(2):sd(2)-edg(2));
        energy = k(idx)';
        energy = [energy; x'; y'];
        energy = sortrows(energy', 1);
        energy = energy(end:-1:1, :);
        x = energy(:, 2);
        y = energy(:, 3);
%         energy
        % initialize outputs
        cent=[];%
        cent_map=zeros(sd);
        
        x=x+edg(1)-1;
        y=y+edg(2)-1;

        for j=1:length(y)
            all_value = d(x(j) - (edg(1) - 1):x(j) + (edg(1) - 1), y(j) - (edg(2) - 1):y(j) + (edg(2) - 1));

%             [d(x(j),y(j)), max(max(all_value))]
            if d(x(j),y(j)) == max(max(all_value))
                
                 
                 
                %             if (d(x(j),y(j))>=d(x(j)-1,y(j)-1 )) &&...
                %                     (d(x(j),y(j))>d(x(j)-1,y(j))) &&...
                %                     (d(x(j),y(j))>=d(x(j)-1,y(j)+1)) &&...
                %                     (d(x(j),y(j))>d(x(j),y(j)-1)) && ...
                %                     (d(x(j),y(j))>d(x(j),y(j)+1)) && ...
                %                     (d(x(j),y(j))>=d(x(j)+1,y(j)-1)) && ...
                %                     (d(x(j),y(j))>d(x(j)+1,y(j))) && ...
                %                     (d(x(j),y(j))>=d(x(j)+1,y(j)+1));
                
                %All these alternatives were slower...
                %if all(reshape( d(x(j),y(j))>=d(x(j)-1:x(j)+1,y(j)-1:y(j)+1),9,1))
                %if  d(x(j),y(j)) == max(max(d((x(j)-1):(x(j)+1),(y(j)-1):(y(j)+1))))
                %if  d(x(j),y(j))  == max(reshape(d(x(j),y(j))  >=  d(x(j)-1:x(j)+1,y(j)-1:y(j)+1),9,1))
                
                cent = [cent [y(j); x(j)]];
                v = d(x(j),y(j)) ;
                d(x(j) - (edg(1) - 1):x(j) + (edg(1) - 1), y(j) - (edg(2) - 1):y(j) + (edg(2) - 1)) = 0;
                d(x(j),y(j)) = v;
                cent_map(x(j),y(j))=cent_map(x(j),y(j))+1; % if a binary matrix output is desired
                
            end
        end
        %
        %         if savefileflag
        %             % previous version used dlmwrite, which can be slower than  fprinf
        %             %             dlmwrite([filename '.txt'],[cent],   '-append', ...
        %             %                 'roffset', 0,   'delimiter', '\t', 'newline', 'unix');+
        %
        %             fprintf(fid, '%f ', cent(:));
        %             fprintf(fid, '\n');
        %
        %         end
        
        cent(1, :) = cent(1, :) - edg(2);
        cent(2, :) = cent(2, :) - edg(1);
       
%         mask = cent(1, :) > 0 & cent(1, :) <= size(d, 2) - 2 * edg(1) & cent(2, :) > 0 & cent(2, :) <= size(d, 1) - 2 * edg(1);
%         cent = cent(:, mask);
        
    else % in case image after threshold is all zeros
        cent=[];
        cent_map=zeros(size(d));
        if nargout>1 ;  varargout{1}=cent_map; end
        return
    end
    
else % in case raw image is all zeros (dead event)
    cent=[];
    cent_map=zeros(size(d));
    if nargout>1 ;  varargout{1}=cent_map; end
    return
end

%demo mode - no input to the function
if (nargin < 1); colormap(bone);hold on; plot(cent(2:2:end),cent(1:2:end),'rs');hold off; end

% return binary mask of centroid positions if asked for
if nargout>1 ;  varargout{1}=cent_map; end