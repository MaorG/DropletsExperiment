function [CFU] = classifyCFU(entities, data, parameters)

props = parseParams(parameters);

mask = data.(props.mask);

[H,W] = size(mask);


intensity = data.(props.intensity);
skel = bwmorph(mask,'skel',Inf);

se = strel('disk',1);
erodedMask = imerode(mask,se);

skel = skel & erodedMask;

regions = entities.regions;



variance = zeros(size(regions));
score = zeros(size(regions));

for i=1:numel(regions)
    
    BB = ceil(regions(i).BoundingBox);
    maskBB = mask(BB(2):(BB(2)+BB(4)-1),BB(1):(BB(1)+BB(3)-1));
    maskBB = 0*maskBB;

    
    [x,y] = ind2sub([H,W], regions(i).PixelIdxList);
    xx = x-BB(2)+1;
    yy = y-BB(1)+1;
    idxBB = sub2ind([BB(4),BB(3)], xx,yy);
    
    maskBB(idxBB) = 1;
    
    
    
    
    intensityBB = intensity(BB(2):(BB(2)+BB(4)-1),BB(1):(BB(1)+BB(3)-1));
    skelBB = skel(BB(2):(BB(2)+BB(4)-1),BB(1):(BB(1)+BB(3)-1));

    maxI = max(double(intensityBB).*double(maskBB));
    minI = min(double(intensityBB).*double(maskBB));
    

    normI = double(double(intensityBB) - minI)./double(maxI - minI);
    
    h = fspecial('gaussian', 4, 16);
    smooth2 = imfilter(normI, h);

    MI = double(smooth2);%.*double(maskBB);
    MI = -imhmin(-MI,0.05);
    MIw = watershed(-MI);
    figure(222)
    subplot(3,1,1)
    imagesc(MI.*maskBB )
    subplot(3,1,3)
    imagesc(double(MIw).*maskBB - 1*(~maskBB))
    

    subplot(3,1,2)
    eI = edge(normI,'Canny',0.1)
    imagesc(eI)
    
    score(i) = ~isempty(find(MIw==2,1));
    continue
    
    
    
    SE = fspecial('disk', 4);
    imregionalmax(intensity, SE)
    figure(222)
    histogram(normI(skelBB),[0:0.1:1.0])
    subplot(2,1,2)
    imagesc(normI.*skelBB)
    
    smooth = nan(size(maskBB));
    smooth(skelBB) = normI(skelBB);
    
    h = fspecial('average', 2);
    smooth2 = imfilter(normI, h);
    
%     H = fspecial('average', 2);
%     smooth2 = roifilt2(H,normI,maskBB);
%     smooth3 = imfilter(normI, H);
    
    %smooth2 = imgaussfilt(smooth,2,'FilterDomain', 'spatial');
    
    
    skelVals = max(0,smooth2(skelBB) - normI(skelBB));
    variance(i) = std(double(skelVals))./sqrt(numel(skelVals));
    if sum(skelVals(:)) == 0
        
        variance(i)=0;
    else
        
        variance(i) = max(skelVals(:));
	end

    
    %variance(i) = std(double(skelVals));
   
end

verbose = 1;

tempmap = zeros(size(entities.seg));
if verbose
    for i=1:numel(regions)
        tempmap(regions(i).PixelIdxList) = score(i)+1;
    end


    
    figure;
    cmap = colormap(jet(1000));
    %cmap = cmap(1:900,:);
    cmap(1,:) = [0,0,0];
    imagesc(tempmap)
    colormap(cmap)
    colorbar
    %caxis([0,0.5]);
    
    
end

CFU = [];

end


function props = parseParams(v)
% default:
props = struct(...
    'mask','liveMask',...
    'intensity','DAPIs'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'mask'))
        props.mask = v{i+1};
    elseif (strcmp(v{i}, 'intensity'))
        props.intensity = v{i+1};
    end
end

end
