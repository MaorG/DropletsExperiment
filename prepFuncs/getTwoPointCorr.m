function res = getTwoPointCorr(data,parameters)

props = parseParams(parameters);

image = data.(props.src);
dr = props.dr;


CC = bwconncomp(image);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centersOrig = cat(1, rp.Centroid);

dynamicEntities = getPropsForSeg(image);

% get CSR simulation envelope

repeats = 100;
[w,h] = size(image);
% 
% xr = randi(w,[size(centers,1),repeats]);
% yr = randi(h,[size(centers,1),repeats]);
CSRcorrfuns = []
for i = 1:repeats
    blksize = 1000;
    verbose = 0;
    
    imageRandomized = getDynamicRandomized(zeros(size(image)), dynamicEntities, props);
    CC = bwconncomp(imageRandomized);
    rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
    centers = cat(1, rp.Centroid);
    xr = centers(:,1);
    yr = centers(:,2);
    
    [ corrfun r rw] = twopointcorr( xr(:),yr(:),dr,blksize,verbose);
    
    corrfun = cat(2,corrfun,zeros(1,10000-size(corrfun,2)));
    CSRcorrfuns = cat(1,CSRcorrfuns, corrfun);
    
    if i == 1
        randomExample = corrfun;
    end
    
    
end
CSRcorrfunsSorted = sort(CSRcorrfuns,1);

r_plus = dr:dr:10000*dr;

% figure;
% 
% hold on
% plot(r, CSRcorrfunsSorted(1,:),'r');
% plot(r, CSRcorrfunsSorted(end,:),'r');


x = centersOrig(:,1);
y = centersOrig(:,2);



blksize = 1000;
verbose = 0;
[ corrfun r rw] = twopointcorr( x,y,dr,blksize,verbose)

% plot(r, corrfun);

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
    'src','GFP',...
    'dr',2, ...
    'repeats',5, ...
    'staticOverlap', 1, ...
    'dynamicOverlap', 0 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'dr'))
        props.dr = v{i+1};
    elseif (strcmp(v{i}, 'repeats'))
        props.repeats = v{i+1};
    elseif (strcmp(v{i}, 'staticOverlap'))
        props.staticOverlap = v{i+1};
    elseif (strcmp(v{i}, 'dynamicOverlap'))
        props.dynamicOverlap = v{i+1};
    end
end

end

