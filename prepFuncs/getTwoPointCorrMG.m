function res = getTwoPointCorrMG(data,parameters)

props = parseParams(parameters);

image = data.(props.src);
dr = props.dr;

margin = props.margin;

CC = bwconncomp(image);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centersOrig = cat(1, rp.Centroid);

dynamicEntities = getPropsForSeg(image);

% get CSR simulation envelope

repeats = props.repeats;
[w,h] = size(image);
%
% xr = randi(w,[size(centers,1),repeats]);
% yr = randi(h,[size(centers,1),repeats]);
verbose = 0;
if verbose
    figure
end

CSRcorrfuns = []
randomExample=[];
for i = 1:repeats
    
    if (strcmp(props.random,'CSR'))
        xr= randi(h,size(dynamicEntities.centers,1),1);
        yr= randi(w,size(dynamicEntities.centers,1),1);
    else
        
        
        imageRandomized = getDynamicRandomized(zeros(size(image)), dynamicEntities, props);
        CC = bwconncomp(imageRandomized);
        rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
        centers = cat(1, rp.Centroid);
        xr = centers(:,1);
        yr = centers(:,2);
    end
    
    [ corrfun  ] = twopointcorrMG(w,h, xr,yr, dr, margin);
    
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


x = centersOrig(:,1);
y = centersOrig(:,2);



verbose = 0;

r =dr:dr:margin;

[ corrfun  ] = twopointcorrMG(w,h, x,y, dr, margin);
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
    'src','GFP',...
    'dr',2, ...
    'repeats',5, ...
    'random', 'shuffle', ...
    'staticOverlap', 1, ...
    'dynamicOverlap', 0, ...
    'margin', 100 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'margin'))
        props.margin = v{i+1};
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

