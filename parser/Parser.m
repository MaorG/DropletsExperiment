classdef Parser
    methods
        
        function conf = getConfiguration(obj, configFileName)
            
            T = readtable(configFileName,'Delimiter',',');
            conf = table2struct(T);
            
            %TODO  - ignore lines beggining with #!!
            for i = 1:numel(conf)
                conf(i)
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
    end
    
    
    
end