global N_BIG;
global N_SMALL;
global NUM_FEATURES;
global NNF;
global nnf;
global A;
global B;
global kappa;
global G_big;
global G_small;
global end_idx;
tic
% Neightborhood size and num features
N_BIG = 5;
N_SMALL = 3;
NUM_FEATURES = 1;
NNF = N_BIG * N_BIG * NUM_FEATURES;
nnf = N_SMALL * N_SMALL * NUM_FEATURES;
% end_idx = 12;
end_idx = sub2ind([N_BIG N_BIG], 2, 3);
% end_idx = sub2ind([N_BIG N_BIG], 2, 2);

kappa = 3;

G_big = fspecial('Gaussian', [N_BIG N_BIG]);

%G_big = (G_big + ones(5))/2;

G_small = fspecial('Gaussian', [N_SMALL N_SMALL]);

% Read images

% Texture transfer
% A = imread('transfer2_A1.jpg');
% A_prime = imread('transfer2_A2.jpg');
% B = imread('transfer2_B1.jpg');

global SaveFolderName
SaveFolderName= datestr(now,'yymmdd-HHMMSS');
mkdir('results',SaveFolderName);

diary(fullfile('results',SaveFolderName,'log.txt'));

A_scale = 1;%0.8   L=3
B_scale =1;
A1 = imresize(imread('images/2.png'), A_scale);
A2 = imresize(imread('images/2.png'), A_scale);
A3 = imresize(imread('images/2.png'), A_scale);
A4 = imresize(imread('images/2.png'), A_scale);
A5 = imresize(imread('images/2.png'), A_scale);
A6 = imresize(imread('images/2.png'), A_scale);
A7 = imresize(imread('images/2.png'), A_scale);
%[A_m,A_n,c]=size(A1);
A=cat(3,A1,A2,A3,A4,A5,A6,A7);

A_prime = imresize((imread('images/monnalisa.jpg')), A_scale);

% B1 = imresize(imread('images/5-B-1.jpg'), A_scale);
% B2 = imresize(imread('images/5-B-3.jpg'), A_scale);
% B3 = imresize(imread('images/5-B-2.jpg'), A_scale);
% B4 = imresize(imread('images/5-B-4.jpg'), A_scale);
% B5 = imresize(imread('images/5-B-5.jpg'), A_scale);
% B6 = imresize(imread('images/5-B-6.jpg'), A_scale);
% B7 = imresize(imread('images/5-B-7.jpg'), A_scale);
B1 = imresize(imread('images/1.png'), A_scale);
B2 = imresize(imread('images/1.png'), A_scale);
B3 = imresize(imread('images/1.png'), A_scale);
B4 = imresize(imread('images/1.png'), A_scale);
B5 = imresize(imread('images/1.png'), A_scale);
B6 = imresize(imread('images/1.png'), A_scale);
B7 = imresize(imread('images/1.png'), A_scale);
% B=zeros(size(B1,1),size(B1,2),12,'double');
% B(:,:,1:3)=B1;
% B(:,:,4:6)=B2;
% B(:,:,7:9)=B3;
% B(:,:,10:12)=B4;
B=cat(3,B1,B2,B3,B4,B5,B6,B7);

% Make image analogy
[B_prime_pyramid,B_prime_pyramid_ini,debug ] = create_image_analogy_LPE(A, A_prime, B);
toc