function perimBW = getBWPerimeter(origBW, distance, thickness)
% get perimeter of BW image by dilation, then removal of original connected
% components
% distance - the distance of the perimeter from the original objects. 1 is
% the closest.
% thickness - thickening of the outer perimeter outwards. to not thicken -
% use 1

se_dilate_outer = strel('disk', distance);
se_dilate_inner = strel('disk', distance - 1);
se_dilate_thick = strel('disk', thickness);

im_dilated_outer = imdilate(origBW, se_dilate_outer);
im_dilated_inner = imdilate(origBW, se_dilate_inner);

% remove inner dilated image from dilated outer image (logical operator replaces
% substitution except 0 - 1 = 0). dilated outer image = original image if
% distance == 1
perimBW = im_dilated_outer & ~im_dilated_inner;
perimBW = imdilate(perimBW, se_dilate_thick) & ~im_dilated_outer;

end
