classdef Parser
    methods
        
        function conf = getConfiguration(obj, configFileName)
            
            T = readtable(configFileName,'Delimiter',',');
            conf = table2struct(T);
            
            
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
            else
                res = eval(expr);
            end
        end
    end
    
    
    
end