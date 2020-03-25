%  This Matlab code demonstrates an edge-based active contour model as an application of
%  the Distance Regularized Level Set Evolution (DRLSE) formulation in the following paper:
%
%  C. Li, C. Xu, C. Gui, M. D. Fox, "Distance Regularized Level Set Evolution and Its Application to Image Segmentation",
%     IEEE Trans. Image Processing, vol. 19 (12), pp. 3243-3254, 2010.
%
% Author: Chunming Li, all rights reserved
% E-mail: lchunming@gmail.com
%         li_chunming@hotmail.com
% URL:  http://www.imagecomputing.org/~cmli//

function mask = getLevelSet(data, parameters)

props = parseParams(parameters);

map = data.(props.map);
seed = data.(props.seed);

mask = levelSetAux(map*256, seed, props);

if props.verbose
    figure
    imshow(double(cat(3,mat2gray(map),seed>0,mask>0)));
end

end

function finalLSF = levelSetAux(map, seed, props)

G=fspecial('gaussian',15,props.sigma);
Img_smooth=conv2(map,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.

% initialize LSF as binary step function
c0=2;
initialLSF=c0*ones(size(map));
% generate the initial region R0 as a rectangle

if (isempty(seed))
    initialLSF(10:end-10, 10:end-10)=-c0;
else
    initialLSF = 2*c0*seed-c0;
end

phi=initialLSF;

% figure(1);
% mesh(-phi);   % for a better view, the LSF is displayed upside down
% hold on;  contour(phi, [0,0], 'r','LineWidth',2);
% title('Initial level set function');
% view([-80 35]);

if props.verbose
    figure(22222);
    imagesc(map,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    title('Initial zero level contour');
end

potential=2;
if potential ==1
    potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model
elseif potential == 2
    potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
else
    potentialFunction = 'double-well';  % default choice of potential function
end


% start level set evolution
for n=1:props.iter_outer
    phi = drlse_edge(phi, g, props.lambda, props.mu, props.alfa, props.epsilon, props.timestep, props.iter_inner, potentialFunction);
    if props.verbose
        if  1|| mod(n,2)==0
            figure(22222);
            imagesc(map,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
        end
    end
end

% refine the zero level contour by further level set evolution with alfa=0
alfa=0;
iter_refine = 10;
phi = drlse_edge(phi, g, props.lambda, props.mu, props.alfa, props.epsilon, props.timestep, props.iter_inner, potentialFunction);

finalLSF=phi;

if props.verbose
    figure(22222);
    imagesc(map,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    hold on;  contour(phi, [0,0], 'r');
    str=['Final zero level contour, ', num2str(props.iter_outer*props.iter_inner+iter_refine), ' iterations'];
    title(str);
end

end



function props = parseParams(v)
% default:
props = struct(...
    'map','GDM',...
    'seed', 'bactMask', ...
    'verbose', 1 ...
    );


props.timestep=5;  % time step
props.mu=0.2/props.timestep;  % coefficient of the distance regularization term R(phi)
props.iter_inner=5;
props.iter_outer=40;
props.lambda=5; % coefficient of the weighted length term L(phi)
props.alfa=1.5;  % coefficient of the weighted area term A(phi)
props.epsilon=1.5; % papramater that specifies the width of the DiracDelta function
props.sigma=3.5;     % scale parameter in Gaussian kernel

for i = 1:numel(v)
    
    if (strcmp(v{i}, 'map'))
        props.map = v{i+1};
    elseif (strcmp(v{i}, 'seed'))
        props.seed = v{i+1};
    elseif (strcmp(v{i}, 'verbose'))
        props.verbose = v{i+1};
    elseif (strcmp(v{i}, 'lambda'))
        props.lambda = v{i+1};
    elseif (strcmp(v{i}, 'alfa'))
        props.alfa = v{i+1};
    elseif (strcmp(v{i}, 'epsilon'))
        props.epsilon = v{i+1};
    elseif (strcmp(v{i}, 'sigma'))
        props.sigma = v{i+1};
    elseif (strcmp(v{i}, 'iter_outer'))
        props.iter_outer = v{i+1};
    elseif (strcmp(v{i}, 'iter_inner'))
        props.iter_inner = v{i+1};
    elseif (strcmp(v{i}, 'mu'))
        props.mu = v{i+1};
    elseif (strcmp(v{i}, 'timestep'))
        props.timestep = v{i+1};
    end
end

end
