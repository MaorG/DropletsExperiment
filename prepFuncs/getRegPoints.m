function res = getRegPoints(data,parameters)

props = parseParams(parameters);

linking = props.linking;

% the images for comparison used for a figure are either linked (e.g.,
% timepoint when 'time' is used with 'link') when 'linking' parameter is set
% to true, or 'src' which typically specifies the different channels from
% the same entry to compare among themselves

% notes on two modes of action:
% when 'linking', use parameters 'linking' true, and 'src' CHANNEL (one
% channel only)
% when not 'linking', use just src {CHANNEL1 CHANNEL2 ...} (more than one
% channel)

% notes on parameters:
% 'linkaxes' true - makes all subplots move synchronomously

% output:
% each entry in the third dimension is a different referenced point (a
% reference point is a set of points for a set of images that points to the
% same physical location)
% for each entry, each row is a point of the ith image
% so, for instance, to get all the points of the first  image - iterate all dimensions and get the first row of each one
    
imgs = cell(0);
titles = cell(0);

src = props.src;

if (linking)
    if (isfield(data.properties, 'prev')) % if it's not the first entry in the linking (e.g., first timepoint) - return; otherwise iterates all linked entries from the first onwards
        res = [];
        return;
    end
    nextLinked = data;
    while 1
        img = nextLinked.(src);
        titles = [titles, [nextLinked.properties.link, ' ', num2str(nextLinked.properties.(nextLinked.properties.link))]];
        imgs = [imgs, img];
        if (isfield(nextLinked.properties, 'next'))
           nextLinked = nextLinked.properties.next;
        else
            break;
        end
    end     
else
    for i = 1 : numel(src)
        titles = [titles, src{i}];
        imgs = [imgs, data.(src{i})];
    end
end


treatTitle = [];
if (isfield(props, 'treatTitle'))
    treatPars = props.treatTitle;
    treatVals = data.parameters;
    for t = 1 : numel(treatPars)
        val = treatVals.(treatPars{t});
        if (isnumeric(val))
           val = num2str(val);
        end
        treatTitle = [treatTitle, ' ', val];
    end
end

%thresholdSrcs = props.thresholdSrcs;

% uncomment this portion for debugging sample images instead
% treatTitle = 'test';
% titles = {'BF' 'GFP' 'RFP' 'DAPI' '647'};
% num = numel(titles);
% fold = 'D:\docs\shifra project 18.11.18\final_graphs\all_distances\color_modified_sizes';
% fold = '\\qnap01\LongTerm\Shifra\2019\7.19\7.7.19\screen b\exported_tiffs';
% files = {'A1_A506toPear(GFPtoBF)_T18(9hrs)_allDistances_largerMicAggregates.tif' 'A1_PearToA506(BFtoGFP)_T18(9hrs)_allDistances_smallerMicAggregates.tif' 'A6_B728toPear(GFPtoBF)_T24(12hrs)_allDistances_largerMicAggregates.tif' 'A6_PearToB728(BFtoGFP)_T24(12hrs)_allDistances_smallerMicAggregates.tif' 'C1_A506toGB(GFPtoBF)_T18(9hrs)_allDistances_largerMicAggregates.tif'};
% files = {'img_T1_P2b_07072019_A1_BF.tiff' 'img_T1_P2b_07072019_A1_Mcherry.tiff' 'img_T1_P2b_07072019_A1_647.tiff' 'img_T1_P2b_07072019_A1_647.tiff' 'img_T1_P2b_07072019_A1_647.tiff'};
% for i = 1 : numel(titles)
%     img = imread(fullfile(fold, files{i}));
%     imgs = [imgs, img];              
% end
% props.linkaxes = true;

num = numel(titles);
h = figure;
if (~isempty(props.figPos))
   set(h, 'Position', props.figPos);
end
clim = [0,2^16 - 1];
clim = repmat(clim, num, 1);
climOld = clim;
th = 1000;
th = repmat(th, num, 1);
thApply = repmat(false, num, 1);
thOld = th;

unfilledPointVals = [-1 -1];
jump = 1000;

[subRows, subCols] = bestVisualSubplotCoordinates(num);
axs = [];

for i = 1 : num
    
    curTitle = titles{i};
    ax = subplot(subRows, subCols, i);
    img = imgs{i};
    if (thApply(i)) % any(strcmp(curTitle, thresholdSrcs)) not relevant anymore
        imshow(img > th(i));
    else
        fixedScale = eval([class(img), '([', num2str(clim(i, :)), '])']); % fixes according to image integer type
        imshow(img, fixedScale);
    end
    title(curTitle);
    hold on;
    axs = [axs, ax];
                
end
    
if (props.linkaxes) 
    linkaxes([axs], 'xy');
end

userinput = 0;
refPoint = 0;
points = [];

lastAx = 0;
lastTitle = [];

% Return key stops getting input points from the images altogether
while userinput ~= 13
    refPoint = refPoint + 1;
    
    points(:,:,refPoint) = repmat(unfilledPointVals, num, 1);
    
    filledRefPoint = repmat(false, num, 1);
    
    while (any(~filledRefPoint) && userinput ~= 13) % while there is at least one unfilled point for the reference and a Return key was not pressed
        
        for i = 1 : numel(axs)
            
            %if (~all(points(i,:,refPoint) == unfilledPointVals)) 
            if (filledRefPoint(i)) % skip already filled image points
                continue;
            end
            
            curTitle = titles{i}; %axs(i).Title.String;
            if (i == 1) % first subplot is always the reference point
                appndText = sprintf(' (select reference point %d)', refPoint);
            else
                appndText = sprintf(' (select corresponding to reference point %d)', refPoint);
            end
            if (lastAx)
                title(axs(lastAx), lastTitle);
            end
            title(axs(i), [curTitle, appndText]);
            lastAx = i;
            lastTitle = curTitle;
            subplot(subRows, subCols, i);
            
            userinput = 0;
            %[x,y,button]=ginput(1);
            
            % Waiting for left click on the highlighted image (highlighted in
            % the title) or space to skip, or Return to end retrieval
            while userinput ~= 1 && userinput ~= 32 && userinput ~= 13
                if (~all(climOld(i, :) == clim(i, :)) || ~all(thOld(i) == th(i)))
                    curImg = imgs{i};
                    if (thApply(i)) % any(strcmp(curTitle, thresholdSrcs)) not relevant anymore
                        curImg = curImg > th(i);
                        imshow(curImg);
                    else
                        fixedScale = eval([class(img), '([', num2str(clim(i, :)), '])']); % fixes according to image integer type
                        imshow(curImg, fixedScale);
                    end
                    
                    %imshow(cat(3, mat2gray(curImg(:,:,1), clim), mat2gray(curImg(:,:,2), clim), mat2gray(curImg(:,:,3), clim)));
                    climOld(i, :) = clim(i, :);
                    thOld(i) = th(i);
                end
                
                %button = 1;
                continueToBigLoop = false;
                while ~continueToBigLoop
                    
                    titl = [ '<q/a>-->[', num2str(clim(i,1)), ', ', num2str(clim(i,2)), ']<--<w/s>  <up/down>-->jump: ', ...
                        num2str(jump), ',  <left/right>--> threshold: ', num2str(th(i)), ...
                        ' zoom<--<z,x> ok<Enter> ', treatTitle];
                    set(h,'Name',titl,'NumberTitle','off');
                    
                    continueToBigLoop = false;
                    [x,y,button]=ginput(1)
                    if isempty(button)
                        button = 13;
                    end
                    switch button
                        case 1 % chosen point
                            scatter(x, y, 'o');
                            filledRefPoint(i) = true;
                            points(i,:,refPoint) = [x y];
                            continueToBigLoop = true;
                        case 32 % skip choosing a point for an image (will come up again at the next round)
                            continueToBigLoop = true;
                        case 28
                            th(i) = th(i) - jump;
                            continueToBigLoop = true;
                        case 29
                            th(i) = th(i) + jump;
                            continueToBigLoop = true;
                        case 31
                            jump = ceil(jump/10);
                            %continueToBigLoop = true;
                        case 30
                            jump = jump*10;
                            %continueToBigLoop = true;
                        case 13
                            continueToBigLoop = true;
                        case 97
                            %clim(1) = ceil(clim(1)*0.5)
                            clim(i, 1) = clim(i, 1) - jump;
                            continueToBigLoop = true;
                        case 113
                            %clim(1) = min(min(ceil(clim(1)*2),2^16),clim(2));
                            clim(i, 1) = clim(i, 1) + jump;
                            continueToBigLoop = true;
                        case 115
                            %clim(2) = max(ceil(clim(2)*0.5),clim(1))
                            clim(i, 2) = clim(i, 2) - jump;
                            continueToBigLoop = true;
                        case 119
                            %clim(2) = min(ceil(clim(2)*2),2^16);
                            clim(i, 2) = clim(i, 2) + jump;
                            continueToBigLoop = true;
                            
                        case 122
                            set(gcf, 'CurrentCharacter', ' ');
                            waitfor(gcf, 'CurrentCharacter', char(120));
                            continueToBigLoop = true;
                            %                    case 120
                        case 116 % 't' will turn on threshold mode
                            thApply(i) = true;
                            thOld(i) = -1; % will make it update the threshold image because old != new
                            continueToBigLoop = true;
                        case 103 % 'g' will turn of threshold mode
                            thApply(i) = false;
                            thOld(i) = -1; % will make it update the threshold image because old != new
                            continueToBigLoop = true;
                            
                            
                    end
                    
                    userinput = button;
                    
                end
                
                
            end
            
            if (userinput == 13)
                break;
            end
            
        end
        
    end
    


end

if (props.keepPos)
    res.nextFigPos = get(h, 'Position');
end
close(h);


% remove all referenced extracted points that were not filled by all the subplots
refPoint = 1;
for i = 1 : size(points,3)
    curPoints = points(:,:,i);
    
    if (any(all(points(:,:,refPoint) == unfilledPointVals, 2))) 
        points(:,:,i) = [];
    else
        refPoint = refPoint + 1;
    end
    
end

res.points = points;

end


function props = parseParams(v)
% default:
props = struct(...
    'src','',...
    'linkaxes',false,...
    'treatTitle', '',...
    'linking', false, ...
    'keepPos', false, ...
    'figPos', [] ...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'linkaxes'))
        props.linkaxes = v{i+1};
    elseif (strcmp(v{i}, 'treatTitle'))
        props.treatTitle = v{i+1};
    elseif (strcmp(v{i}, 'linking'))
        props.linking = v{i+1};      
    elseif (strcmp(v{i}, 'keepPos'))
        props.keepPos = v{i+1};
    elseif (strcmp(v{i}, 'figPos'))
        props.figPos = v{i+1};           
    end
    
end

end