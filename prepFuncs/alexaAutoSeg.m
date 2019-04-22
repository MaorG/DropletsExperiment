function res = alexaAutoSeg(data,parameters)

props = parseParams(parameters);

AL = data.(props.srcALX);
BF = data.(props.srcBF);

disk = getDisk(5);

%ALs = double(imgaussfilt(AL, 10));
%BFs = double(imgaussfilt(BF, 10));
ALs = double(imgaussfilt(AL, 4));
%BFs = double(imgaussfilt(BF, 4));

%BFg = imgradient(BFs);
ALg = imgradient(ALs);

[ALgx, ALgy] = gradient(ALs);
[ALgxx, ALgxy] = gradient(ALgx);
[~, ALgyy] = gradient(ALgy);

% [BFgx, BFgy] = gradient(BFs);
% [BFgxx, BFgxy] = gradient(BFgx);
% [~, BFgyy] = gradient(BFgy);

Kal = (ALgxx .* ALgyy - (ALgxy.^2)) ./  (1 + (ALgx.^2) + (ALgy.^2)).^2;
% Kbf = (BFgxx .* BFgyy - (BFgxy.^2)) ./  (1 + (BFgx.^2) + (BFgy.^2)).^2;

% H = ((1+ALgx.^2).*ALgyy + (1+ALgy.^2).*ALgxx - 2.*ALgx.*ALgy.*ALgxy)./...
%     ((1 + ALgx.^2 + ALgy.^2).^(3/2));

Jal = stdfilt(Kal,disk);
% Jbf = stdfilt(Kbf,disk);
% figure; imagesc(log10(Jal));
% figure; imagesc(log10(Jbf));
% figure; imshow(imfuse(mat2gray(BF,[20000,60000]), ...
%     cat(3,bwperim(imfill((J < 0.00001),'holes')), ...
%           bwperim(imfill((J < 0.0001),'holes')), ...
%           bwperim(imfill((J < 0.001),'holes'))),'blend'))


th = 0.0000001

h = figure;
userinput = 0
clim = [1,2^16 - 1];

BFUI = BF;
jump = 100;
rectUI = [1,1,size(BF,1),size(BF,2)];

interrupted = false;

while userinput ~= 13
    maskUI = Jal(rectUI(1):(rectUI(1)+rectUI(3)-1),rectUI(2):(rectUI(2)+rectUI(4)-1)) < th; % ????
    maskUI = imfill( maskUI ,'holes');
    BFUI = BF(rectUI(1):(rectUI(1)+rectUI(3)-1),rectUI(2):(rectUI(2)+rectUI(4)-1));
    imshow(imfuse( ...
        cat(3,...
            mat2gray(BFUI,clim), ...
            mat2gray(BFUI,clim), ...
            mat2gray(BFUI,clim) ), ...
        cat(3,...
            (imfill( maskUI ,'holes')), ...
            0*maskUI, ...
            0*maskUI ) ...
        ,'blend') ...
        );
    button = 1;
    continueToBigLoop = false;
    while ~continueToBigLoop
        title( [ '{q/a}-->[', num2str(clim(1)), ', ', num2str(clim(2)), ']<--{w/s}  {up/down} jump: ', num2str(jump), ',  {left/right} threshold: ', num2str(th)] );

        continueToBigLoop = false;
        try
            [x,y,button]=ginput(1)
        catch
             button = 13;
             interrupted = true;
        end
        if isempty(button)
            button = 13;
        end
        button
        switch button
            case 28
                th = th * jump;
                continueToBigLoop = true;
            case 29
                th = th / jump
                continueToBigLoop = true;
            case 31
                jump = ceil(jump/10);
                %continueToBigLoop = true;
            case 30
                jump = jump*10;
                %continueToBigLoop = true;

            case 13
                continueToBigLoop = true;
            case 122
                rectUI = getrect;
                rectUI = rectUI([2,1,4,3])
                continueToBigLoop = true;
            case 120
                rectUI = [1,1,size(BF,1),size(BF,2)];
                continueToBigLoop = true;
            case 97
                %clim(1) = ceil(clim(1)*0.5)
                clim(1) = clim(1) - jump;
                continueToBigLoop = true;
            case 113
                %clim(1) = min(min(ceil(clim(1)*2),2^16),clim(2));
                clim(1) = clim(1) + jump;
                continueToBigLoop = true;
            case 115
                %clim(2) = max(ceil(clim(2)*0.5),clim(1))
                clim(2) = clim(2) - jump;
                continueToBigLoop = true;
            case 119
                %clim(2) = min(ceil(clim(2)*2),2^16);
                clim(2) = clim(2) + jump;
                continueToBigLoop = true;
        end
        
        userinput = button;
        
    end
    
end

if (~interrupted)
    close(h);
end

mask = Jal < th; 
mask = imfill( mask ,'holes');

res = mask;

return

Kbf = (BFgxx .* BFgyy - (BFgxy.^2)) ./  (1 + (BFgx.^2) + (BFgy.^2)).^2;
disk = getDisk(5);
Jbf = stdfilt(Kbf,disk);


figure;
imagesc(log10(Jbf))


ALgx = diff(ALs, 1, 1);
ALgy = diff(ALs, 1, 2);

ALgxx = diff(ALgx, 1, 1);
ALgxy = diff(ALgx, 1, 2);
ALgyx = diff(ALgy, 1, 1);
ALgyy = diff(ALgy, 1, 2);

imshow(cat(3,0.5*mat2gray(ALg),0.5*mat2gray(BFg), 1*mat2gray(K,0.0001*[-1,1])))

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

