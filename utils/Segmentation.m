classdef Segmentation
    %SEGMENTATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % original Image
        I
        
        
        % image props
        Isize % should be used to clear boundaries to avoid laplacian artifacts
        scale % hmmm
        
        
        % binary Images
        BW
        BWcells
        BWclusters
        
        % process properties
        laplacian
        threshold
        minArea
        maxArea
        clusterDilateRadius
        
        % results
        cells
        clusters
        
    end
    
    methods
        
        function S = createLaplacian(S, n)
            
            S.laplacian = S.createLap(n);
            
        end
        
        function S = toBinary(S)
            
            NI = conv2(single(S.I), single(S.laplacian), 'same');
            
            NI = S.normalizeImage(NI);
            
            S.BW = NI > S.threshold;
            
            se = strel('disk',1);
            S.BW = imopen(S.BW, se);
            S.BW = imclearborder(S.BW);
        end
        
        function S = getCells(S)
            
            if (isempty(S.minArea))
                S.minArea = 20;
            end
            if (isempty(S.maxArea))
                S.maxArea = 1000;
            end
            
            S.BWcells = S.getBWCellsFromBinaryAux(S.BW, S.minArea, S.maxArea);
            
        end
        
        function S = getClusters(S)
            if isempty(S.clusterDilateRadius)
                S.clusterDilateRadius = 10;
            end
            se = strel('disk',S.clusterDilateRadius);
            S.BWclusters = imdilate(S.BWcells, se);
            
            S.BWclusters = imerode(S.BWclusters, se);
            
            
            cellsCC = bwconncomp(S.BWcells);
            LabeledCells = labelmatrix(cellsCC);
            clustersCC = bwconncomp(S.BWclusters);
            
            rp = regionprops(clustersCC, 'BoundingBox', 'Image');
            
            S.clusters = [];
            BB = cat(1, rp.BoundingBox);
            for ci = 1:size(BB,1)
                BBi = ceil(BB(ci,:));
                cellsInBB = S.BWcells(BBi(2):(BBi(2)+BBi(4)-1), BBi(1):(BBi(1)+BBi(3)-1));
                

                
                LabeledCellsInBB = LabeledCells(BBi(2):(BBi(2)+BBi(4)-1), BBi(1):(BBi(1)+BBi(3)-1));
                clusterInBB = rp(ci).Image;
                
                % !!! make sure counting only cells in cluster, not cells
                % in BB - folowing line should do this
                LabeledCellsInBB = bsxfun(@times, LabeledCellsInBB, cast(clusterInBB, 'like', LabeledCellsInBB));
                cluster = struct;
                
                LabelsInBB = unique(LabeledCellsInBB);
                LabelsInBB = LabelsInBB(LabelsInBB ~= 0);

                cluster.BB = BBi;
                %cluster.Image = 0.5*(cellsInBB + rp(ci).Image);
                cluster.count = numel(LabelsInBB);
                cluster.cellIds = LabelsInBB;
                
                S.clusters = [S.clusters, cluster];
            end
            
        end
        
        function S = getClustersAndAreas(S)
            if isempty(S.clusterDilateRadius)
                S.clusterDilateRadius = 10;
            end
            se = strel('disk',S.clusterDilateRadius);
            S.BWclusters = imdilate(S.BWcells, se);
            
            S.BWclusters = imerode(S.BWclusters, se);
            
            
            cellsCC = bwconncomp(S.BWcells);
            LabeledCells = labelmatrix(cellsCC);
            clustersCC = bwconncomp(S.BWclusters);
            
            rp = regionprops(clustersCC, 'Area');
            
            S.clusters = [];
            areas = cat(1, rp.Area);

            for ci = 1:size(areas,1)
                cluster = struct('area', areas(ci));
                S.clusters = [S.clusters, cluster];
            end
        end
        
        function prop = getCellsProperty(S, propName)
            CC = bwconncomp(S.BWcells, 4);
            rprop = regionprops(CC, propName);
            prop = rprop;
        end
        
    end
    
    methods(Static)
        
        function NIm = normalizeImage(Im)
            ImF = single(Im);
            NIm = ImF - single(min(Im(:)));
            NIm = NIm ./ single(max(NIm(:)));
        end
        
        function L = createLap(n)
            A1 = n*n;
            
            L = - A1 * ones(n+2,n+2);
            L(2:end-1, 2:end-1) = 0;
            
            A2 = - sum(L(:)) ./ (n*n);
            
            L(2:end-1, 2:end-1) = A2;
            
        end
        
        
        function BWcells = getBWCellsFromBinaryAux(BW, minArea, maxArea)
            
            cellsCC = bwconncomp(BW);
            rp = regionprops(cellsCC, 'PixelIdxList', 'Area');
            areas = cat(1, rp.Area);
            if (isempty(minArea))
                minArea = 10;
            end
            if (isempty(maxArea))
                maxArea = 1000;
            end
            ids = find(areas > minArea & areas < maxArea);
            
            BWcells = false(size(BW));
            
            for id = ids'
                BWcells(cellsCC.PixelIdxList{id}) = 1;
            end
        end
        
        
        function prop = getCellsPropertyAux(BWcells, propName)
            CC = bwconncomp(BWcells);
            prop = regionprops(CC, propName);
        end
        
        
    end
    
end

