function res = userRemoveRegions(data,parameters)

props = parseParams(parameters);

%AL = data.(props.srcALX);
BF = data.(props.srcBF);
if (isfield(data, props.srcRemove) && all(size(data.(props.srcRemove)) == size(BF)))
    AL = data.(props.srcRemove);
else
    AL = zeros(size(BF));
end

AL = logical(AL);

imDesc = [];
imParsFields = fieldnames(data.parameters);
for i = 1 : numel(imParsFields)
    if (~isempty(imDesc))
        imDesc = [imDesc, ' '];
    end
    imDesc = [imDesc, imParsFields{i}, ' ', num2str(data.parameters.(imParsFields{i}))];
end

%th = 1000;

h = figure;
%hold on;
userinput = 0;
clim = props.clim; 
jump = props.jump;

BFUI = BF;

rectUI = [1,1,size(BF,1),size(BF,2)];


while userinput ~= 13
    maskUI = AL(rectUI(1):(rectUI(1)+rectUI(3)-1),rectUI(2):(rectUI(2)+rectUI(4)-1)); 
    BFUI = BF(rectUI(1):(rectUI(1)+rectUI(3)-1),rectUI(2):(rectUI(2)+rectUI(4)-1));
    imshow(imfuse( ...
        cat(3,...
            mat2gray(BFUI,clim), ...
            mat2gray(BFUI,clim), ...
            mat2gray(BFUI,clim) ), ...
        cat(3,...
            (AL), ...
            0*maskUI, ...
            0*maskUI ) ...
        ,'blend') ...
        );
    button = 1;
    continueToBigLoop = false;
    while ~continueToBigLoop
        titl = [ '{q/a}-->[', num2str(clim(1)), ', ', num2str(clim(2)), ']<--{w/s}  {up/down} jump: ', num2str(jump), ',  image: ', imDesc];
        set(h,'Name',titl,'NumberTitle','off')
        %set(gca, 'Position', [200 200 0 0]);
        continueToBigLoop = false;
        [x,y,button]=ginput(1)
        if isempty(button)
            button = 13;
        end
        button
        switch button
%             case 28
%                 th = th - jump;
%                 continueToBigLoop = true;
%             case 29
%                 th = th + jump
%                 continueToBigLoop = true;
            case 31
                jump = ceil(jump/10);
                %continueToBigLoop = true;
            case 30
                jump = jump*10;
                %continueToBigLoop = true;
            case 13
                continueToBigLoop = true;
            case 122
                %rectUI = getrect;
                coor = getrect;
                row_from = max(floor(coor(2)),1);
                col_from = max(floor(coor(1)),1);
                row_to = min(floor(coor(2) + coor(4)),size(BF,2));
                col_to = min(floor(coor(1) + coor(3)),size(BF,1));
                disp(coor);
                AL(row_from:row_to, col_from:col_to) = 1;
                %rectUI = rectUI([2,1,4,3])
                continueToBigLoop = true;
%             case 120
%                 rectUI = [1,1,size(BF,1),size(BF,2)];
%                 continueToBigLoop = true;
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


res = AL;
end



function props = parseParams(v)
% default:
props = struct(...
    'srcALX','ALX',...
    'srcBF','BF', ...
    'srcRemove', 'RemoveRegionsMask', ...
    'clim', [0,2^16 - 1], ...
    'jump', 1000 ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'srcALX'))
        props.srcALX = v{i+1};
    elseif (strcmp(v{i}, 'srcBF'))
        props.srcBF = v{i+1};
    elseif (strcmp(v{i}, 'srcRemove'))
        props.srcRemove = v{i+1};
    elseif (strcmp(v{i}, 'clim'))
        props.clim = v{i+1};
    elseif (strcmp(v{i}, 'jump'))
        props.jump = v{i+1};
    end
end

end
