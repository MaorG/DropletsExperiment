temp
dynamicDensityMap = conv2(dynamic, disk,'same');
figure
imagesc(staticDensityMap)
colorbar
figure
imagesc(dynamicDensityMap)
colorbar
dynamicDensityMap = dynamicDensityMap ./ boundaryFactor;
figure
imagesc(dynamicDensityMap)
colorbar
figure; scatter(staticDensityMap(:), dynamicDensityMap(:), '.r')
R = corrcoef(staticDensityMap(:), dynamicDensityMap(:))
figure
maxS = max(staticDensityMap(:))
maxD = max(dynamicDensityMap(:))
imshow(cat(3,staticDensityMap/maxS,dynamicDensityMap/maxD,0*dynamicDensityMap))
imshow(cat(3,10*staticDensityMap/maxS,10*dynamicDensityMap/maxD,0*dynamicDensityMap))
imshow(cat(3,2*staticDensityMap/maxS,2*dynamicDensityMap/maxD,0*dynamicDensityMap))