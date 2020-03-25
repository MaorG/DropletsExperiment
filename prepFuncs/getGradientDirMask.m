function mask = getGradientDirMask(data, parameters)

props = parseParams(parameters);

src = data.(props.src);
minArea = props.minArea;
direcs  = props.dirs;
verbose = props.verbose;

bf = mat2gray(src);

% todo: replace with convolution with gaussian
[Gx,Gy] = getGradientXY(bf);

mask = getGradientDirMaskAux(Gx, Gy, minArea, direcs, verbose);

end

function [Gx,Gy] = getGradientXY(bf)
dx = [
    -5 -4 0 4 5
    -8 -10 0 10 8
    -10 -20 0 20 10
    -8 -10 0 10 8
    -5 -4 0 4 5
    ];
dy = dx';

Gx = imfilter(bf, dx);
Gy = imfilter(bf, dy);
end

function mask = getGradientDirMaskAux(Gx, Gy,minArea, direcs, verbose)

[Gmag,Gdir] = imgradient(Gx, Gy);

%Gdir(Gdir<0) = Gdir((Gdir<0)) + 180;
Gdir = Gdir+180;

[~,~,binned] = histcounts(Gdir(:),direcs);

GdirI = reshape(binned,size(Gdir));

RGB = ind2rgb(GdirI,hsv(18));
RGB(:,:,1) = RGB(:,:,1).*(Gmag>10);
RGB(:,:,2) = RGB(:,:,2).*(Gmag>10);
RGB(:,:,3) = RGB(:,:,3).*(Gmag>10);
GdirMat = zeros([size(Gdir),numel(direcs)-1]);
for i = 1:numel(direcs)-1
    GdirMat(:,:,i) = Gdir >= direcs(i) & Gdir<direcs(i+1);
end

GdirMat2 = zeros(size(GdirMat));

N = numel(direcs)-1
for i = 1:N
    i2 = mod(i+1,N+1)+floor((i+1)/(N+1));
    i3 = mod(i+2,N+1)+floor((i+2)/(N+1));
    i4 = mod(i+3,N+1)+floor((i+3)/(N+1));
    %     if ii > numel(direcs)-1
    %         ii = 1;
    %     end
    GdirMat2(:,:,i) = GdirMat(:,:,i) | GdirMat(:,:,i2) | GdirMat(:,:,i3)| GdirMat(:,:,i4);
end

GdirMat3 = zeros(size(GdirMat));

for i = 1:size(GdirMat2,3)
    GdirMat3(:,:,i) = bwareaopen(GdirMat2(:,:,i),minArea);
end

mask1 = (sum(GdirMat3,3) > 0);

if verbose
    figure
    [~,~,binned] = histcounts(Gdir(:),direcs);
    GdirI = reshape(binned,size(Gdir));
    RGB = ind2rgb(GdirI,hsv(18));
    int_mask = Gmag > 0.2;
    %imshow(0.75*double(cat(3,0.5*GdirMat2(:,:,1)+mask,0.5*GdirMat2(:,:,2)+mask,0.5*GdirMat2(:,:,3)+mask)));
    imshow(RGB.*(0.25+0.375*repmat(mask1+int_mask,[1,1,3])));
    %imshow(0.75*double(cat(3,0.5*GdirMat2(:,:,1)+mask,0.5*GdirMat2(:,:,2)+mask,0.5*GdirMat2(:,:,3)+mask)));
end

    
    GdirII = mod(GdirI+N/2,N+1)+floor((GdirI+N/2)/(N+1));
    
%     RGB = ind2rgb(GdirI,hsv(24));
%     imshow(RGB.*(0.5+0.5*repmat(mask,[1,1,3])));
%     figure
%     RGB = ind2rgb(GdirII,hsv(24));
%     imshow(RGB.*(0.5+0.5*repmat(mask,[1,1,3])));
%     figure
%     imshow(RGB);
    
    I1 = GdirI(2:end-1,2:end-1)-GdirII(1:end-2,2:end-1);
    I2 = GdirI(2:end-1,2:end-1)-GdirII(3:end,2:end-1);
    I3 = GdirI(2:end-1,2:end-1)-GdirII(2:end-1,1:end-2);
    I4 = GdirI(2:end-1,2:end-1)-GdirII(2:end-1,3:end);
    
    mm =8;
    II1 = I1> -mm & I1< mm;
    II2 = I2> -mm & I2< mm;
    II3 = I3> -mm & I3< mm;
    II4 = I4> -mm & I4< mm;
    III = (II1|II2|II3|II4);
    
if verbose
    
    figure
    
    imshow(0.25*mask1(2:end-1,2:end-1) + (III & mask1(2:end-1,2:end-1)))
    
end

mask = zeros(size(Gx));
mask(2:end-1,2:end-1) = III;
mask = mask&mask1;
end


function props = parseParams(v)
% default:
props = struct(...
    'src','BF',...
    'minArea',60,...
    'verbose', 0,...
    'dirs',[]...
    );

props.dirs = [0:15:360];

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'minArea'))
        props.minArea = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    elseif (strcmp(v{i}, 'dirs'))
        props.dirs = v{i+1};
    end
end

end

