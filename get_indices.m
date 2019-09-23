function [ start_i, end_i, start_j, end_j, ...
  pad_top, pad_bot, pad_left, pad_right, flag] = get_indices( i, j, N, h, w)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

border = floor(N/2);

% if N == 3 && (i < N || i > h-N || j < N || j > w-N)
%   start_i = 0; end_i = 0; start_j = 0; end_j = 0;
%   pad_top = 0; pad_bot = 0; pad_left = 0; pad_right = 0;
%   flag = true;
%   return
% end

i_top = i-border;
pad_top = 1;
if i_top < 1
  start_i = 1;
  pad_top = 2 - i_top;
else
  start_i = i_top;
end

i_bot = i+border;
pad_bot = N;
if i_bot > h
  pad_bot = N-(i_bot-h);
  end_i = h;
else
  end_i = i_bot;
end


j_left = j - border;
pad_left = 1;
if j_left < 1
  start_j = 1;
  pad_left = 2 - j_left;
else
  start_j = j_left;
end

j_right = j + border;
pad_right = N;
if j_right > w
  end_j = w;
  pad_right = N-(j_right-w);
else
  end_j = j_right;
end

flag = false;

end

