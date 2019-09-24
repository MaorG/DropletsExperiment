function I = generatePointPattern(data, parameters)

props = parseParams(parameters);

N = data.properties.(props.N);
h = data.properties.(props.h);
w = data.properties.(props.w);
typeName = data.properties.(props.type);
I = zeros(h,w);


if (strcmp(typeName, 'random'))
    I(randi(numel(I),[N,1])) = 1;
elseif (strcmp(typeName, 'uniform'))
    l = ceil(sqrt((h*w)/N));
    cols = ceil(w/l);
    rows = ceil(h/l);
    
    for ri = 0:rows
        for ci = 0:cols
            I(floor(l/2)+l*ri, floor(l/2)+l*ci) = 1;
        end
    end
    
elseif (strcmp(typeName, 'flowers'))    
    r = data.properties.(props.r);
    Nf = floor(N/7);
    % create one flower
    flower = zeros(2*r + 1);
    flower(r+1,r+1) = 1;
    for alpha = (pi/3):(pi/3):2*pi
        x = floor(1 + r + (r*cos(alpha)))
        y = floor(1 + r + (r*sin(alpha)))
        flower(x,y) = 1;
    end
    % now place it randomly on top of the image
    for i = 1:Nf
        rx = randi(h-2*r-1);
        ry = randi(w-2*r-1);
        I(rx:(rx + 2*r),ry:(ry + 2*r)) = I(rx:(rx + 2*r),ry:(ry + 2*r)) | flower;
    end
    
end
   

end


function props = parseParams(v)
% default:
props = struct(...
    'N','N',...
    'w','w',...
    'h','h',...
    'r','r',...
    'type','type'...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'N'))
        props.N = v{i+1};
    elseif (strcmp(v{i}, 'w'))
        props.w = v{i+1};
    elseif (strcmp(v{i}, 'h'))
        props.w = v{i+1};
    elseif (strcmp(v{i}, 'r'))
        props.w = v{i+1};
    elseif (strcmp(v{i}, 'type'))
        props.type = v{i+1};
    end
end

end
