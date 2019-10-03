function res = getTwoPointCorr(data,parameters)

props = parseParams(parameters);

image = data.(props.src);
dr = props.dr;


CC = bwconncomp(image);
rp = regionprops(CC, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers = cat(1, rp.Centroid);

% get CSR simulation envelope

repeats = 100;
[w,h] = size(image);

xr = randi(w,[size(centers,1),repeats]);
yr = randi(h,[size(centers,1),repeats]);
CSRcorrfuns = []
for i = 1:repeats
    blksize = 1000;
    verbose = 0;
    [ corrfun r rw] = twopointcorr( xr(:,i),yr(:,i),dr,blksize,verbose);
    
    corrfun = cat(2,corrfun,zeros(1,10000-size(corrfun,2)));
    CSRcorrfuns = cat(1,CSRcorrfuns, corrfun);
end
CSRcorrfunsSorted = sort(CSRcorrfuns,1);

r_plus = dr:dr:10000*dr;

% figure;
% 
% hold on
% plot(r, CSRcorrfunsSorted(1,:),'r');
% plot(r, CSRcorrfunsSorted(end,:),'r');


x = centers(:,1);
y = centers(:,2);



blksize = 1000;
verbose = 0;
[ corrfun r rw] = twopointcorr( x,y,dr,blksize,verbose)

% plot(r, corrfun);

res = struct;
res.corr = corrfun;
res.r = r;
res.rCSR = r_plus;
res.csr = CSRcorrfuns;
end


function props = parseParams(v)
% default:
props = struct(...
    'src','GFP',...
    'dr',2 ...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'dr'))
        props.removedMask = v{i+1};
    end
end

end