%[ corrfun r rw] = twopointcorr( x,y,dr,blksize,verbose)
%
%   Computes the two point correlation function of a 2D lattice
%   of a fixed width and height
%
%   x - list of x coordinates of points
%   y - list of y coordinates of points
%   dr - binning distance for successive circles
%   blksize - optional, default 1000, number of points to be considered
%   in a single step.
%   verbose - if true, will print which step is currently processed
%
%   coorfun - two point correlation function
%   r - r-coordinates for the coordfun
%   rw - number of particles that participated in particular r value 
%   corrfun computation. Low rw means corrfun is unreliable at that r.
%
%   Developed by Ilya Valmianski
%   email: ivalmian@ucsd.edu

function [ corrfun r rw] = twopointcrosscorr( x1,y1,x2,y2,dr,maxR,blksize,verbose)
    
    %validate input     
    if length(x1)~=length(y1),
        error('Length of x should be same as length of y'); 
    elseif  numel(dr)~=1,
        error('dr needs to have numel==1');
    elseif numel(x1)~=length(x1) || numel(y1)~=length(y1),
        error('Require x and y to be 1D arrays');
    end

    if length(x2)~=length(y2),
        error('Length of x should be same as length of y'); 
    elseif  numel(dr)~=1,
        error('dr needs to have numel==1');
    elseif numel(x2)~=length(x2) || numel(y2)~=length(y2),
        error('Require x and y to be 1D arrays');
    end

    x1 = reshape(squeeze(x1),[length(x1) 1]);
    y1 = reshape(squeeze(y1),[length(y1) 1]);
    x2 = reshape(squeeze(x2),[length(x2) 1]);
    y2 = reshape(squeeze(y2),[length(y2) 1]);
    
    %validate/set blksize
    if nargin < 4
        blksize = 1000;
    elseif numel(blksize)~=1,
        error('blksize must have numel = 1');
    elseif blksize < 1,
        blksize = 1;
    elseif isinf(blksize) || isnan(blksize),
        blksize = length(x2);
    end
    
    %validate/set verbose
    if nargin ~= 5,
        verbose = false;
    elseif numel(verbose)~=1,
        error('verbose must have numel = 1');
    end   
        
        
    %real height/width
    width1 = max(x1)-min(x1);
    height1 = max(y1)-min(y1);
    width2 = max(x2)-min(x2);
    height2 = max(y2)-min(y2);
    
    width = max(width1,width2);
    height = max(height1, height2);
    
    %number of particles
    totalPart1 = length(x1);
    totalPart2 = length(x2);
    
    %largest radius possible
    %maxR = sqrt((width/2)^2 + (height/2)^2);
    
    %r bins and area bins
    r = dr:dr:maxR;
    av_dens = totalPart1/width/height;
    rareas = ((2*pi*r* dr)*av_dens);
    
    %preallocate space for corrfun/rw
    corrfun = r*0;
    rw = r*0;
    
    %number of steps to be considered
    numsteps = ceil(totalPart2 / blksize);
    
    for j = 1:numsteps,
 
        %loop through all particles and compute the correlation function
        indi = (j-1)*blksize+1;
        indf = min(totalPart2,j*blksize);
        
        if verbose,
            disp(['Step ' num2str(j) ' of ' num2str(numsteps) '. ' ...
                'Analyzing points ' num2str(indi) ' to '  num2str(indf)...
                ' of total ' num2str(totalPart)]);
        end
        
        
        [corrfunArr rwArr] = ...
            arrayfun(@ (xj,yj) onePartCorr(xj,yj,x1,y1,r,rareas),...
            x2(indi:indf),y2(indi:indf),'UniformOutput',false);
        
        if (numel(rwArr) ~= 0)
            rw = rw + sum(cell2mat(rwArr),1);
        
            corrfun =  corrfun + sum(cell2mat(corrfunArr),1);
        end

      
    end
   
    corrfun = corrfun ./ rw;
    
    %truncate values that have not had contirbutions
    corrfun = corrfun(rw~=0);
    r = r(rw~=0);
    rw = rw(rw~=0);
    
end

function [corrfun rw] = onePartCorr(xj,yj,x,y,r,rareas)

    %compute radiuses in the (xj,yj) centered coordinate system
    rho=hypot(x-xj,y-yj);
    rho=rho(logical(rho))';

    %compute maximum unbiased rho
    maxRho = min([max(x)-xj,xj-min(x),max(y)-yj,yj-min(y)]);
    
    %truncate to highest unbiased rho
    rho=rho(rho<maxRho);
    
    %indicate for which r-values the correlation function is computed
    rw=r*0;
    rw(r<maxRho)=1;

    %compute count with correct binning
    count=histc( rho,[-inf r]');
    count=count(2:end);

    %normalize density
    corrfun = count./rareas;  


end