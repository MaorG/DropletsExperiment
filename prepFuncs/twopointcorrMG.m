function [ allCorrC ] = twopointcorrMG(w,h, x,y, dr, margin)

dr = dr;
maxr = w;
r = dr:dr:maxr;

N = numel(x);
inside = (x>margin & x<(w-margin) & y>margin & y<(h-margin));
w
h

ind = sub2ind([h,w],x,y);

spd = squareform(pdist([x,y]));

spd = spd*0.16;

av_dens = N/(h*w);
rareas = (2*pi*r*dr)*av_dens;

allCorr = zeros(size(r(1:end-1)));
for i = 1:numel(x)
    corr = histcounts(spd(:,i),r);
    
    if inside(i)
        allCorr = corr+allCorr;
    end
end

allCorrC = allCorr ./ rareas(1:end-1);
allCorrC = allCorrC/(N*sum(inside)/N);



end