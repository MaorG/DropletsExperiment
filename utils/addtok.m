function text = addtok(text, token, tokChar)
    if (isempty(token))
        return;
    end
    
    if (~isempty(text))
        text = [text, tokChar];
    end
    
    text = [text, token];
end

        
        