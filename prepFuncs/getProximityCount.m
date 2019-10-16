function [res] = getProximityCount(data, parameters)

props = parseParams(parameters);

static = data.(props.static);
dynamic = data.(props.dynamic);

pixelSize = data.properties.pixelSize;
repeats = props.repeats;
windowSize = props.windowSize;

bothByDistanceExp = [];
bothByDistanceRnd = [];
for ws = windowSize
    
    disk = getDisk(ceil(ws / pixelSize));
    
    if strcmp(props.mode, 'binary')
        allRndDC = [];
        expDC = getDensityCorrBinaryAux(static, dynamic, disk);
        
        dynamicEntities = getPropsForSeg(dynamic);
        for ri = 1:repeats
            disp(['randomized ' , num2str(ri)])
            tic
            dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props);
            toc
            disp(['DC ' , num2str(ri)])
            tic
            rndDC = getDensityCorrBinaryAux(static, dynamicRandomized, disk);
            toc
            allRndDC = [allRndDC, rndDC];
            disp([' '])
            disp([' --- '])
        end
        
%         figure;
%         
%         hold on
%         
         bothR = cat(1, allRndDC.both);
         onlySR = cat(1, allRndDC.onlyS);
         onlyDR = cat(1, allRndDC.onlyD);
         noneR = cat(1, allRndDC.none);
%         
%         scatter(ws*ones(size(bothR)), bothR,'r+')
%         %    scatter(windowSize*ones(size(bothR)), onlySR,'rs')
%         %    scatter(windowSize*ones(size(bothR)), onlyDR,'rd')
%         %    scatter(windowSize*ones(size(bothR)), noneR,'rx')
%         
%         scatter(ws, expDC.both,'b+')
%         %    scatter(windowSize, expDC.onlyS,'bs')
%         %    scatter(windowSize, expDC.onlyD,'bd')
%         %    scatter(windowSize, expDC.none,'bx')
        
        
    end
    
    bothByDistanceRnd = cat(2,bothByDistanceRnd, bothR);
    bothByDistanceExp = cat(2,bothByDistanceExp, expDC.both);
    
end

% figure
% hold on;
% for wi = 1:numel(windowSize)
%         scatter(windowSize(wi)*ones(size(bothByDistanceRnd(:,wi))), bothByDistanceRnd(:,wi),'ro');
%         scatter(windowSize(wi), bothByDistanceExp(wi),'bo');
% end
% res = struct;

res.windowSize = windowSize;
res.bothByDistanceRnd = bothByDistanceRnd;
res.bothByDistanceExp = bothByDistanceExp;

end

function res = getDensityCorrBinaryAux(static, dynamic, disk)

staticD = conv2(static, disk,'same');
% dynamicD = conv2(dynamic, disk,'same');
% 
% res = struct;
% res.both = sum(staticD & dynamicD, 'all');
% res.onlyS = sum(staticD & ~dynamicD, 'all');
% res.onlyD = sum(~staticD & dynamicD, 'all');
% res.none = sum(~staticD & ~dynamicD, 'all');

res = struct;
res.both = sum(staticD & dynamic, 'all');
res.onlyS = sum(staticD & ~dynamic, 'all');
res.onlyD = sum(~staticD & dynamic, 'all');
res.none = sum(~staticD & ~dynamic, 'all');

end



function props = getPropsForSeg(im)

CC = bwconncomp(im);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);
pixels = cell(numel(rp),1);
pixelsidx = cell(numel(rp),1);
for ii = 1:numel(rp)
    pixels{ii} = rp(ii).PixelList;
    pixelsidx{ii} = rp(ii).PixelIdxList;
end
areas = cat(1, rp.Area);

% from array of structs to struct of arrays...

props = struct;
props.centers = centers;
props.areas = areas;
props.pixels = pixels;
props.pixelsidx = pixelsidx;

end




function props = parseParams(v)
% default:
props = struct(...
    'static','BF',...
    'dynamic','GFP',...
    'windowSize',2, ...
    'repeats',10, ...
    'confidence__', 0.05, ...
    'staticOverlap', 0, ...
    'dynamicOverlap', 0, ...
    'mode', 'binary', ...
    'verbose', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'windowSize'))
        props.windowSize = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    elseif (strcmp(v{i}, 'binary'))
        props.binary = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
        
    end
end

end

