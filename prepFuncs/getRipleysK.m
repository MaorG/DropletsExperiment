function res = getRipleysK(data,parameters)

props = parseParams(parameters);

image = data.(props.src);
rbins = props.rbins;
imageSize = size(image);
validPixels = ones(imageSize);



if isfield(data, (props.removedMask)) && ~isempty(data.(props.removedMask))
    validPixels = ~data.(props.removedMask);
end

CC = bwconncomp(image);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);

N = size(centers,1);
gamma = N/sum(validPixels(:));

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
getCountsAndAreasByDistMap(imageSize,centers,N,radii,validPixels)

res = struct;
res.totAreas = totAreas;
res.totCounts = totCounts;
res.rbins = rbins;
res.N = N;
res.validPixelCount = sum(validPixels(:));
end

function [totCounts, totAreas] = getCountsAndAreasByDistMap(imageSize,centers,N,radii)
    
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
    'rbins',[1,2,4,8,16,32,64] ...
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

