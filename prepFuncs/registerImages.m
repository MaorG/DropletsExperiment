function [refIm, targetIm, refImCropped] = registerImages(ref, target)

% notes:
% refImCropped - returns the mask for the portions of the reference image
% that needs to be cropped because of the manipulations, typically the
% calling function should collect the croppings from the different pairs of
% images that were sent to this function, so in the resulting reference image
% the parts that needs to be cropped are the sum of all these
% ref and target contain three fields: .point, .angle and .img
% example: [~, targetIm, refImCropped] = registerImages(ref, target); %
% (typically the first output argument is not needed because before
% modification all cropped portions need to be collected from refImCropped)

refPoint = ref.point;
tarPoint = target.point;
refAngle = ref.angle;
tarAngle = target.angle;
refIm = ref.img;
targetIm = target.img;

angleToRotate = refAngle - tarAngle;


imBlank = ones(size(refIm));

% older method - still doesn't work properly because rotation is from the center of
% the image - so the rotation entails movement of the point, which modifies
% the imtranslation that needs to be done; it can probably be calculated
% trigonometrically
% this method uses one point and the angle found
%
% targetIm = imrotate(targetIm, angleToRotate, 'crop');
% targetIm = imtranslate(targetIm, [refPoint(1)-tarPoint(1), refPoint(2)-tarPoint(2)]); 
% 
% imCropped1 = imrotate(imBlank, angleToRotate, 'crop'); % matrix where all the 1 pixels are the part left empty after the rotation - have to be deleted from the original image
% imCropped2 = imtranslate(imBlank, [refPoint(1)-tarPoint(1), refPoint(2)-tarPoint(2)]);
% imCropped = ~imBlank;
% imCropped(~(imCropped1 & imCropped2)) = 1;

% newer current method - matlab designated functions
% this method uses two points for each image, so the angle is angle is
% irrelevant
%
R = imref2d(size(refIm)); % object that specifies the size of the resulting image after transformation
% create geometric transformation matrix for the two reference points in
% both images
tform = fitgeotrans([target.point; target.secpoint],[ref.point; ref.secpoint],'nonreflectivesimilarity');
targetIm = imwarp(targetIm, tform, 'OutputView', R);

imCropped = imwarp(~imBlank, tform, 'OutputView', R, 'fillValue', 1);

refIm(imCropped) = 0;
refImCropped = imCropped;

% visualize result
%imtool(cat(3, imwarp(targetIm, tform, 'OutputView', R, 'fillValue', 255), refIm, zeros(size(targetIm))));

end






% for debugging purposes:
% figure;
% subplot(1, 2, 1);
% imshow(zeros(imageSize));
% hold on;
% plotPoints(pA);
% subplot(1, 2, 2);
% imshow(zeros(imageSize));
% hold on;
% plotPoints(pB);
% 
% function plotPoints(p)
% 
% for i = 1 : size(p, 1)
%     curPoint = p(i, :);
%     scatter(curPoint(2), curPoint(1), 'o');
% end
% end
    