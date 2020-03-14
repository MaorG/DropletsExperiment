function res = getRipleysK2(data,parameters)

props = parseParams(parameters);

image = data.(props.src);
rbins = props.rbins;
imageSize = size(image);
validPixels = ones(imageSize);
imageArea = imageSize(1) * imageSize(2);

repeats = 10;


if isfield(data, (props.removedMask)) && ~isempty(data.(props.removedMask))
    validPixels = ~data.(props.removedMask);
end

CC = bwconncomp(image);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);

N = size(centers,1);

rk = calcRipleysK(centers, imageArea,rbins)

rkrnds = [];
for i = 1:repeats
    rcenters = rand(size(centers));
    rcenters(:,1) = rcenters(:,1)*imageSize(1);
    rcenters(:,2) = rcenters(:,2)*imageSize(2);
    rkrnd = calcRipleysK(rcenters, imageArea,rbins);
    rkrnds = [rkrnds; rkrnd];
end


figure;

hold on
for i = 1:repeats
    plot(rbins*data.parameters.pixelSize,rkrnds(i,:),'r'); 
end
plot(rbins*data.parameters.pixelSize,rk,'b');
title([data.parameters.well, ' ' num2str(data.parameters.time)]);
res = struct;
res.rk = rk;
res.rkrnds = rkrnds;
res.bins = rbins;

end

function res = calcRipleysK(centers, imageArea, distBins)


N = size(centers,1);
distances = nan(N,N);
for i = 1:N
    for j = 1:N
        if (i~=j)
            center1 = centers(i,:);
            center2 = centers(j,:);
            distances(i,j) = sqrt( ((center1(1)-center2(1))^2) + ((center1(2)-center2(2))^2));
        end
    end
end

distances = sort(distances(:));
distances = distances(~isnan(distances));

%distBins = 1:6:600;

kfunc = nan(size(distBins));

for i = 1:numel(distBins)-1
    kfunc(i) = imageArea*sum(distances <= distBins(i+1) & distances > distBins(i)) / ( (N*N) * pi*(distBins(i+1)^2 - distBins(i)^2) );
%    kfunc(i) = imageArea*sum(distances <= distBins(i))/(N*N);
end
res = kfunc;
return;
lfunc = sqrt(kfunc/pi);
pfunc = lfunc - distBins;
res = pfunc;
figure;
hold on
plot(distBins, pfunc);
return;

centersImage = zeros(imageSize);
for i = 1:N
    center = centers(i,:);
    cx = ceil(center(1));
    cx = min(max(1,cx),imageSize(2));
    cy = ceil(center(2));
    cy = min(max(1,cy),imageSize(1));
    centersImage(cy,cx) = 1;
end

radii = rbins./data.properties.pixelSize;

% by the dist map
[totCounts, totAreas] = getCountsAndAreasByDistMap(imageSize,centers,centersImage,N,radii,validPixels)

res = struct;
res.totAreas = totAreas;
res.totCounts = totCounts;
res.rbins = rbins;
res.N = N;
res.validPixelCount = sum(validPixels(:));
end

function [totCounts, totAreas] = getCountsAndAreasByDistMap(imageSize,centers,centersImage,N,radii,validPixels)
    
totCounts = nan(N,numel(radii));
totAreas = nan(N,numel(radii));

for i = 1:N
    
    i
    
    
    distMapPerp = zeros(imageSize);
    center = centers(i,:);
    cx = ceil(center(1));
    cx = min(max(1,cx),imageSize(2));
    cy = ceil(center(2));
    cy = min(max(1,cy),imageSize(1));
    distMapPerp(cy,cx) = 1;
    
    %     distMap = bwdist(distMapPerp);
    %     distMap(~validPixels) = inf;
    
    X = (1:imageSize(2)) - cx;
    Y = (1:imageSize(1)) - cy;
    
    [XX,YY] = meshgrid(X,Y);
    RR = XX.^2 + YY.^2;
    
    for ri = 1:(numel(radii)-1)
        
        r1 = radii(ri);
        r2 = radii(ri+1);
        
        
        RRmask = (RR >= (r1^2) & RR <= (r2^2));
        
        totArea = sum(RRmask(:)&validPixels(:));
        totCount = sum(sum(RRmask&centersImage));
        
        totCounts(i,ri) = totCount;
        totAreas(i,ri) = totArea;
    end
    
end

end

function props = parseParams(v)
% default:
props = struct(...
    'src','GFP',...
    'removedMask','removed',...
    'rbins',[1:120] ...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'removedMask'))
        props.removedMask = v{i+1};
    elseif (strcmp(v{i}, 'rbins'))
        props.rbins = v{i+1};
    end
end

end

