function [ allCorrC ] = twopointcrosscorrMG(w,h, x1,y1, x2, y2, dr, meanBinWin, rolling, margin)

pixel2um = 0.16 

if rolling
    dr = dr/meanBinWin;
end
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

av_dens = (N1*N2)/((h*w)*(pixel2um*pixel2um));

rareas = (2*pi*r*dr);

rareas = pi*r.*r;
rareas = rareas(2:end)-rareas(1:end-1);
rareas(end+1) = rareas(end);


%allCorr = zeros(size(r(1:end-1)));
allCorr = zeros(size(r(1:end-1)));
for i = 1:numel(x1)
    if inside1(i)
        column = spd(i,:); 
        %column(i) = [];
        corr = histcounts(column,r);
        allCorr = (corr)+allCorr;
    end
end

allCorrC = allCorr ./ rareas(1:end-1);
allCorrC = allCorrC/(av_dens)/(sum(inside1)/N1);

allCorrC = movingAverage(allCorrC, meanBinWin);

if rolling
    allCorrM = reshape(allCorrC,[meanBinWin, numel(allCorrC)/meanBinWin ]);
    allCorrC = mean(allCorrM, 1);
end

end

function res = movingAverage(A, m)

M = movsum(A,[m-1, 0]);

S(1:m) = 1:m;
S = repmat(m,size(A));
S(1:m) = 1:m;
res = M./S;




end