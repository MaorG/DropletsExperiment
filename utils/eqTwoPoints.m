function [slope, intercept] = eqTwoPoints(p1, p2)

% finds the equation coefficients between two points
% input: p1 - first point coordinates, p2 - second point

x = [p1(1) p2(1)];
y = [p1(2) p2(2)];
c = [[1; 1]  x(:)]\y(:); % Calculate Parameter Vector
slope = c(2);
intercept = c(1);

end