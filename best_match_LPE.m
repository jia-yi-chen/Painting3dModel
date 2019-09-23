function [ best_i, best_j ] = best_match_LPE( A_pyramid, A_prime_pyramid, B_pyramid, B_prime_pyramid,...
  s_pyramid, A_features, B_features, l, L,height_B, width_B)
%BEST_MATCH ...

global kappa;

[best_app_i, best_app_j] = best_approximate_match_LPE(A_features, A_pyramid, ...
  B_pyramid, B_features, l,height_B, width_B);

[hB, wB, ~] = size(B_pyramid{l});
[hA, wA, ~] = size(A_pyramid{l});



kB=1;
for j=1:wB
    for i=1:hB
%          [tempi,tempj,temp_isBounding]=index2point(hB,wB,kB,2);
         
         [tempi,tempj,~,~,~]=index2piont(hA,wA,best_app_i(kB),2);
         kB=kB+1;
         s_pyramid{l}(i,j,1)=tempi;
         s_pyramid{l}(i,j,2)=tempj;

    end
end
% if i <= 4 || j <= 4 || i >= h-4 || j >=w-4
%   best_i = best_app_i;
%   best_j = best_app_j;
%   return
% end
for j=1:wB
    for i=1:hB
        [best_coh_i, best_coh_j] = best_coherence_match_LPE(A_pyramid, A_prime_pyramid, ...
  B_pyramid, B_prime_pyramid, s_pyramid, l, L,i, j);
    end
end

if best_coh_i == -1 || best_coh_j == -1
  best_i = best_app_i;
  best_j = best_app_j;
  return
end

F_p_app = concat_feature(A_pyramid, A_prime_pyramid, l, ...
  best_app_i, best_app_j, L);

F_p_coh = concat_feature(A_pyramid, A_prime_pyramid, l, best_coh_i, best_coh_j, L);

F_q = concat_feature(B_pyramid, B_prime_pyramid, l, i, j, L);

d_app = sum((F_p_app(:) - F_q(:)).^2);
d_coh = sum((F_p_coh(:) - F_q(:)).^2);

if d_coh <= d_app * (1 + 2^(l - L)*kappa)
  best_i = best_coh_i;
  best_j = best_coh_j;
else
  best_i = best_app_i;
  best_j = best_app_j;
end

end

