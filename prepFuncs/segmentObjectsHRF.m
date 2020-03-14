function seg = segmentObjectsHRF(data,parameters)

props = parseParams(parameters);

src = data.(props.src);
if isnumeric(props.HRFThresh)
    thresh = props.HRFThresh;
else 
    thresh = data.properties.(props.HRFThresh);
end
if isnumeric(props.HRFngh)
    ngh = props.HRFngh;
else 
    ngh = data.properties.(props.HRFngh);
end


[h,w] = size(src);
M = ones(size(src));
I = src;
if (props.verbose)
    tt = data.(props.src);
    figure
    imshow(tt)
    hold on;
    colors = hsv(numel(thresh));
    title(data.properties.well)
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

M(:,1) = 0;
M(:,end) = 0;
M(1,:) = 0;
M(end,:) = 0;

M(:,1:5) = 0;
M(:,(end-4):end) = 0;
M(1:5,:) = 0;
M((end-4):end,:) = 0;

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

props.HRFThresh = [10000 7000 4000];
props.HRFngh = [10, 5, 2];

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'RGBsrc'))
        props.RGBsrc = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    elseif (strcmp(v{i}, 'HRFThresh'))
        props.HRFThresh = v{i+1};
    elseif (strcmp(v{i}, 'HRFngh'))
        props.HRFngh = v{i+1};
    end
end

end

