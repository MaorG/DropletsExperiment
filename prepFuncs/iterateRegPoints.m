function 

% get the points for each image from an array of an (a x b x 2) dimension,
% where the points for the Nth image are in the N row of (:,:,1) and
% (:,:,2) - so there are 2 points in total for this function for each image

% first image is the reference image, so each each pair of points of an
% image that is sent to the target function is sent with the first pair

arr = em.dm.allData(1).regPoints.points;

radius = 50; % the radius from the first point to choose the second point (towards the direction of the original second point)
% have to be specified but the extra point found will be less relevant at
% the moment, because we only use the angle and the midpoint

imageSize = [455 585];

if (size(arr, 3) ~= 2)
    error('Each image should have two points - so the array has to be of the size a x b x 2');
end

ref = struct;
target = struct; 

% each entry in the third dimension is a different reference point
% for each entry, each row is a point of the ith image
% so, for instance, to get all the points of the first image - iterate all dimensions and get the first row of each one
    
for i = 1 : size(arr, 1)
    a = arr(i, :, 1);
    b = arr(i, :, 2);
    
    % for each image two points a, b (a chosen before b); take middle point and take point
    % extended 'radius' distance from midpoint towards b
    
    [x1,y1] = ginput(1); scatter(x1,y1,'o'); text(x1, y1, num2str([x1 y1])); [x2,y2] = ginput(1); scatter(x2,y2,'o'); text(x2, y2, num2str([x2 y2]))
    
    a = [x1 y1];
    b = [x2 y2];
    
    % get midpoint of line, use that as the first point
    midRow = (a(2) + b(2))/2;
    midCol = (a(1) + b(1))/2;

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
    
    exactAngle
    
    % x_target and y_target not used yet; using the current method it is enough to get the mid point
    % and the angle
    
    
    
    figure;
    imshow(ones(imageSize));
    hold on;    
    
    [x1,y1] = ginput(1); scatter(x1,y1,'o'); text(x1, y1, num2str([x1 y1])); [x2,y2] = ginput(1); scatter(x2,y2,'o'); text(x2, y2, num2str([x2 y2]))
    
    scatter(midCol, midRow, 'o');
    text(midCol, midRow, num2str([midCol midRow]));
    scatter(x_target, y_target, 'o');
    text(x_target, y_target, num2str([x_target y_target]));

    
    for i = 1 : size(p, 1)
        curPoint = p(i, :);
        scatter(x_target, y_target, 'o');
        text(x_target, y_target, num2str([x_target y_target]));
    end
    
    
    % change direction to translate from [x y] to [row col]
    a = a([2 1]);
    b = b([2 1]);
    
    height = diff([a(1) b(1)]);
    
    if (i == 1)
        ref.point = [midCol, midCol];
        ref.angle = exactAngle;
    else
        target.point = [midCol, midRow];
        target.angle = exactAngle;
            
        registerImages(ref, target, imageSize);
    end
end

        





     