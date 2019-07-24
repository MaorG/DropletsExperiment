function result = centerSpacedText(text, len, option)

% INPUT: len is optional - to specify length when 'text' is not already
% filled with spaces, then it will use that length instead of defining
% slen1 and slen2 by the trailing spaces
% option - optional, to specifiy whether optional len is the full length of
% the resulting text or the length of the trailing spaces to add. default
% is 'spaces', or choose option 'fullLength'
% OUTPUT: text with trailing spaces from back and front, balanced

str = regexp(text, '^(\s*)(.+?)(\s*)$', 'tokens', 'once');
repSChar1 = ' ';
repSChar2 = ' ';

if (exist('len', 'var') && isnumeric(len))
    lenSum = len;
    if (exist('option', 'var') && any(strcmp(option, 'fullLength')))
        lenSum = lenSum - length(str{2});
    end
else
    slen1 = length(str{1});
    slen2 = length(str{3});
    lenSum = slen1 + slen2;
end

avg = (lenSum) / 2;
nrepS1 = floor(avg);
nrepS2 = ceil(avg);

resultS1 = repmat(repSChar1, 1, nrepS1);
resultS2 = repmat(repSChar2, 1, nrepS2);

result = [resultS1, str{2}, resultS2];

end
