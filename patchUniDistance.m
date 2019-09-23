function y=patchUniDistance(nnfpatch)
%nnfpatch:matrix

global N2
[m,n]=size(nnfpatch);
% guass
y=sum(sum(nnfpatch))/N2;
end