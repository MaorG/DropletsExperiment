function result = getCellEvo(entities, parameters, am)

props = parseParams(parameters);

% get param names
fns = fieldnames(entities(1).dataParameters);

% TODO: struct creation is messy...
for ei = numel(entities):-1:1
    res(ei) = entities(ei).dataParameters;
end

[res.val] = deal([]);

for ei = numel(entities):-1:1
    if (isfield(entities(ei).dataProperties, 'prevUID'))
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
            nextEntities = am.enm.getEntitiesByDataUID(currEntities.entName, currEntities.dataProperties.nextUID);
            linkedEntities = [linkedEntities, nextEntities]
            %currID = nextID;
            currEntities = nextEntities;
            if isfield(currEntities.dataProperties,'nextUID')
                %nextID = currEntities.dataProperties.nextUID;
            else 
                reachedEnd = true;
            end
        end

        % TODO - parametrize
        
        linkedEntities
        
        listLength = numel(linkedEntities);
        areasStart = zeros(size(linkedEntities{1}.area));
        dAreasStart = zeros(size(linkedEntities{1}.area));
        areasEnd = zeros(size(linkedEntities{1}.area));
        dAreasEnd = zeros(size(linkedEntities{1}.area));
        ratioStart = zeros(size(linkedEntities{1}.area));
        ratioEnd = zeros(size(linkedEntities{1}.area));
        
        for ci = 1:numel(linkedEntities{1}.area)
            t = 1;
            % track only cells that reached the end (why?)
            areasStart(ci) = linkedEntities{1}.area(ci);
            ratioStart(ci) = linkedEntities{1}.ldratio(ci);
            if (isempty(linkedEntities{1}.dArea{ci}))
                dAreasStart(ci) = 0;
                
            else
                dAreasStart(ci) = linkedEntities{1}.dArea{ci}(1);
            end
            
            
            noNext = false;
            reachedEnd = true;
            last_ci = ci;
            while (~noNext && t < listLength)
                
                elemNextIdx = linkedEntities{t}.nextIdx{last_ci};
                if (~isempty(elemNextIdx))
                    if false & numel(elemNextIdx) ==1
                        last_ci = elemNextIdx;
                    else
                        temp_area =  linkedEntities{t+1}.area(elemNextIdx);
                        [~,maxIdx] = max(temp_area);
                        last_ci = elemNextIdx(maxIdx); %perhaps look for largest, not first
                    end
                    
                else
                    noNext = true;
                    reachedEnd = false;
                end
                t = t+1;

            end
            if (~noNext && reachedEnd)
                
                
                
                
                
                
                if numel(linkedEntities{end}.area(last_ci)) == 1
                    areasEnd(ci) = linkedEntities{end}.area(last_ci);
                    ratioEnd(ci) = linkedEntities{end}.ldratio(last_ci);
                else
                    areasEnd(ci) = max(linkedEntities{end}.area(last_ci));
                    ratioEnd(ci) = max(linkedEntities{end}.ldratio(last_ci));
                end
                if (~isempty(linkedEntities{end}.dArea{last_ci}))

                    dAreasEnd(ci) = linkedEntities{end}.dArea{last_ci}(1);
                else
                    dAreasEnd(ci) = 0;
                    dAreasEnd(ci) = 0;
                end
            end
            
            
           

        end
        pA = (entities(ei).dataParameters.pixelSize)^2;
        areasStart = areasStart*pA;
        dAreasStart = dAreasStart*pA;
        areasEnd = areasEnd*pA;
        dAreasEnd = dAreasEnd*pA;
        res(ei).val = cat(3, ...
                cat(2,areasStart,dAreasStart, ratioStart), ...
                cat(2,areasEnd,dAreasEnd, ratioEnd))
            
        midx = find(res(ei).val(:,2,2));
        res(ei).val = res(ei).val(midx,:,:);
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
    'cellArea','area', ...
    'dropArea','dArea', ...
    'intensity','meanBioRep' ...
    );

for i = 1:numel(v)
    if (strcmp(v{i}, 'cellArea'))
        props.cellArea = v{i+1};
    elseif (strcmp(v{i}, 'dropArea'))
        props.dropArea = v{i+1};
    elseif (strcmp(v{i}, 'intensity'))
        props.intensity = v{i+1};
    end
end

end


