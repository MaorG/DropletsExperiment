function result = getDropEvo(entities, parameters, am)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataProperties;
end

[res.val] = deal([]);

largestRatio = 0;

for ei = numel(entities):-1:1
    %if (isfield(entities(ei).dataProperties, 'prevUID'))
    if (isfield(entities(ei).dataProperties, 'prevEntity'))
        % not first
        res(ei).val = [];
    else
        % get linked entities
        currEntities = entities(ei);
        linkedEntities = {currEntities};
        reachedEnd = false;
        while (~reachedEnd)
            % todo:
            % just use pointers already !!!
            %nextEntities = am.enm.getEntitiesByDataUID(currEntities.entName, currEntities.dataProperties.nextUID);
            nextEntities = currEntities.dataProperties.nextEntity;
            linkedEntities = [linkedEntities, {nextEntities}];
            %currID = nextID;
            currEntities = nextEntities;
            if isfield(currEntities.dataProperties,'nextEntity')
                %nextID = currEntities.dataProperties.nextUID;
            else 
                reachedEnd = true;
            end
        end

        % TODO - parametrize
        
        linkedEntities % *all* droplets in all timepoints FoV
        % not just a "current" and "next" pair
        
        linkedEntities{1} % starting droplets
        
        % get index of all drops that did not split or join (currently
        % works with 2 timepoints; requires recursion for more)
        goodIndicesList = [];
        if (numel(linkedEntities) ~= 2)
            continue;
        end
        nextIdxList = linkedEntities{1}.nextIdx;
        prevIdxList = linkedEntities{2}.prevIdx;
        for ci = 1:numel(nextIdxList)
            curNextIdx = nextIdxList{ci};
            % check if "good"
            if (numel(curNextIdx) == 1) && (all(prevIdxList{curNextIdx} == ci))
                % filter by size
                time1Pix = linkedEntities{1}.dataProperties.pixelSize;
                time2Pix = linkedEntities{2}.dataProperties.pixelSize;
                minSizeTime1 = 300 / (time1Pix^2);
                minSizeTime2 = 150 / (time2Pix^2);
                if (linkedEntities{1}.area(ci) >= minSizeTime1 && linkedEntities{2}.area(curNextIdx) >= minSizeTime2)
                    goodIndicesList = [goodIndicesList; ci curNextIdx];
                end 
            end
                
        end

        
        listLength = numel(linkedEntities);
        areasStart = zeros(size(goodIndicesList, 1), 1);
        %areasStartInds = zeros(size(goodIndicesList, 1), 1); % saving indices for debugging
        cAreasStart = zeros(size(areasStart));
        ratioStart = zeros(size(areasStart));
        areasEnd = zeros(size(goodIndicesList, 1), 1);
        %areasEndInds = zeros(size(goodIndicesList, 1), 1); % saving indices for debugging
%         dAreasEnd = zeros(size(linkedEntities{1}.area));
%         ratioStart = zeros(size(linkedEntities{1}.area));
%         ratioEnd = zeros(size(linkedEntities{1}.area));
        
        for ci = 1:size(goodIndicesList, 1)
            t = 1;
            ind = goodIndicesList(ci);
            % track only cells that reached the end (why?)
            areasStart(ci) = linkedEntities{1}.area(ind);
            %areasStartInds(ci) = ind; % saving indices for debugging
            cAreasStart(ci) = sum(cell2mat(linkedEntities{1}.cArea(ind)));
            liveAreaTemp = sum(cell2mat(linkedEntities{1}.cLDRatio(ind)) .* cell2mat(linkedEntities{1}.cArea(ind)) );
            ratioStart(ci) = liveAreaTemp ./ cAreasStart(ci);
%             if (isempty(linkedEntities{1}.dArea{ci}))
%                 dAreasStart(ci) = 0;
%                 
%             else
%                 dAreasStart(ci) = linkedEntities{1}.dArea{ci}(1);
%             end
            
            
            noNext = false;
            reachedEnd = true;
            last_ind = ind;
            while (~noNext && t < listLength)
                
                elemNextIdx = linkedEntities{t}.nextIdx{last_ind};
                if (~isempty(elemNextIdx))
                    if false & numel(elemNextIdx) ==1
                        last_ind = elemNextIdx;
                    else
                        temp_area =  linkedEntities{t+1}.area(elemNextIdx);
                        [~,maxIdx] = max(temp_area);
                        last_ind = elemNextIdx(maxIdx); %perhaps look for largest, not first
                    end
                    
                else
                    noNext = true;
                    reachedEnd = false;
                end
                t = t+1;

            end
            if (~noNext && reachedEnd)
                
                if numel(linkedEntities{end}.area(last_ind)) == 1
                    areasEnd(ci) = linkedEntities{end}.area(last_ind);
                    %areasEndInds(ci) = last_ind; % saving indices for debugging
                    ratioEnd(ci) = linkedEntities{end}.cLDRatio(last_ind);
                else
                    areasEnd(ci) = max(linkedEntities{end}.area(last_ind));
                    %areasEndInds(ci) = last_ind; % saving indices for debugging
                    ratioEnd(ci) = max(linkedEntities{end}.cLDRatio(last_ind));
                end
%                 if (~isempty(linkedEntities{end}.dArea{last_ci}))
% 
%                     dAreasEnd(ci) = linkedEntities{end}.dArea{last_ci}(1);
%                 else
%                     dAreasEnd(ci) = 0;
%                     dAreasEnd(ci) = 0;
%                 end
            end
            
            
           

        end
        pA = (entities(ei).dataParameters.pixelSize)^2;
        areasStart = areasStart*pA;
        cAreasStart = cAreasStart*pA;
        
        areasEnd = areasEnd*pA;
        %dAreasEnd = dAreasEnd*pA;
%         res(ei).val = cat(3, ...
%                 cat(2,areasStart,dAreasStart, ratioStart), ...
%                 cat(2,areasEnd,dAreasEnd, ratioEnd))
        res(ei).val.areasStart = areasStart;
        res(ei).val.areasEnd = areasEnd;
        res(ei).val.cAreasStart = cAreasStart;
        res(ei).val.ratioStart = ratioStart;
        

        % save data parameters too in val to later reference them for
        % customization of each plot according to parameters
        for i = 1 : numel(fns)
            res(ei).val.dataParameters.(fns{i}) = res(ei).(fns{i});
        end
        
        largestRatio = max(largestRatio, max(areasEnd ./ areasStart));
        
        
        if props.verbose % && strcmp([linkedEntities{1}.dataParameters.well, '.', num2str(linkedEntities{1}.dataParameters.repeat)], 'b3.2')
            
            
            figure;
            hold on;
            
            titl = '';
            verTitlePar = props.verboseTitlePar;
            verTitleText = props.verboseTitleText;
            titlePar = linkedEntities{1}.dataParameters.(verTitlePar);
            if (isnumeric(titlePar))
                titlePar = num2str(titlePar);
            end
            titlePos = find(strcmp(verTitleText, titlePar));
            titlePos = titlePos(1) + 1;
            if (titlePos <= numel(verTitleText))
                titl = verTitleText{titlePos};
            end
            titl = [titl, ' ', linkedEntities{1}.dataParameters.well, '.', num2str(linkedEntities{1}.dataParameters.repeat)];
            set(gcf,'Name',titl,'NumberTitle','off')
            
            im = zeros(size(linkedEntities{1}.seg));
            rgb = struct('r', im, 'g', im, 'b', im);
            verPar = props.verbosePar;
            verClrs = props.verboseColors;
            
            linesList = [];
            
            centersList = [];
            for i = 1 : numel(linkedEntities)
                curEnts = linkedEntities{i};
                clrPar = curEnts.dataParameters.(verPar);
                if (isnumeric(clrPar))
                    clrPar = num2str(clrPar);
                end
                clrPos = find(strcmp(verClrs, clrPar));
                clrPos = clrPos(1) + 1;
                if (clrPos <= numel(verClrs) && any(strcmp({'r' 'g' 'b'}, verClrs{clrPos})))
                    oldIm = curEnts.dataHandle.(props.verboseImageOld) * 100;
                    newIm = curEnts.dataHandle.(props.verboseImageNew) * 255;
                    oldIm(find(newIm)) = newIm(find(newIm));
                    oldIm = uint8(oldIm);
                    rgb.(verClrs{clrPos}) = oldIm;
                end
                curGoodIndices = goodIndicesList(:, i);
                
                centersList = [];
                for gi = 1 : numel(curGoodIndices)
                    centersList = [centersList; [curEnts.center{curGoodIndices(gi)}(2) curEnts.center{curGoodIndices(gi)}(1)]];
                end
                
                % the following portion is used to save a mask for the
                % centers of the filtered objects to later use in gimp for
                % more precise segmentation on the relevant objects only
                if (props.verboseCircleSize > 0)
                    filteredIm = zeros(size(curEnts.dataHandle.(props.verboseImageOld)));
                    %circlesCoor = [centersList, repmat(props.verboseCircleSize, size(centersList, 1), 1)]; % add radius size 
                    circlesSize = props.verboseCircleSize;
                    for c = 1 : size(centersList, 1)
                        filteredIm = drawRect(filteredIm, centersList(c, 1), centersList(c, 2), circlesSize);
                    end
                    %filteredIm = logical(insertShape(filteredIm, 'FilledCircle', circlesCoor));
                    %filteredIm = filteredIm(:,:,1);
                    if (~isempty(props.verboseFilteredMasksPath))
                        fDir = fullfile(am.dm.rootName, props.verboseFilteredMasksPath);
                        if (~exist(fDir, 'dir'))
                            mkdir(fDir);
                        end
                        fName = [titl, ' time ', num2str(i), '.tif'];
                        imwrite(filteredIm, fullfile(fDir, fName));
                    end
                end
                    
                linesList = [linesList, centersList];
            end
            
            imshow(cat(3, rgb.r, rgb.g, rgb.b));
            
            a = [];
            for gi = 1 : size(linesList, 1)
                line([linesList(gi, [4,2])], [linesList(gi, [3,1])], 'Color', 'b', 'LineWidth', 2);
                text(mean([linesList(gi, [4,2])]),mean([linesList(gi, [3,1])]), num2str(linkedEntities{2}.area(goodIndicesList(gi, 2)) / linkedEntities{1}.area(goodIndicesList(gi, 1))), 'Color', 'blue');
                a = [a, linkedEntities{2}.area(goodIndicesList(gi, 2)) / linkedEntities{1}.area(goodIndicesList(gi, 1))];
            end
            % the following is for debugging a particular treatment, code
            % portion taken from output
%             if (strcmp(titl, 'Beads b2.3'))
%                 figure;
%                 hold on;
%                 edges = [-inf, logspace(log10(0.5), log10(2), 12), inf];
%                 hc = histcounts(a, edges);
%                 bar(hc);
%                 yl = ylim;
%                 line([7,7],[0,yl(2)],'Color','black','LineStyle','--');
%                 set(gca, 'XTick', 1:numel(hc), 'XTickLabel', createSpacedMatrix(edges, 'range'));
%                 xtickangle(45);
%                 xlabel('new_area/old_area (Time 2 / Time 1)', 'Interpreter', 'none');
%                 ylabel('# of droplets');
%             end
        end

        
        %res(ei).val2 = [areasStartInds, areasEndInds]; % saving indices for debugging
            
%         midx = find(res(ei).val(:,2,2));
%         res(ei).val = res(ei).val(midx,:,:);
    end
end



%nd = createNDResultTable(res, 'val', fns);
nd = NDResultTable(res, 'val', fns);

% TODO: use some func for this - simple concatanation...
for ti = 1:numel(nd.T)
    if (~isempty(nd.T{ti}))
        vv = nd.T{ti}{1};
        for ri = 2:numel(nd.T{ti})
            vv = cat(1, vv, nd.T{ti}{ri});
        end
        nd.T{ti} = cell(0);
        nd.T{ti}{1} = vv;
    end
end

%     bins = [0,logspace(props.bins_min,props.bins_max+props.bins_step,2+(props.bins_max - props.bins_min)/props.bins_step)];
%     % TODO: and for this a simple cellfunc would do...
% 	for ti = 1:numel(nd.T)
%         if (~isempty(nd.T{ti}))
%             areas = nd.T{ti}{1};
%
%             totAreaInBins = [];
%             [Ni,~,binidx] = histcounts(areas,bins);
%             for bi = 1:numel(Ni)
%                 totAreaInBins(bi) = sum(areas(binidx==bi));
%             end
%             relAreaInBins = totAreaInBins / sum(totAreaInBins);
%
%             vva = struct('X', bins(1:end-1), 'Y', relAreaInBins);
%             nd.T{ti}{1} = vva;
%         end
%     end
%
result = nd;

% TODO: and for removing dimension of size 1 (? but what will happen to a
% single data entry ?)

end

function props = parseParams(v)
% default:
props = struct(...
    'cellArea','cArea', ...
    'dropArea','area', ...
    'intensity','meanBioRep', ...
    'verbose', 0, ...
    'verbosePar', 'time', ...
    'verboseColors', {{'1' 'r' '2' 'g'}}, ...
    'verboseTitlePar', 'aem', ...
    'verboseTitleText', {{'1' 'Bacteria' '3' 'Beads'}}, ...
    'verboseImageNew', 'DropMaskF', ...
    'verboseImageOld', 'DropMaskU', ...
    'verboseCircleSize', 0, ...
    'verboseFilteredMasksPath', '' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'dropArea'))
        props.dropArea = v{i+1};
    elseif (strcmp(v{i}, 'intensity'))
        props.intensity = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    elseif (strcmp(v{i}, 'verbosePar'))
        props.verbosePar = v{i+1};
    elseif (strcmp(v{i}, 'verboseColors'))
        props.verboseColors = v{i+1};
    elseif (strcmp(v{i}, 'verboseTitlePar'))
        props.verboseTitlePar = v{i+1};  
    elseif (strcmp(v{i}, 'verboseTitleText'))
        props.verboseTitleText = v{i+1};  
    elseif (strcmp(v{i}, 'verboseImageNew'))
        props.verboseImageNew = v{i+1};          
    elseif (strcmp(v{i}, 'verboseImageOld'))
        props.verboseImageOld = v{i+1};      
    elseif (strcmp(v{i}, 'verboseCircleSize'))
        props.verboseCircleSize = v{i+1};      
    elseif (strcmp(v{i}, 'verboseFilteredMasksPath'))
        props.verboseFilteredMasksPath = v{i+1};              
    end
end

end


