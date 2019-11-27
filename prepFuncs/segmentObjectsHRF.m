function seg = segmentObjectsHRF(data,parameters)

props = parseParams(parameters);

src = data.(props.src);
thresh = [10000 7000 4000];
ngh = [10, 5, 2];


[h,w] = size(src);
M = ones(size(src));
I = src;
if (props.verbose)
    RGB = data.(props.RGBsrc);
    figure
    imshow(RGB)
    hold on;
    colors = hsv(numel(thresh));
end 

for i = 1:numel(thresh)
    SE = strel('disk', ngh(i),4);
    [I,M] = HRF(I, M, thresh(i), SE.Neighborhood);
    
    if (props.verbose)
        colorI = ones(h,w,3);
        for ci = 1:3
            colorI(:,:,ci) = colors(i,ci);
        end
        hm = imshow(colorI);
        set(hm, 'AlphaData', bwperim(M));
    end
end

seg = M;

end

function [II,MM] = HRF(I,M,r,SE)
   
    U = I;
    U(M==0) = 65535;
    minI = ordfilt2(U,1,SE);
    U(M==0) = 0;
    maxI = ordfilt2(U,sum(SE(:)),SE);
    
    MM = (maxI - minI) > r;
    II = I;
    II(MM==0) = 0;

end

function props = parseParams(v)
% default:
props = struct(...
    'src','BF',...
    'RGBsrc','RGB',...
    'verbose','0'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'RGBsrc'))
        props.RGBsrc = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    end
end

end

