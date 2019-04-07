function res = alexaSeg(data,parameters)
    
    props = parseParams(parameters);
    
    s = data.(props.src);

    g = imgradient(s);
    
    tic
    [Mrdg, Mriv, Medg] = getContours(s);
    toc
    
    figure;
    imshow(cat(3,mat2gray(g,[0,1000]),mat2gray(s),0*mat2gray(g)));
    figure;
    imshow(double(cat(3,Mrdg,Mriv,Medg)));
    
    res = [];
end

function props = parseParams(v)
% default:
props = struct(...
    'src','I',...
    'thresh','6'...
    );

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'src'))
        props.src = v{i+1};
    elseif (strcmp(v{i}, 'thresh'))
        props.dist = v{i+1};

    end
end

end