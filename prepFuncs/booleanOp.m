function res = booleanOp(data,parameters)

% parameters:
% src1: fieldname in data, 1st image
% src2: fieldname in data, 2nd image
% op: choose from {'union', 'diff', 'intersect'}

props = parseParams(parameters);

s1 = data.(props.src1);
s2 = data.(props.src2);

if strcmp(props.op, 'union')
    res = s1 | s2;
elseif strcmp(props.op, 'difference')
    res = s1 & ~s2;
elseif strcmp(props.op, 'intersect')
    res = s1 & s2;
end

end

function props = parseParams(v)
% default:
props = struct(...
    'src1','Rmask',...
    'src2','Gmask',...
    'op','union'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src1'))
        props.src1 = v{i+1};
    elseif (strcmp(v{i}, 'src2'))
        props.src2 = v{i+1};
    elseif (strcmp(v{i}, 'op'))
        props.op = v{i+1};
    end
end

end

