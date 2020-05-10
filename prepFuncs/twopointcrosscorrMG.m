function [ allCorrC ] = twopointcrosscorrMG(w,h, x1,y1, x2, y2, dr, margin)

pixel2um = 0.16 
% todo...

dr = dr;
maxr = margin;
r = 0:dr:maxr;

N1 = numel(x1);
N2 = numel(x2);

marginPixels = margin/pixel2um;
inside1 = (x1>marginPixels & x1<(w-marginPixels) & y1>marginPixels & y1<(h-marginPixels));
w
h

spd = pdist2([x1 y1],[x2 y2]);

spd = spd*pixel2um;

av_dens = N2/((h*w)*(pixel2um*pixel2um));

rareas = (2*pi*r*dr);

rareas = pi*r.*r;
rareas = rareas(2:end)-rareas(1:end-1);
rareas(end+1) = rareas(end);


allCorr = zeros(size(r(1:end-1)));
for i = 1:numel(x1)
    if inside1(i)
        column = spd(i,:); 
        %column(i) = [];
        corr = histcounts(column,r);
        % don't count self
        
        allCorr = (corr/N2)+allCorr;
    end
end

%allCorrC = allCorr ./ rareas(1:end-1);
%allCorrC = allCorrC/(N*sum(inside1)/N);

allCorrC = allCorr ./ rareas(1:end-1);
%allCorrC = allCorrC/(sum(inside)/N)/(av_dens);
allCorrC = allCorrC/(av_dens)/(sum(inside1)/N1)*(N2/N1);


end