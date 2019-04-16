function res = alexaAutoSeg(data,parameters)

props = parseParams(parameters);

AL = data.(props.srcALX);
BF = data.(props.srcBF);

disk = getDisk(20);

ALs = double(imgaussfilt(AL, 10));
BFs = double(imgaussfilt(BF, 10));

BFg = imgradient(BFs);
ALg = imgradient(ALs);

[ALgx, ALgy] = gradient(ALs);
[ALgxx, ALgxy] = gradient(ALgx);
[~, ALgyy] = gradient(ALgy);

[BFgx, BFgy] = gradient(BFs);
[BFgxx, BFgxy] = gradient(BFgx);
[~, BFgyy] = gradient(BFgy);

K = (ALgxx .* ALgyy - (ALgxy.^2)) ./  (1 + (ALgx.^2) + (ALgy.^2)).^2;
H = ((1+ALgx.^2).*ALgyy + (1+ALgy.^2).*ALgxx - 2.*ALgx.*ALgy.*ALgxy)./...
    ((1 + ALgx.^2 + ALgy.^2).^(3/2));


ALgx = diff(ALs, 1, 1);
ALgy = diff(ALs, 1, 2);

ALgxx = diff(ALgx, 1, 1);
ALgxy = diff(ALgx, 1, 2);
ALgyx = diff(ALgy, 1, 1);
ALgyy = diff(ALgy, 1, 2);

imshow(cat(3,0.5*mat2gray(ALs),0.5*mat2gray(BFs), 1*mat2gray(K,0.0001*[-1,1])))

figure;
imshow(mat2gray(BF));

[x,y] = ginput();

figure;
scatter(((K(:))), BFg(:))
hold on

idx = uint32(sub2ind(size(ALg), y,x));

scatter(K(idx), BFg(idx),100,'r');

mmm = (K > min(K(idx)) & K< max(K(idx)) & (BFg > min(BFg(idx)) & BFg < max(BFg(idx)) ));

figure
imshow(cat(3,0.5*mat2gray(ALg),0.5*mat2gray(BFg), 2*mat2gray(mmm)))

figure
scatter(K(:), BFg(:));
hold on
scatter(K(mmm(:)>0), BFg(mmm(:)>0));




res = [];

end

function disk = getDisk(radius)
    dx = -radius:radius;
    dy = -radius:radius;
    [DX, DY] = meshgrid(dx,dy);
    disk = (DX.*DX)+(DY.*DY) <= radius*radius;
end

function props = parseParams(v)
% default:
props = struct(...
    'srcALX','ALX',...
    'srcBF','BF'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'srcALX'))
        props.srcALX = v{i+1};
    elseif (strcmp(v{i}, 'srcBF'))
        props.srcBF = v{i+1};
    end
end

end

