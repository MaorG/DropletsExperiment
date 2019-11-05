function [allresults] = getDensityDist(data, parameters)


props = parseParams(parameters);

pixelSize = data.properties.pixelSize;
radius = props.radius ./ pixelSize;
allres = [];
for ri = 1:numel(radius)
   
    res = struct;
    res.radius = radius(ri);
    res.res = getDensityDistAux(data, parameters, res.radius);
    allres = cat(1,allres,res);
end

allresults = struct;
allresults.pool = allres;

end

function [res] = getDensityDistAux(data, parameters, radius)


props = parseParams(parameters);

static = data.(props.static);
dynamic = data.(props.dynamic);

repeats = props.repeats;


% delete: moved to visualization
% distanceBins = props.distanceBins;
% confidence = props.confidence;

% analyze experimental data


disk = getDisk(radius);

boundaryFactor = conv2(ones(size(static)), disk, 'same');
%boundaryFactor = sum(disk(:))*ones(size(static));

staticDensityMap = conv2(static, disk,'same');
dynamicDensityMap = conv2(dynamic, disk,'same');

staticDensityMap = staticDensityMap ./ boundaryFactor;
dynamicDensityMap = dynamicDensityMap ./ boundaryFactor;

%expDensities = getDensityDistByBins(staticDensityMap , dynamicDensityMap, props);

[Ndyn,B] = histcounts(dynamicDensityMap,props.bins);
%[Ndyn,~,~] = histcounts2(dynamicDensityMap, staticDensityMap, props.bins, props.bins);

% doing once, saving time
dynamicEntities = getPropsForSeg(dynamic);

B = props.bins(1:end-1)
if props.verbose
    figure
    hold on;
end

% does the thing
for ri = 1:repeats
    disp(['randomized ' , num2str(ri)])
    tic 
    dynamicRandomized = getDynamicRandomized(static, dynamicEntities, props);
    toc
    disp(['NN ' , num2str(ri)])
    tic 
    dynamicRandomized(dynamicRandomized~=0) = 1;
    dynamicRandomizedDensityMap = conv2(dynamicRandomized, disk,'same');
    dynamicRandomizedDensityMap  = dynamicRandomizedDensityMap ./ boundaryFactor;

    [rndDist, ~] = histcounts(dynamicRandomizedDensityMap, props.bins);
    %[rndDist, ~, ~] = histcounts2(dynamicRandomizedDensityMap, staticDensityMap, props.bins, props.bins);
    toc
    allRndDensities{ri} = rndDist;
    disp([''])

    
    if  props.verbose
        plot(props.bins(1:end-1), rndDist, 'r')
%        [XX,YY] = meshgrid(B, B);
%        surf(XX,YY,rndDist, 'FaceAlpha',0.0, 'EdgeColor', 'none', 'FaceColor', [0.5,0.5,0.5])
%        surf(XX,YY,rndDist, 'FaceAlpha',0.0, 'EdgeColor', 'none');
        
%         figure
%         [XX,YY] = meshgrid( B,B);
%         %surf(XX,YY,Ndyn, 'FaceAlpha',0.5, 'EdgeColor', 'none', 'FaceColor', [0.0,0.5,0.0])
%         surf(XX,YY,rndDist, 'FaceAlpha',1.0, 'EdgeColor', 'none', 'FaceColor', 'interp');
%         hold on;
    end
   
    
end

if props.verbose
    plot(props.bins(1:end-1), Ndyn, 'b', 'LineWidth', 2)
        figure;
        %[XX,YY] = meshgrid( B,B);
        %surf(XX,YY,Ndyn, 'FaceAlpha',0.5, 'EdgeColor', 'none', 'FaceColor', [0.0,0.5,0.0])
        %surf(XX,YY,Ndyn, 'FaceAlpha',1.0, 'EdgeColor', 'none', 'FaceColor', 'interp');


end
res = struct;

res.bins = props.bins;
res.Nexp = Ndyn;
res.Nrnd = allRndDensities;

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
    'bins', [0:0.001:1], ...
    'radius', 5,...
    'repeats',10, ...
    'confidence__', 0.05, ...
    'mode', 'edge', ...
    'staticOverlap', 0, ...
    'dynamicOverlap', 0, ...
    'verbose', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'static'))
        props.static = v{i+1};
    elseif (strcmp(v{i}, 'dynamic'))
        props.dynamic = v{i+1};
    elseif (strcmp(v{i}, 'radius'))
        props.radius = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'bins'))
        props.bins = v{i+1};
    elseif (strcmp(v{i}, 'confidence'))
        props.confidence = v{i+1};
    elseif (strcmp(v{i}, 'mode'))
        props.mode = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
        
    end
end

end
