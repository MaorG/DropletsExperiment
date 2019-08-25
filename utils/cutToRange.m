function x = cutToRange(x, range)
    if (x < range(1)) 
        x = range(1);
    elseif (x > range(2))
        x = range(2);
    end
end
