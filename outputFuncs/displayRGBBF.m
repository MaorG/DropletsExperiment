function displayRGBBF(m, parameters)

props = parseParams(parameters);

channels = cell(0);
cindices = zeros(3,1);

if (~isempty(props.R))
    channels{1} = mat2gray(m.(props.R), props.Rscale);
    cindices(1) = 1;
end
if (~isempty(props.G))
    channels{2} = mat2gray(m.(props.G), props.Gscale);
    cindices(2) = 1;
end
if (~isempty(props.B))
    channels{3} = mat2gray(m.(props.B), props.Bscale);
    cindices(3) = 1;
end

BG = m.(props.BG);

for i = 1:3
    if isempty(channels{i})
        Isize = size(channels{find(cindices, 1 )});
        channels{i} = zeros(Isize);
    end
end

BG = mat2gray(BG);
imshow(cat(3,channels{1}+BG,channels{2}+BG,channels{3}+BG));

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
    'BG', [] ...
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
        
    end
end

end

