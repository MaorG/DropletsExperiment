classdef Parser
    methods
        
        function conf = getConfiguration(obj, configFileName)
            
            T = readtable(configFileName,'Delimiter',',');
            conf = table2struct(T);
            
            fields = fieldnames(conf)';
            
            % remove from data all rows where first field begins with #
            % (before the '')
            fieldN = 1;
            expToRem = '^#';
            colVals = {conf.(fields{fieldN})};
            conf = conf(cellfun(@isempty, regexp(colVals, expToRem)));
            
            for i = 1:numel(conf)
                
                for fieldName = fields
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
    end
    
    
    
end