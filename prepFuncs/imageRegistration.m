% main function run from prep

function res = imageRegistration(data,parameters,resNames)

% the images for comparison used for a figure are either linked (e.g.,
% timepoint when 'time' is used with 'link') when 'linking' parameter is set
% to true, or 'src' which typically specifies the different channels from
% the same entry to compare among themselves

% notes on two modes of action:
% when 'linking', use parameters 'linking' true, and 'src' CHANNEL (one
% channel only)
% when not 'linking', use just src {CHANNEL1 CHANNEL2 ...} (more than one
% channel)

props = parseParams(parameters);

inRegPointsField = 'points';

linking = props.linking;
src = props.src;
srcHandles = cell(0);
imgs = cell(0);

% if regPoints was saved and then reloaded, it will be in 'properties',
% otherwise, it will be in the main handle of data
pointsSrc = props.pointsSrc;
if (isprop(data, pointsSrc))
    if (isempty(data.(pointsSrc)))
        res = []; % empty - probably at linking and this entry is not the first
        return;
    else
        regPoints = data.(pointsSrc).(inRegPointsField);
    end
elseif (isfield(data.properties, pointsSrc))
    if (isempty(data.properties.(pointsSrc)))
        res = []; % empty - probably at linking and this entry is not the first
        return;
    else
        regPoints = data.properties.(pointsSrc).(inRegPointsField);
    end
else
    error('regPoints not found'); 
end

if (linking)
    if (isfield(data.properties, 'prev')) % if it's not the first entry in the linking (e.g., first timepoint) - return; otherwise iterates all linked entries from the first onwards
        res = [];
        return;
    end
    nextLinked = data;
    while 1
        srcHandles = [srcHandles, nextLinked];
        img = nextLinked.(src);
        %titles = [titles, [nextLinked.properties.link, ' ', num2str(nextLinked.properties.(nextLinked.properties.link))]];
        imgs = [imgs, img];
        if (isfield(nextLinked.properties, 'next'))
           nextLinked = nextLinked.properties.next;
        else
            break;
        end
    end     
else
    srcHandles = data;
    for i = 1 : numel(src)
        % titles = [titles, src{i}];
        imgs = [imgs, data.(src{i})];
    end
end

newImgs = iterateRegPoints(imgs, regPoints);


for i = 1 : numel(newImgs)
    curImg = newImgs{i};
    if (numel(srcHandles) == 1) 
        curHandle = srcHandles;
    else
        curHandle = srcHandles(i); % typically at linking
    end
    if (iscell(resNames) && numel(resNames) == 1) || ischar(resNames) % typically at linking
        curSrc = resNames;
    else
        curSrc = resNames{i};
    end
    curHandle.(curSrc) = newImgs{i};
end
    

end


function props = parseParams(v)
% default:
props = struct(...
    'src','', ...
    'linking', false, ...
    'pointsSrc', 'regPoints' ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};     
    elseif (strcmp(v{i}, 'linking'))
        props.linking = v{i+1};  
    elseif (strcmp(v{i}, 'pointsSrc'))
        props.pointsSrc = v{i+1};
    end
    
end

end
