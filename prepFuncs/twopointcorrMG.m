function [ allCorrC ] = twopointcorrMG(w,h, x,y, dr, margin)

pixel2um = 0.16 
% todo...

dr = dr;
maxr = margin;
r = 0:dr:maxr;

N = numel(x);

marginPixels = margin/pixel2um;
inside = (x>marginPixels & x<(w-marginPixels) & y>marginPixels & y<(h-marginPixels));
w
h

ind = sub2ind([h,w],x,y);

spd = squareform(pdist([x,y]));

spd = spd*pixel2um;

av_dens = N/((h*w)*(pixel2um*pixel2um));

rareas = (2*pi*r*dr);

rareas = pi*r.*r;
rareas = rareas(2:end)-rareas(1:end-1);
rareas(end+1) = rareas(end);


allCorr = zeros(size(r(1:end-1)));
for i = 1:numel(x)
    if inside(i)
        column = spd(:,i); 
        column(i) = [];
        corr = histcounts(column,r);
        % don't count self
        
        allCorr = (corr/N)+allCorr;
    end
end

allCorrC = allCorr ./ rareas(1:end-1);
allCorrC = allCorrC/(N*sum(inside)/N);

allCorrC = allCorr ./ rareas(1:end-1);
%allCorrC = allCorrC/(sum(inside)/N)/(av_dens);
allCorrC = allCorrC/(av_dens)/(sum(inside)/N);


end