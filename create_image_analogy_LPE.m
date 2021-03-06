function [ B_prime_pyramid,B_prime_pyramid_ini,debug ] = create_image_analogy_LPE( A, A_prime, B )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global N_BIG;
global NUM_FEATURES;
global NNF;
global SaveFolderName;
[B_height, B_width, ~] = size(B);
[A_height, A_width, ~] = size(A);

%% Create luminance maps
% A = rgb2ntsc(A);
% A_prime = rgb2ntsc(A_prime);
% B = rgb2ntsc(B);

%% Construct Gaussian pyramids for A, A' and B
A_pyramid = {A};
A_prime_pyramid = {A_prime};
B_pyramid = {B};
B_prime_pyramid = {zeros(size(A_prime,1),size(A_prime,2),3)};
B_prime_pyramid_ini = {zeros(size(A_prime,1),size(A_prime,2),3)};

L=6;
min_size=0.2;
scale_factor=(1-min_size)/(L-1);
% Was 50, 50
for k=1:L-1
  scaledsize= [floor(size(A_pyramid{1},1)*(min_size+scale_factor*(L-k-1))) floor(size(A_pyramid{1},2)*(min_size+scale_factor*(L-k-1)))];
  A_pyramid{end+1} = imresize(A_pyramid{1}, scaledsize);
  A_prime_pyramid{end+1} = imresize(A_prime_pyramid{1}, scaledsize);
  B_pyramid{end+1} = imresize(B_pyramid{1},scaledsize);
  B_prime_pyramid{end+1} = imresize(B_prime_pyramid{1}, scaledsize);
  B_prime_pyramid_ini{end+1} = imresize(B_prime_pyramid_ini{1}, scaledsize);
  
%   [A_height, A_width, ~] = size(A_pyramid{end});
end

% L = size(A_pyramid, 2);

% Extended pyramids, for ANN only
A_pyramid_extend = cell(L);
B_pyramid_extend = cell(L);


% [B_extend_h, B_extend_w, ~] = size(B_pyramid_extend{1});

for l=1:L   %����0-255
%   A_pyramid_extend{l} = extend_image_LPE(A_pyramid{l}, 0, 1);
%   B_pyramid_extend{l} = extend_image_LPE(B_pyramid{l}, 0,1);
%  A_pyramid_extend{l} = cat(3,A_pyramid{l}(:,:,4),rgb2gray(A_pyramid{l}(:,:,1:3)),rgb2gray(A_pyramid{l}(:,:,10:12)),rgb2gray(A_pyramid{l}(:,:,4:6)),rgb2gray(A_pyramid{l}(:,:,7:9)),rgb2gray(A_pyramid{l}(:,:,13:15)),rgb2gray(A_pyramid{l}(:,:,19:21)));
  A_pyramid_extend{l} = cat(3,A_pyramid{l}(:,:,1),...
                                                 A_pyramid{l}(:,:,2),...
                                                 A_pyramid{l}(:,:,3),...
                                                 A_pyramid{l}(:,:,4),...
                                                 A_pyramid{l}(:,:,5),...
                                                 A_pyramid{l}(:,:,6),...
                                                 A_pyramid{l}(:,:,7),...
                                                 A_pyramid{l}(:,:,8),...
                                                 A_pyramid{l}(:,:,9),...
                                                 A_pyramid{l}(:,:,10),...
                                                 A_pyramid{l}(:,:,11),...
                                                 A_pyramid{l}(:,:,12),...
                                                 A_pyramid{l}(:,:,13),...
                                                 A_pyramid{l}(:,:,14),...
                                                 A_pyramid{l}(:,:,15),...
                                                 A_pyramid{l}(:,:,16),...
                                                 A_pyramid{l}(:,:,17),...
                                                 A_pyramid{l}(:,:,18),...
                                                 A_pyramid{l}(:,:,19),...
                                                 A_pyramid{l}(:,:,20),...
                                                 A_pyramid{l}(:,:,21));
%  B_pyramid_extend{l} = cat(3,B_pyramid{l}(:,:,4),rgb2gray(B_pyramid{l}(:,:,1:3)),rgb2gray(B_pyramid{l}(:,:,10:12)),rgb2gray(B_pyramid{l}(:,:,4:6)),rgb2gray(B_pyramid{l}(:,:,7:9)),rgb2gray(B_pyramid{l}(:,:,13:15)),rgb2gray(B_pyramid{l}(:,:,19:21)));
  B_pyramid_extend{l} = cat(3,B_pyramid{l}(:,:,1),...
                                                 B_pyramid{l}(:,:,2),...
                                                 B_pyramid{l}(:,:,3),...
                                                 B_pyramid{l}(:,:,4),...
                                                 B_pyramid{l}(:,:,5),...
                                                 B_pyramid{l}(:,:,6),...
                                                 B_pyramid{l}(:,:,7),...
                                                 B_pyramid{l}(:,:,8),...
                                                 B_pyramid{l}(:,:,9),...
                                                 B_pyramid{l}(:,:,10),...
                                                 B_pyramid{l}(:,:,11),...
                                                 B_pyramid{l}(:,:,12),...
                                                 B_pyramid{l}(:,:,13),...
                                                 B_pyramid{l}(:,:,14),...
                                                 B_pyramid{l}(:,:,15),...
                                                 B_pyramid{l}(:,:,16),...
                                                 B_pyramid{l}(:,:,17),...
                                                 B_pyramid{l}(:,:,18),...
                                                 B_pyramid{l}(:,:,19),...
                                                 B_pyramid{l}(:,:,20),...
                                                 B_pyramid{l}(:,:,21));
end


fprintf('Finding best match...\n\n');

%% Main loop, find the best match

% TODO: doing single scale for quicker testin right now -- remove this
% line.
% L = 1;

psz = 5;
w = (psz-1)/2;
NNF_pre=[];
debug={};
for l = L:-1:1
      fprintf('\nl: %d/%d\n===========\n', l, L);
      % Loop over B'
      B_prime_sz = size(B_pyramid_extend{l});
% 
      [NNF_l, debug]=PatchMatch_LPE(B_pyramid_extend,A_pyramid_extend,l,L,NNF_pre,debug,psz);
      NNF_pre=NNF_l;

%        [NNF_l, debug]=PatchMatch_LPE_uniform(B_pyramid_extend,A_pyramid_extend,l,L,NNF_pre,debug,psz);
%        NNF_pre=NNF_l;
%        imshow(debug.source_used/10)

%        fprintf('Reconstructing Initial NNF Image... ');
%         for ii = (1+w):psz:B_prime_sz(1)-w
%             for jj = (1+w):psz:B_prime_sz(2)-w
%                 temp_i=debug.NNF_ini{l}(ii,jj,1)-w:debug.NNF_ini{l}(ii,jj,1)+w;
%                 temp_j=debug.NNF_ini{l}(ii,jj,2)-w:debug.NNF_ini{l}(ii,jj,2)+w;
%                 B_prime_pyramid_ini{l}(ii-w:ii+w,jj-w:jj+w,:)...
%                     = A_prime_pyramid{l}(...
%                       temp_i,...
%                        temp_j,...
%                        :);
%             end
%         end
%         fprintf('Done!\n');


        fprintf('Reconstructing Output Image... ');
        for ii = (1+w):1:B_prime_sz(1)-w
            for jj = (1+w):1:B_prime_sz(2)-w
                B_prime_pyramid{l}(ii,jj,:) ...
                    =  A_prime_pyramid{l}(NNF_l(ii,jj,1),NNF_l(ii,jj,2),:);
            end
        end
        fprintf('Done!\n'); 
% 
%         fprintf('Reconstructing Output Image... ');
%         for ii = (1+w):1:B_prime_sz(1)-w
%             for jj = (1+w):1:B_prime_sz(2)-w
%                 B_prime_pyramid{l}(ii,jj,:) ...
%                    =  mean(mean(A_prime_pyramid{l}(NNF_l(ii,jj,1)-w:NNF_l(ii,jj,1)+w,NNF_l(ii,jj,2)-w:NNF_l(ii,jj,2)+w,:)));
% %=  A_prime_pyramid{l}(NNF_l(ii,jj,1),NNF_l(ii,jj,2),:);
%             end
%         end
%         fprintf('Done!\n');    
        
%         
%         fprintf('Reconstructing Output Image... ');
%         for ii = (1+w):psz:B_prime_sz(1)-w
%             for jj = (1+w):psz:B_prime_sz(2)-w
%                 B_prime_pyramid{l}(ii-w:ii+w,jj-w:jj+w,:) ...
%                     =  A_prime_pyramid{l}(NNF_l(ii,jj,1)-w:NNF_l(ii,jj,1)+w,NNF_l(ii,jj,2)-w:NNF_l(ii,jj,2)+w,:);
%             end
%         end
%         fprintf('Done!\n');
        figure;
        imshow(B_prime_pyramid{l}/255);

        reconstImg = uint8(B_prime_pyramid{l});
        reconstImg_ini = uint8(B_prime_pyramid_ini{l});
        imwrite(reconstImg_ini,fullfile('results',SaveFolderName,strcat('B_prime_ini',num2str(l),'.bmp')),'BMP');
        imwrite(reconstImg,fullfile('results',SaveFolderName,strcat('B_prime_level',num2str(l),'.bmp')),'BMP');


end
B_prime = B_prime_pyramid{1};
%figure(1),imshow(B_prime/255);
% for l=L:-1:1
%     reconstImg = uint8(B_prime_pyramid{l});
%     reconstImg_ini = uint8(B_prime_pyramid_ini{l});
%     imwrite(reconstImg_ini,fullfile('results',SaveFolderName,strcat('B_prime_ini',num2str(l),'.bmp')),'BMP');
%     imwrite(reconstImg,fullfile('results',SaveFolderName,strcat('B_prime_level',num2str(l),'.bmp')),'BMP');
% 
% end
% imwrite(debug.source_used/max(max(debug.source_used)),fullfile('results',SaveFolderName,strcat('source_used',num2str(l),'.bmp')),'BMP');
end  
