function RX = randByDistrib(X, Y, n)

% returns a random number between min(X) and max(Y) when the
% probability of getting each number is determined by its corresponding
% frequency in Y
% n - number of random numbers to generate
% returns the list of n random numbers in a row

% debugging
% X = [12, 100, 200, 500, 750, 1000];
% Y = [0, 3, 6, 2, 1.5, 1];
% Y = [10, 50, 60, 800, 100, 50];

% sort X and Y accordingly
[Xs, sortedInds] = sort(X);
Ys = Y(sortedInds);
X = Xs;
Y = Ys;

KX = min(X):0.1:max(X);
KY = interp1(X,Y,KX);

GY = cumsum(KY);

gmin = min(GY);
gmax = max(GY);

r = rand(n,1);
R = (gmax-gmin)*r + gmin;

RX = [];

for i = 1:numel(R)
    [~,minidx] = min(abs(GY-R(i)));
    RX(i) = KX(minidx);
end


% % visualize histogram of random distribution
% figure
% hold on
% plot(KX,KY)
% [N,edges] = histcounts(RX,12:1000);
% yyaxis right
% bar(edges(1:end-1),N)
% ylim([0,max(N)])


end