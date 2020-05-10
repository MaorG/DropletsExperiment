function res = getTwoPointCrossCorrMG(data,parameters)

props = parseParams(parameters);

imageDynamic = data.(props.srcDynamic);
imageStatic = data.(props.srcStatic);
dr = props.dr;

margin = 100;

CC = bwconncomp(imageDynamic);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centersOrigDynamic = cat(1, rp.Centroid);
CC = bwconncomp(imageStatic);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centersOrigStatic = cat(1, rp.Centroid);

xs = centersOrigStatic(:,1);
ys = centersOrigStatic(:,2);


dynamicEntities = getPropsForSeg(imageDynamic);
staticEntities = getPropsForSeg(imageStatic);

% get CSR simulation envelope

repeats = props.repeats;
[w,h] = size(imageDynamic);
%
% xr = randi(w,[size(centers,1),repeats]);
% yr = randi(h,[size(centers,1),repeats]);
verbose = 0;
if verbose
    figure
end

CSRcorrfuns = []
for i = 1:repeats
    
    if (strcmp(props.random,'CSR'))
        xr= randi(h,size(dynamicEntities.centers,1),1);
        yr= randi(w,size(dynamicEntities.centers,1),1);
        [ corrfun  ] = twopointcrosscorrMG(w,h, xr,yr, xs, ys, dr, margin);
    elseif (strcmp(props.random,'shuffle1'))
        imageRandomized = getDynamicRandomized(imageStatic, dynamicEntities, props);
        CC = bwconncomp(imageRandomized);
        rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
        centers = cat(1, rp.Centroid);
        xr = centers(:,1);
        yr = centers(:,2);
        [ corrfun  ] = twopointcrosscorrMG(w,h, xr,yr, xs, ys, dr, margin);
    elseif (strcmp(props.random,'shuffle2'))
        imageStaticRandomized = getDynamicRandomized(0*imageStatic, staticEntities, props);
        props1 = props;
        props1.staticOverlap = 0;
        imageDynamicRandomized = getDynamicRandomized(imageStaticRandomized, dynamicEntities, props1);
        CC = bwconncomp(imageDynamicRandomized);
        rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
        centers = cat(1, rp.Centroid);
        xr = centers(:,1);
        yr = centers(:,2);
        CC = bwconncomp(imageStaticRandomized);
        rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
        centers = cat(1, rp.Centroid);
        xrs = centers(:,1);
        yrs = centers(:,2);
        [ corrfun  ] = twopointcrosscorrMG(w,h, xr,yr, xrs, yrs, dr, margin);
    else
        N1 = size(dynamicEntities.centers,1);
        N2 = size(staticEntities.centers,1);
        xx1 = centersOrigDynamic(:,1);
        yy1 = centersOrigDynamic(:,2);
        xx2 = centersOrigStatic(:,1);
        yy2 = centersOrigStatic(:,2);
        xx = [xx1;xx2];
        yy = [yy1;yy2];
        rpi = randperm(N1+N2,N1);
        xx1 = xx(rpi);
        yy1 = yy(rpi);
        xx(rpi) = [];
        yy(rpi) = [];
        [ corrfun  ] = twopointcrosscorrMG(w,h, xx1,yy1, xx, yy, dr, margin);
    end
    
    
    
    %corrfun = cat(2,corrfun,zeros(1,10000-size(corrfun,2)));
    CSRcorrfuns = cat(1,CSRcorrfuns, corrfun);
    
    if i == 1
        randomExample = corrfun;
    end

    if verbose

        plot(dr:dr:10000*dr,corrfun);
        hold on;
    end
    
end
CSRcorrfunsSorted = sort(CSRcorrfuns,1);

r_plus = dr:dr:margin;

% figure;
%
% hold on
% plot(r, CSRcorrfunsSorted(1,:),'r');
% plot(r, CSRcorrfunsSorted(end,:),'r');


x = centersOrigDynamic(:,1);
y = centersOrigDynamic(:,2);



verbose = 0;

r =dr:dr:margin;

[ corrfun  ] = twopointcrosscorrMG(w, h, x, y, xs, ys, dr, margin);
% plot(r, corrfun);

%corrfun = cat(2,corrfun,zeros(1,margin-size(corrfun,2)))

if verbose
    plot(r,corrfun ,'k', 'LineWidth', 2);
    xlim([0,100])
end

res = struct;
res.corr = corrfun;
res.r = r;
res.rCSR = r_plus;
res.csr = CSRcorrfuns;

res.randomExample = randomExample;
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
    'srcDynamic','bactMask',...
    'srcStatic','microbiotaMask',...
    'dr',2, ...
    'repeats',5, ...
    'random', 'shuffle', ...
    'staticOverlap', 1, ...
    'dynamicOverlap', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'srcStatic'))
        props.srcStatic = v{i+1};
    elseif (strcmp(v{i}, 'srcDynamic'))
        props.srcDynamic = v{i+1};
    elseif (strcmp(v{i}, 'dr'))
        props.dr = v{i+1};
    elseif (strcmp(v{i}, 'random'))
        props.random = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    end
end

end

