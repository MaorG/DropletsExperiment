classdef Parser
    methods
        
        function conf = getConfiguration(obj, configFileName)
            
            T = readtable(configFileName,'Delimiter',',');
            % TODO: ignore columns beggining with #!
            % problem: readtable automatically changes '#BF' to 'x_BF'
            % theoretically it's possible to ignore all columns that start
            % with 'x_', but it also changes 'global' to 'x_Global' and
            % 'global' is a column name in the exp config
            
            
            conf = table2struct(T);

            
            %ignore lines beggining with #
            for i = numel(conf):-1:1
                conf(i)
                fn = fieldnames(conf)
                if strncmp(conf(i).(fn{1}),'#',1)
                    conf(i)=[];
                end
            end                                


            
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
    end
    
    
    
end