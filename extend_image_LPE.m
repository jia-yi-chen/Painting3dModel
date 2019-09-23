function [ result ] = extend_image_LPE( image, border, layers )
%EXTEND_IMAGE Extend the borders of the image by ext_size

% global NUM_FEATURES;

border = floor(border);
[h, w, ~] = size(image);
result = zeros(h + 2 * border, w + 2 * border,size(layers,2));

% Put original pic in center
for i=1:size(layers,2)
    result(border+1:end-border, border+1:end-border,i) = image(:,:,layers(i));
    
    % We just want to leave it as 0's so it doesn't add any weight
    
    % Fill in borders
    result(1:border, border+1:end-border,i) = repmat(image(1,:,layers(i)), border, 1);
    result(end-border+1:end, border+1:end-border,i) = repmat(image(end,:,layers(i)),border, 1);
    result(border+1:end-border, 1:border,i) = repmat(image(:,1,layers(i)),1, border);
    result(border+1:end-border, end-border+1:end,i) = repmat(image(:,end,layers(i)),1, border);
    
    % Fill in corners
    result(1:border,1:border,i) = repmat(image(1,1,layers(i)), border, border);
    result(1:border,end-border+1:end,i) = repmat(image(1,end,layers(i)), border, border);
    result(end-border+1:end,1:border,i) = repmat(image(end,1,layers(i)), border, border);
    result(end-border+1:end,end-border+1:end,i) = repmat(image(end,end,layers(i)), border, border);
end
% subplot(1,2,1);
% imshow(uint8(image));
% subplot(1,2,2);
% imshow(uint8(result));

end

