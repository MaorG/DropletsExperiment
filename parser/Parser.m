classdef Parser
    methods
        
        function conf = getConfiguration(obj, configFileName)
            

            % get configuration file using comma as a field separator
            % ignore lines that begin with #
            % don't use commas as a separator if they're enclosed in double
            % quotation marks
            
            commaTo = char(65535); % special character that shouldn't be used regularly in the file
            commentLinePrefix = '#';
            commentColumnPrefix = '!'; % characters that can prefix field columns to specify which columns to ignore
            
            conf = obj.createStructFromCsvFile(obj, configFileName, commaTo, commentLinePrefix, commentColumnPrefix);

                        
            %TODO - ignore commas within double quote marks!
%             T = readtable(configFileName,'Delimiter',',');
%             conf = table2struct(T);
            
            %TODO (more nicely) - ignore lines beggining with #!!
%             for i = numel(conf):-1:1
%                 conf(i)
%                 fn = fieldnames(conf)
%                 if strncmp(conf(i).(fn{1}),'#',1)
%                     conf(i)=[];
%                 end
%             end                                
            

            
            for i = 1:numel(conf)
                    
                for fieldName = fieldnames(conf)'
                    conf(i).(fieldName{1}) = obj.customeval(conf(i).(fieldName{1}));
                end
                
            end
            
        end
    end
    
    methods(Static)
        
        function res = customeval(expr)
            if isnumeric (expr)
                res = expr;
            elseif isempty(expr)
                res = [];
            else
                res = eval(expr);
            end
        end
        
        
        function conf = createStructFromCsvFile(obj, filepath, commaTo, commentLinePrefix, commentColumnPrefix)
            
            conf = struct;
            fields = {};
            
            colsIgnore = [];
            
            fid = fopen(filepath);
            rline = fgetl(fid);
            lineNum = 0;
            while ischar(rline)
                %disp(rline)
                
                if (~strncmp(rline, commentLinePrefix, 1) && ~isempty(rline)) % ignore lines that start with '#'
                    
                    lineNum = lineNum + 1;
                    
                    tokens = obj.getCommaTokensIgnoreQuotes(rline, commaTo);
                    
                    for i = 1 : numel(tokens)
                        token = tokens{i};
                        token = strrep(strrep(token, commaTo, ','), '"', ''); % remove quote marks and replace special character back to comma
                        
                        if (lineNum == 1)
                            if (strncmp(token, commentColumnPrefix, 1))
                                colsIgnore = [colsIgnore, i];
                                fields = [fields, 'none'];
                            else
                                fields = [fields, token];
                            end
                        elseif (~any(i == colsIgnore))
                            conf(lineNum-1).(fields{i}) = token;
                        end
                    end
                    
                end
                
                rline = fgetl(fid);
            end
            fclose(fid);
            
            
        end
        
        
        function tokens = getCommaTokensIgnoreQuotes(rline, commaTo)
            
            regCommaToks = '[^,\s](?:[^,\s]|\s(?!,|\s|$))*';
            regQuotesRep = '"(.*?)"';
            quotesTo = '<<<$1>>>';
            regCommaRep = '(?<=<<<((?!>>>).)*),(?=((?!>>>).)*>>>)';
            regNewQuotes = '<<<|>>>';
            %commaTo = char(63665);
            qrline = regexprep(rline, regQuotesRep, quotesTo);
            cqrline = regexprep(qrline, regCommaRep, commaTo);
            fcqrline = regexprep(cqrline, regNewQuotes, '');
            tokens = regexp(fcqrline, regCommaToks, 'match');
            tokens = regexprep(tokens, commaTo, ',');
            
        end
        
        
    end
    
    
    
end