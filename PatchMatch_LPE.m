% Inputs: 
% - targetImg: An image (usually masked by NaN. NaN is lost domain)
% - sourceImg: An image from which patches are extracted, same size as targetImg.
% - psz: patch size (psz x psz). Default is 9. 
% 
% Outputs:
% - NNF: Nearest Neighbor Field, which contains indices of sourceImg for 
%        each corresponding indices of targetImg
% - debug: debugging information.
%

function [NNF, debug] = PatchMatch_LPE(targetImg_extent, sourceImg_extent,level,max_level, NNF_L,debug, psz)
%targetImg:               A_extent
%sourceImg:              B_extent
%level:                        matching  A_extent{level}   and   B_extent{level}
%max_level:               level number
%NNF_L, offset_L:     ��һ���߶ȵ���Ϣ
if level<max_level
    NNF_resize1=size(targetImg_extent{level},1)/size(targetImg_extent{level+1},1);
    NNF_resize2=size(targetImg_extent{level},2)/size(targetImg_extent{level+1},2);
end
%get feature image in this level
targetImg=targetImg_extent{level};% m1*n1*12
sourceImg=sourceImg_extent{level};% m2*n2*12

% set psz to default
if (nargin<6); psz =5; end

% % grayscale images only (TODO: extend to color images)
% if ~ismatrix(targetImg); targetImg = rgb2gray(targetImg); end
% if ~ismatrix(sourceImg); sourceImg = rgb2gray(sourceImg); end

targetImg = double(targetImg);% m1*n1*12
sourceImg = double(sourceImg);% m2*n2*12

%%%%%%%%%%%%%%%%%%%%
%--  Initialize NNF and Offset --%
%%%%%%%%%%%%%%%%%%%%
ssz = [size(sourceImg,1),size(sourceImg,2),size(sourceImg,3)];
tsz = [size(targetImg,1),size(targetImg,2),size(targetImg,3)];
if mod(psz,2)==1
    w = (psz-1)/2;
else
    error('psz must be odd.');
end
%the copy of target feature: 3D image
targetImg_NaN = nan(tsz(1)+2*w,tsz(2)+2*w,tsz(3));
for channel=1:tsz(3)
    targetImg_NaN(1+w:tsz(1)+w,1+w:tsz(2)+w,channel) = targetImg(:,:,channel);
end


if level==max_level
   
    %% NNF indices whose patches do not lap over outer range of images
    % [m2*n2*2] 3D  NNF
    NNF = cat(3,...
        randi([1+w,ssz(1)-w],[tsz(1),tsz(2),1]),...
        randi([1+w,ssz(2)-w],[tsz(1),tsz(2),1])...
    );
    %%
    % initialize offsets (what a redundant code...)
    % need not calcurate offset in advance? => anyway, implement!
    fprintf('Initalizing... ');
    offsets = inf(tsz(1),tsz(2));% 2D Offset Field
    for ii = 1:tsz(1)
          for jj = 1:tsz(2)
            %3D patch :feature Eular distance
            ofs_ini = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w,:)...
                  - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w,:);

            ofs_ini = ofs_ini(~isnan(ofs_ini(:)));
            offsets(ii,jj) = sum(ofs_ini.^2)/length(ofs_ini);
          end
    end
    fprintf('Done.\n');
    %%
    debug.offsets_ini{level} = offsets;
    debug.NNF_ini{level} = NNF;
else % using the upsample of the previous NNF
    %% [m2*n2*2] 3D  NNF
    NNF =cat(3, zeros([tsz(1),tsz(2)]), zeros([tsz(1),tsz(2)]));
    NNF(:,:,1)=min(max(floor(imresize(NNF_L(:,:,1),[tsz(1),tsz(2)],'bilinear')*NNF_resize1),w+1),size(sourceImg,1)-w);
    NNF(:,:,2)=min(max(floor(imresize(NNF_L(:,:,2),[tsz(1),tsz(2)],'bilinear')*NNF_resize2),w+1),size(sourceImg,2)-w);
    %% 
    offsets = inf(tsz(1),tsz(2));% 2D Offset Field
    for ii = 1:tsz(1)
          for jj = 1:tsz(2)

            ofs_ini = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                  - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w  , :);

            ofs_ini = ofs_ini(~isnan(ofs_ini(:)));
            offsets(ii,jj) = sum(ofs_ini.^2)/length(ofs_ini);
          end
    end
    fprintf('Done.\n');
    %%
    debug.offsets_ini{level} = offsets;
    debug.NNF_ini{level} = NNF;
end

%%%%%%%%%%%%%%%%%%%%%%%%
%--  MAIN ITERATION  --%
%%%%%%%%%%%%%%%%%%%%%%%%
max_iterations =4;
radius = ssz(1)/4;
alpha = .5;
% min n s.t. r(alpha)^n < 1
% total_itr_rs = -floor(log(radius)/log(alpha));
Radius = round(radius*alpha.^(0:(-floor(log(radius)/log(alpha)))));
lenRad = length(Radius);
for iteration = 1:max_iterations

    is_odd = mod(iteration,2)==1;

    %% raster scan or reverse raster scan
    if is_odd % odd
        disp([num2str(iteration),'th iteration (raster scan order) start!.']);
        ii_seq = 1:tsz(1); jj_seq = 1:tsz(2);
    else % even
        disp([num2str(iteration),'th iteration (reverse raster scan order) start!.']);
        ii_seq = tsz(1):(-1):1; jj_seq = tsz(2):(-1):1;
    end

    fprintf('0%%----------100%%\n >'); % ten %s.
    dispProgress = false(tsz(1)*tsz(2),1);
    dispInterval = floor(tsz(1)*tsz(2)/10);
    dispProgress(dispInterval:dispInterval:end) = true;
    debug.dispProgress = dispProgress;

    for ii = ii_seq
          for jj = jj_seq

            % TODO: if offset(ii,jj) is lower than predefined threshold, continue.

            %%%%%%%%%%%%%%%%%%%%%
            %--  Propagation  --%
            %%%%%%%%%%%%%%%%%%%%%


            %% propagate from top and left
            if is_odd %odd

                % center, top, left
                ofs_prp(1) = offsets(ii,jj);
                ofs_prp(2) = offsets(max(1,ii-1),jj);
                ofs_prp(3) = offsets(ii,max(1,jj-1));
                [~,idx] = min(ofs_prp);

                % propagate from top
                switch idx
                case 2
                    if NNF(ii-1,jj,1)+1+w<=ssz(1) && NNF(ii-1,jj,2)+w<=ssz(2)
                    % if idx==2 && NNF(ii-1,jj,1)+1+w<=ssz(1) && NNF(ii-1,jj,2)+w<=ssz(2)
                        NNF(ii,jj,:) = NNF(ii-1,jj,:);
                        NNF(ii,jj,1) = NNF(ii,jj,1)+1;
                        tmp = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                              - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w , :);
                        tmp = tmp(~isnan(tmp(:)));
                        offsets(ii,jj) = sum(tmp(:).^2)/length(tmp(:));
                    end

                % propagate from left
                case 3
                    % elseif idx==3 && NNF(ii,jj-1,1)<=ssz(1) && NNF(ii,jj-1,2)+1+w<=ssz(2)
                    if NNF(ii,jj-1,1)<=ssz(1) && NNF(ii,jj-1,2)+1+w<=ssz(2)
                        NNF(ii,jj,:) = NNF(ii,jj-1,:);
                        NNF(ii,jj,2) = NNF(ii,jj,2)+1;
                        tmp = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                              - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w , :);
                        tmp = tmp(~isnan(tmp(:)));
                        offsets(ii,jj) = sum(tmp(:).^2)/length(tmp(:));
                    end
                end

            %% propagate from bottom and right
            else %even

                % center, bottom, right
                ofs_prp(1) = offsets(ii,jj);
                ofs_prp(2) = offsets(min(ii+1,tsz(1)),jj);
                ofs_prp(3) = offsets(ii,min(jj+1,tsz(2)));
                [~,idx] = min(ofs_prp);

                % propagate from bottom
                switch idx
                case 2
                    if idx==2 && NNF(ii+1,jj,1)-1-w>=1 && NNF(ii+1,jj,2)-w>=1
                    % if idx==2 && NNF(ii+1,jj,1)-1-w>=1 && NNF(ii+1,jj,2)-w>=1
                        NNF(ii,jj,:) = NNF(ii+1,jj,:);
                        NNF(ii,jj,1) = NNF(ii,jj,1)-1;
                        tmp = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                              - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w , :);
                        tmp = tmp(~isnan(tmp(:)));
                        offsets(ii,jj) = sum(tmp(:).^2)/length(tmp(:));
                    end

                    % propagate from right
                case 3
                    if idx==3 && NNF(ii,jj+1,1)-w>=1 && NNF(ii,jj+1,2)-1-w>=1
                    % elseif idx==3 && NNF(ii,jj+1,1)-w>=1 && NNF(ii,jj+1,2)-1-w>=1
                        NNF(ii,jj,:) = NNF(ii,jj+1,:);
                        NNF(ii,jj,2) = NNF(ii,jj,2)-1;
                        tmp = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                              - sourceImg(NNF(ii,jj,1)-w:NNF(ii,jj,1)+w,NNF(ii,jj,2)-w:NNF(ii,jj,2)+w , :);
                        tmp = tmp(~isnan(tmp(:)));
                        offsets(ii,jj) = sum(tmp(:).^2)/length(tmp(:));
                    end
                end

            end


            %%%%%%%%%%%%%%%%%%%%%%
            %--  RandomSearch  --%
            %%%%%%%%%%%%%%%%%%%%%%

            iis_min = max(1+w,NNF(ii,jj,1)-Radius(:));
            iis_max = min(NNF(ii,jj,1)+Radius(:),ssz(1)-w);
            jjs_min = max(1+w,NNF(ii,jj,2)-Radius(:));
            jjs_max = min(NNF(ii,jj,2)+Radius(:),ssz(2)-w);

            iis = floor(rand(lenRad,1).*(iis_max(:)-iis_min(:)+1)) + iis_min(:);
            jjs = floor(rand(lenRad,1).*(jjs_max(:)-jjs_min(:)+1)) + jjs_min(:);

            nns(:,1) = NNF(ii,jj,:);
            nns(:,2:lenRad+1) = [iis';jjs'];

            ofs_rs(1) = offsets(ii,jj);
            for itr_rs = 1:lenRad
                tmp1 = targetImg_NaN(w+ii-w:w+ii+w,w+jj-w:w+jj+w , :)...
                           - sourceImg(iis(itr_rs)-w:iis(itr_rs)+w,jjs(itr_rs)-w:jjs(itr_rs)+w , :);
                tmp2 = tmp1(~isnan(tmp1(:)));
                ofs_rs(itr_rs+1) = sum(tmp2.^2)/length(tmp2);
            end

            [~,idx] = min(ofs_rs);
            offsets(ii,jj) = ofs_rs(idx);
            NNF(ii,jj,:) = nns(:,idx);

            if dispProgress((ii-1)*tsz(2)+jj); fprintf('='); end

          end % jj
    end % ii
    fprintf('>\nDone!\n');

end % iteration

debug.offsets{level} = offsets;

end % end of function
