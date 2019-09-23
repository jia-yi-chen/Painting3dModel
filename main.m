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

% Texture synthesis
% tmp = imresize(imread('images/japanese-wallpaper.jpg'), .5);
% A = zeros(size(tmp));
% A_prime = tmp;
% B = zeros(125,125,3);

% Painting
% A = imread('images/rhone-src.jpg');
% A_prime = imread('images/rhone.jpg');
% B = imread('jakarta.jpg');
A_scale = 0.1;
B_scale = 0.1;
A1 = imresize(imread('images/1-all.jpg'), A_scale);
A2 = imresize(imread('images/1-LD12E.jpg'), A_scale);
A3 = imresize(imread('images/1-LDE.jpg'), A_scale);
A4 = imresize(imread('images/1-LSE.jpg'), A_scale);
%[A_m,A_n,c]=size(A1);
A=zeros(size(A1,1),size(A1,2),12,'double');
A(:,:,1:3)=A1;
A(:,:,4:6)=A2;
A(:,:,7:9)=A3;
A(:,:,10:12)=A4;

A_prime = imresize(imread('images/aaaaaaaaa.jpg'), A_scale);

B1 = imresize(imread('images/4-all.jpg'), A_scale);
B2 = imresize(imread('images/4-LD12E.jpg'), A_scale);
B3 = imresize(imread('images/4-LDE.jpg'), A_scale);
B4 = imresize(imread('images/4-LSE.jpg'), A_scale);
B=zeros(size(B1,1),size(B1,2),12,'double');
B(:,:,1:3)=B1;
B(:,:,4:6)=B2;
B(:,:,7:9)=B3;
B(:,:,10:12)=B4;
% 
% A = imresize(A, A_scale);
% A_prime = imresize(A_prime, A_scale);
% B = imresize(B, B_scale);

% Blur
% A = imread('images/newflower-src.jpg');
% A_prime = imread('images/newflower-blur.jpg');
% B = imread('toy-newshore-src.jpg');

% Blur2
% A = imread('images/blurA1.jpg');
% A_prime = imread('images/blurA2.jpg');
% B = imread('images/blurB1.jpg');

% Identity Test
% A = imread('images/IdentityA.jpg');
% A_prime = imread('images/IdentityA.jpg');
% B = imread('IdentityB.jpg');

% %% Emboss Test
% A = imread('images/rose-src.jpg');
% A_prime = imread('images/rose-emboss.jpg');
% B = imread('dandilion-src.jpg');

% TODO: Remove this -- it's just faster for testing.


% Make image analogy
B_prime = create_image_analogy(A, A_prime, B);
imwrite(B_prime,'output/1st.jpg');