function displayErrorBars(m, properties)

errorbar(m.X,m.Y,m.Yste)
set(gca,'xscale','log');
end