function res = userThreshold(data,parameters)

props = parseParams(parameters);

AL = data.(props.srcALX);
BF = data.(props.srcBF);

th = 1000;

h = figure;
userinput = 0;
clim = [0,2^16 - 1];
jump = 1000;

BFUI = BF;

rectUI = [1,1,size(BF,1),size(BF,2)];

while userinput ~= 13
    maskUI = AL(rectUI(1):(rectUI(1)+rectUI(3)-1),rectUI(2):(rectUI(2)+rectUI(4)-1)) > th; % ????
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
        title( [ '<q/a>-->[', num2str(clim(1)), ', ', num2str(clim(2)), ']<--<w/s>  <up/down>-->jump: ', ...
            num2str(jump), ',  <left/right>--> threshold: ', num2str(th), ...
            '  zoom<--<z,x>  ok<Enter>']);

        continueToBigLoop = false;
        [x,y,button]=ginput(1)
        if isempty(button)
            button = 13;
        end
        button
        switch button
            case 28
                th = th - jump;
                continueToBigLoop = true;
            case 29
                th = th + jump
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
                rectUItemp = getrect;
                if rectUItemp(3) ~= 0 && rectUItemp(4) ~= 0 
                    rectUI = rectUItemp([2,1,4,3]) + [rectUI(1),rectUI(2),0,0];
                    continueToBigLoop = true;
                end
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
close(h);

mask = AL > th; 
mask = imfill( mask ,'holes');

res = mask;
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

