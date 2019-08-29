function text = conv3dMatToTextWithCatForEval(mat)

textBegin = 'cat(3,';
textEnd = ')';
parmsSep = ',';
matEntrySep = ';';
mat2dBegin = '[';
mat2dEnd = ']';

parms = '';

for i = 1 : size(mat, 3)

    matEntry = '';
    for x = 1 : size(mat, 1)
        
        matEntry = addtok(matEntry, num2str(mat(x, :, i)), matEntrySep);
        
    end
        
    matEntryFull = [mat2dBegin, matEntry, mat2dEnd];
    
    parms = addtok(parms, matEntryFull, parmsSep);
    
end

text = [textBegin, parms, textEnd];

end
