function res = appendPaths(path1, path2)

% this function adds path1 to path2 only if path2 is not already a full
% path
% eg: appendPaths('D:\utils\', 'software\file.exe') returns
% D:\utils\software\file.exe
% whereas appendPaths('D:\utils', 'D:\utils\software\file.exe') disregards
% path1, leaving only path2

fullPathPfx = '^(?:[A-Z]:|\\\\)';


if (isempty(regexp(path2, fullPathPfx)))
    res = fullfile(path1, path2);
else
    res = path2;
end

end
