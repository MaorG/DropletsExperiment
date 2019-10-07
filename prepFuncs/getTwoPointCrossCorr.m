function res = getTwoPointCrossCorr(data,parameters)

props = parseParams(parameters);

image1 = data.(props.src1);
image2 = data.(props.src2);
dr = props.dr;

maxR = 500


CC1 = bwconncomp(image1);
rp1 = regionprops(CC1, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers1 = cat(1, rp1.Centroid);
CC2 = bwconncomp(image2);
rp2 = regionprops(CC2, 'Centroid', 'PixelList', 'PixelIdxList', 'Area');
centers2 = cat(1, rp2.Centroid);

% get CSR simulation envelope

repeats = 100;
[w,h] = size(image1);

xr1 = randi(w,[size(centers1,1),repeats]);
yr1 = randi(h,[size(centers1,1),repeats]);
xr2 = randi(w,[size(centers2,1),repeats]);
yr2 = randi(h,[size(centers2,1),repeats]);
CSRcorrfuns = []
for i = 1:repeats
    blksize = 1000;
    verbose = 0;
    [ corrfun r rw] = twopointcrosscorr( xr1(:,i),yr1(:,i),xr2(:,i),yr2(:,i),dr,maxR,blksize,verbose);
    
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


x1 = centers1(:,1);
y1 = centers1(:,2);
x2 = centers2(:,1);
y2 = centers2(:,2);



blksize = 1000;
verbose = 0;
[ corrfun r rw] = twopointcrosscorr( x1,y1,x2,y2,dr,maxR,blksize,verbose)

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
    'src1','C1',...
    'src2','C2',...
    'dr',2 ...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'src2'))
        props.src2 = v{i+1};
    elseif (strcmp(v{i}, 'dr'))
        props.removedMask = v{i+1};
    end
end

end