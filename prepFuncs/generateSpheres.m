function I = generateSpheres(data, parameters)

props = parseParams(parameters);

N = data.properties.(props.N);
h = data.properties.(props.h);
w = data.properties.(props.w);
typeName = data.properties.(props.type);
I = zeros(h,w);


if (strcmp(typeName, 'random'))
    rSphere = data.properties.(props.rs);
    I(randi(numel(I),[floor(N/2),1])) = 1;
    I(randi(numel(I),[floor(N/2),1])) = 2;
    disk = getDisk(rSphere);
    I1 = conv2(I==1,disk,'same');
    I2 = conv2(I==2,disk,'same');
    I(I1 ~= 0) = 1;
    I(I2 ~= 0) = 2;

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
    rSphere = data.properties.(props.rs);
    Nf = floor(N/7);
    % create one flower
    flower = zeros(2*r + 1);
    flower(r+1,r+1) = 1;
    for alpha = (pi/3):(pi/3):2*pi
        x = floor(1 + r + (r*cos(alpha)))
        y = floor(1 + r + (r*sin(alpha)))
        flower(x,y) = 2;
    end
    % now place it randomly on top of the image
    for i = 1:Nf
        rx = randi(h-2*r-1);
        ry = randi(w-2*r-1);
        temp = I(rx:(rx + 2*r),ry:(ry + 2*r)) ;
        temp(flower == 1) = 1;
        temp(flower == 2) = 2;
        I(rx:(rx + 2*r),ry:(ry + 2*r)) = temp;
    end
    % now conv2 each code with disk
    
    disk = getDisk(rSphere);
    I1 = conv2(I==1,disk,'same');
    I2 = conv2(I==2,disk,'same');
    I(I1 ~= 0) = 1;
    I(I2 ~= 0) = 2;
    
    IR = zeros(w,h);
    IR(randi(numel(IR),[floor(6*N/7),1])) = 2;
    disk = getDisk(rSphere);
    IR2 = conv2(IR==2,disk,'same');
    I(IR2 ~= 0) = 2;
end
   

end


function disk = getDisk(radius)
dx = -radius:radius;
dy = -radius:radius;
[DX, DY] = meshgrid(dx,dy);
disk = (DX.*DX)+(DY.*DY) <= radius*radius;
end

function props = parseParams(v)
% default:
props = struct(...
    'N','N',...
    'w','w',...
    'h','h',...
    'r','r',...
    'rs', 'rs',...
    'type','type'...
    )

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'N'))
        props.N = v{i+1};
    elseif (strcmp(v{i}, 'w'))
        props.w = v{i+1};
    elseif (strcmp(v{i}, 'h'))
        props.h = v{i+1};
    elseif (strcmp(v{i}, 'r'))
        props.r = v{i+1};
    elseif (strcmp(v{i}, 'rs'))
        props.rs = v{i+1};
    elseif (strcmp(v{i}, 'type'))
        props.type = v{i+1};
    end
end

end
