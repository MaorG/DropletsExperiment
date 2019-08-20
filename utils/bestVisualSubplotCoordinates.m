function [coor1, coor2] = bestVisualSubplotCoordinates(numSubplots)
%BESTVISUALSUBPLOTCOORDINATES returns the best visual coordinates 
%for the subplot function in a figure

% INPUT:
% numSubplots - the total number of subplots to be used in the figure

% OUTPUT:
% coor1, coor2 - coordinates to be used inside subplot: subplot(coor1, coor2, i)

coor1 = 1;
coor2 = 1;
total = i;
while coor1 * coor2 < numSubplots
    if (coor1 == coor2)
        coor2 = coor2 + 1;
    else
        coor1 = coor1 + 1;
    end
end

end

