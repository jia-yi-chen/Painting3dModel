function [i_bounding,j_bounding,i,j,isBounding]=index2piont(h,w,index,bound_width)
%h,w是加了bounding后的
%bound_width=2    (5*5)
isBounding=0;
i=0;
j=0;

[i_bounding,j_bounding]=ind2sub([h,w],index);


if i_bounding <= bound_width || j_bounding <= bound_width || i_bounding >= h-bound_width || j_bounding >=w-bound_width
        isBounding=1;
        i=i_bounding-bound_width;
        j=j_bounding-bound_width;
     return
end
 
 
end