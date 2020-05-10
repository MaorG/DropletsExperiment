function displayRGBBF(m, parameters, removedMask)

props = parseParams(parameters);

channels = cell(3, 1);
cindices = zeros(3,1);


if (~isempty(props.R))
    channels{1} = mat2gray(m.(props.R), props.Rscale);
    if (props.encircle(1))
        channels{1} = getBWPerimeter(channels{1}, 1, 2);
    end
    cindices(1) = 1;
end
if (~isempty(props.G))
    channels{2} = mat2gray(m.(props.G), props.Gscale);
    if (props.encircle(2))
        channels{2} = getBWPerimeter(channels{2}, 1, 2);
    end
    cindices(2) = 1;
end
if (~isempty(props.B))
    channels{3} = mat2gray(m.(props.B), props.Bscale);
    if (props.encircle(3))
        channels{3} = getBWPerimeter(channels{3}, 1, 2);
    end
    cindices(3) = 1;
end

colorPos = find(strcmp({'R' 'G' 'B'}, props.MarkColor));
if (~isempty(props.Mark) && ~isempty(colorPos))
    channels{colorPos}(props.Mark) = 1;
end
    
    
BG = m.(props.BG);

for i = 1:3
    if isempty(channels{i})
        Isize = size(channels{find(cindices, 1 )});
        channels{i} = zeros(Isize);
    end
end

BG = mat2gray(BG);

if (exist('removedMask', 'var') && all(size(removedMask) == size(BG)))
         % following gets too dark
%         imshow(imfuse( ...
%         cat(3,channels{1}+BG,channels{2}+BG,channels{3}+BG), ...
%         cat(3,...
%             (removedMask), ...
%             0*removedMask, ...
%             0*removedMask ) ...
%         ,'blend') ...
%         );
    imshow(cat(3,channels{1}+BG+removedMask,channels{2}+BG,channels{3}+BG));
else
    if (size(BG,3) == 1)
        imshow(cat(3,channels{1}+BG,channels{2}+BG,channels{3}+BG));
    else
        imshow(double(cat(3,255*channels{1}+BG(:,:,1),255*channels{2}+BG(:,:,2),255*channels{3}+BG(:,:,2))));
        
    end
    
end

end

function props = parseParams(v)
% default:
props = struct(...
    'R',[],...
    'Rscale',[0,1],...
    'G',[],...
    'Gscale',[0,1],...
    'B',[],...
    'Bscale',[0,1], ...
    'BG', [], ...
    'Mark', [], ...
    'MarkColor', 'R', ...
    'encircle', [0 0 0] ... % vector of 3 numbers representing the offset of each of the R G B, in that order, whether it's on or off; to only encircle the GFP channel, use 0 1 0
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'R'))
        props.R = v{i+1};
    elseif (strcmp(v{i}, 'Rscale'))
        props.Rscale = v{i+1};
    elseif (strcmp(v{i}, 'G'))
        props.G = v{i+1};
    elseif (strcmp(v{i}, 'Gscale'))
        props.Gscale = v{i+1};
    elseif (strcmp(v{i}, 'B'))
        props.B = v{i+1};
    elseif (strcmp(v{i}, 'Bscale'))
        props.Bscale = v{i+1};
	elseif (strcmp(v{i}, 'BG'))
        props.BG = v{i+1};
	elseif (strcmp(v{i}, 'Mark'))
        props.Mark = v{i+1};        
	elseif (strcmp(v{i}, 'MarkColor'))
        props.MarkColor = v{i+1};  
	elseif (strcmp(v{i}, 'encircle'))
        props.encircle = v{i+1};          
        
    end
end

end

