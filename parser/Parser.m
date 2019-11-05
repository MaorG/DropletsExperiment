classdef Parser
    
    properties
            
        commaTo = char(65535); % special character that shouldn't be used regularly in the file
        commentLinePrefix = '#';
        commentColumnPrefix = '!'; % characters that can prefix field columns to specify which columns to ignore
        splitLineStr = '\.\.\.\s*$'; % this string regex pattern can optionally be used at the end of lines to append the current line to the next line (... in this case as used in matlab scripts syntax)
        topicLineStr = '^\s*<(\S+)>\s*$'; % pattern for topics in the main experiment file, e.g. looks for <topic> in the experiment main file for the configuration of the corresponding config file; used when all configuration files are in one file
        curTopic = '';
        inCurTopic = true;
        
    end
    
    methods
        
        % the function will read just mainConfigFileName if topic matches the pattern of topicLineStr, 
        % otherwise it will read configFileName as usual. if topic matches
        % the pattern, this implies that all config files are combined in
        % mainConfigFileName as separate topics
        function conf = getConfiguration(obj, mainConfigFileName, configFileName, topic)
            

            % get configuration file using comma as a field separator
            % ignore lines that begin with #
            % don't use commas as a separator if they're enclosed in double
            % quotation marks

            fileToRead = configFileName;
            
            if (exist('topic', 'var'))
                chkTopic = regexp(topic, obj.topicLineStr, 'tokens', 'once');
                if (~isempty(chkTopic))
                    obj.curTopic = chkTopic;
                    fileToRead = mainConfigFileName;
                end
            end
                            
            conf = obj.createStructFromCsvFile(obj, fileToRead);
                        
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
            expr
            if isnumeric (expr)
                res = expr;
            elseif isempty(expr)
                res = [];
            else
                res = eval(expr);
            end
        end
        
        
        function conf = createStructFromCsvFile(obj, filepath)
            
            conf = struct;
            fields = {};
            
            colsIgnore = [];
            
            fid = fopen(filepath);
            rline = fgetl(fid);
            lineNum = 0;
            prevLines = [];
            while ischar(rline)
                %disp(rline)
                
                if (~strncmp(rline, obj.commentLinePrefix, 1) && ~isempty(rline)) % ignore lines that start with '#'
                    if (regexp(rline, obj.splitLineStr))
                        prevLines = [prevLines, regexprep(rline, obj.splitLineStr, '')];
                    else
                        fullLine = [prevLines, rline];
                        prevLines = [];
                        
                        
                        chkTopic = regexp(fullLine, obj.topicLineStr, 'tokens', 'once');
                        if (~isempty(chkTopic) && ~isempty(obj.curTopic))
                            if (strcmp(obj.curTopic, chkTopic)) 
                                obj.inCurTopic = true;
                            else
                                obj.inCurTopic = false;
                            end
                            
                        elseif (obj.inCurTopic)
                        
                            lineNum = lineNum + 1;
                                                    
                            tokens = obj.getCommaTokensIgnoreQuotes(obj, fullLine);
                            
                            for i = 1 : numel(tokens)
                                token = tokens{i};
                                token = strrep(strrep(token, obj.commaTo, ','), '"', ''); % remove quote marks and replace special character back to comma
                                
                                if (lineNum == 1)
                                    if (strncmp(token, obj.commentColumnPrefix, 1))
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
                        
                    end
                    
                end
                
                rline = fgetl(fid);
            end
            fclose(fid);
            
            
        end
        
        
        function tokens = getCommaTokensIgnoreQuotes(obj, rline)
            
            %regCommaToks = '[^,\s](?:[^,\s]|\s(?!,|\s|$))*';
            regCommaToks = '[^,\s](?:[^,\s]|\s(?!,|$))*';
            regQuotesRep = '"(.*?)"';
            quotesTo = '<<<$1>>>';
            regCommaRep = '(?<=<<<((?!>>>).)*),(?=((?!>>>).)*>>>)';
            regNewQuotes = '<<<|>>>';
            %commaTo = char(63665);
            qrline = regexprep(rline, regQuotesRep, quotesTo);
            cqrline = regexprep(qrline, regCommaRep, obj.commaTo);
            fcqrline = regexprep(cqrline, regNewQuotes, '');
            tokens = regexp(fcqrline, regCommaToks, 'match');
            tokens = regexprep(tokens, obj.commaTo, ',');
            
        end
        
        
    end
    
    
    
end