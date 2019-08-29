function [newImgs] = iterateRegPoints(imgs, regPoints)

% get the points for each image from an array of an (a x b x 2) dimension,
% where the points for the Nth image are in the N row of (:,:,1) and
% (:,:,2) - so there are 2 points in total for this function for each image

% first image is the reference image, so each each pair of points of an
% image that is sent to the target function is sent with the first pair

% regPoints = em.dm.allData(1).regPoints.points; % for debugging

% regPoints structure:
% each entry in the third dimension is a different referenced point (a
% reference point is a set of points for a set of images that points to the
% same physical location)
% for each such entry, each row is a point of the ith image
% so, for instance, to later get all the points of the first  image - iterate all dimensions and get the first row of each one
    

radius = 50; % the radius from the first point to choose the second point (towards the direction of the original second point)
% have to be specified but the extra point found will be less relevant at
% the moment, because we only use the angle and the midpoint

%imageSize = [455 585]; % for debugging
imageSize = size(imgs{1}); % all images have to be of the same size

if (size(regPoints, 3) ~= 2)
    error('Each image should have two points - so the array has to be of the size a x 2 x 2 (middle 2 is for [x y] coordinates)');
end
if (size(regPoints, 1) < 2)
    error('There should be at least two images - so the a in the array a x 2 x 2 has to be 2 by minimum');
end

ref = struct;
target = struct; 

newImgs = {[]};

refImCroppedTotal = logical(zeros(imageSize));

% each entry in the third dimension is a different reference point
% for each entry, each row is a point of the ith image
% so, for instance, to get all the points of the first image - iterate all dimensions and get the first row of each one
    
for i = 1 : size(regPoints, 1)
    
    curImg = imgs{i};
    
    a = regPoints(i, :, 1);
    b = regPoints(i, :, 2);
    
    % for each image two points a, b (a chosen before b); take middle point and take point
    % extended 'radius' distance from midpoint towards b
    
    % for debugging: choosing points on a blank image to test calculations
    % of midpoint, extended point and angle
%     figure;
%     imshow(ones(imageSize));
%     hold on;    
%     [x1,y1] = ginput(1); scatter(x1,y1,'o'); text(x1, y1, num2str([x1 y1])); [x2,y2] = ginput(1); scatter(x2,y2,'o'); text(x2, y2, num2str([x2 y2])) 
%     a = [x1 y1];
%     b = [x2 y2];

    % get midpoint of line, use that as the first point
    midRow = (a(2) + b(2))/2;
    midCol = (a(1) + b(1))/2;

    % get equation for the two points
    [slope, intercept] = eqTwoPoints([midCol midRow], b);
    angle = atan(slope);
    if (abs(slope) == Inf)
        x_target = midCol;
        y_target = midRow;
        if (a(2) < b(2))
            y_target = y_target + radius;
            exactAngle = 270;
        else
            y_target = y_target - radius;
            exactAngle = 90;
        end
    else
        x_dist = cos(angle) * radius;
        if (a(1) < b(1)) % if first point is lower than the second point, then the target point with radius distance is between them - use addition to midpoint
            x_target = midCol + x_dist;
            exactAngle = mod(360 - radtodeg(angle), 360);
        else % otherwise, it's in the opposite direction - subtract from midpoint
            x_target = midCol - x_dist;
            exactAngle = 180 - radtodeg(angle);
        end
        % find y_target from equation using x_target
        y_target = slope * x_target + intercept;
        %x_target = cutToRange(round(x_target), [1 imageSize(2)]);
        %y_target = cutToRange(round(y_target), [1 imageSize(1)]);
    end
    
    % x_target and y_target not used yet; using the current method it is enough to get the mid point
    % and the angle
    
    
    %for debugging: plotting the mid point and extended point found
%     scatter(midCol, midRow, 'o');
%     text(midCol, midRow, num2str([midCol midRow]));
%     scatter(x_target, y_target, 'o');
%     text(x_target, y_target, num2str([x_target y_target]));

    
    
%     % change direction to translate from [x y] to [row col] (the following commented portion is irrelevant)
%     a = a([2 1]);
%     b = b([2 1]);
%     height = diff([a(1) b(1)]);
    
    if (i == 1)
        ref.point = [midCol, midRow];
        ref.angle = exactAngle;
        ref.secpoint = [x_target y_target];
        ref.img = curImg;
        
    else
        target.point = [midCol, midRow];
        target.angle = exactAngle;
        target.secpoint = [x_target y_target];
        target.img = curImg;
        
        [~, targetIm, refImCropped] = registerImages(ref, target);
        
        refImCroppedTotal = refImCroppedTotal | refImCropped;
        
        newImgs = [newImgs, targetIm];
        
    end
    
end


resultRefImg = ref.img;
resultRefImg(refImCroppedTotal) = 0;

newImgs{1} = resultRefImg;


end
        





     