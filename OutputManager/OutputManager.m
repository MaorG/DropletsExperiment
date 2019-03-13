classdef OutputManager < dynamicprops

    properties
        am
    end
    
    methods
        function obj = OutputManager(am)
            obj.am = am;
        end
        
        function doOutput(obj, outputConfig)
            disp(outputConfig)
            for i = 1:numel(outputConfig)
                disp(outputConfig(i));
                obj.doOutputRow(outputConfig(i))
            end
        end
        
        function doOutputRow(obj, outputConfigRow)

            parameters = outputConfigRow.parameters;
            src = obj.am.(outputConfigRow.srcName);
            filter = outputConfigRow.filter;
            
            
            tableUI(src, str2func(outputConfigRow.funcName),[])
            
            %filteredRT = src.filter(filter);
            
            
            
            
            %obj.(resName) = eval([outputConfigRow.funcName, '(src, parameters)']);
            
            % TODO:  this is too simplistic and lazy... e.g. the filtering
            % can and should take place before actually calling the output
            % func
            % perhaps the manager can extract the data from the src NDTable
            % and pass is to the func
            % -> so now 'filter' is a separate column. other parameters can
            % be passed into the display func

        end
      
    end
end

