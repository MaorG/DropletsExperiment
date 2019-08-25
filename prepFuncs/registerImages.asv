function [refIm, targetIm] = registerImages(refIm, refP, targetIm, targetP, imageSize)

refPoint = refP.point;
tarPoint = targetP.point
refAngle = refP.angle;
tarAngle = targetP.angle;

angleToRotate = refAngle - tarAngle;


imCropped = ones(size(refIm));
imCropped = ~rotate(imCropped, angleToRotate, 'crop'); % matrix where all the 1 pixels are the part left empty after the rotation - have to be deleted from the original image
imCropped = imtranslate(imCropped, [refPoint(1)-tarPoint(1), refPoint(2)-tarPoint(2)]); 

targetIm = imrotate(targetIm, angleToRotate, 'crop');

targetIm = imtranslate(targetIm, [refPoint(1)-tarPoint(1), refPoint(2)-tarPoint(2)]); 

refIm(imCropped) = 0;

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
    