function displayErrorBars(m)

errorbar(m.X,m.Y,m.Yste)
set(gca,'xscale','log');
end