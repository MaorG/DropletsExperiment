classdef AnalysisManager < dynamicprops

    % TODO: create an analysis object, somewhat like NDTable, which
    % relates the results to the data properties.
    %
    % how can NDtable functionality can be used here? only within
    % the static funcs that will return it? 
    % the analysis manager doesn't actually do
    % anything except calling the function based on some config line.
    % 
    % perhaps the analysis object should take multiple commands?
    %
    % or maybe, assume that each command will be used in a specific manner
    % and return the final ndtable for display as-is... 
    % <<< looks like the better option at the moment >>>
    %
    % PS: what about scale?!?!?!?
    %
    % (perhaps also write a class for the data (to easily extract
    % properties?))
        

    properties
        enm
        dm
    end
    
    methods
        function obj = AnalysisManager(dm, enm)
            obj.dm = dm;
            obj.enm = enm;
        end
        
        function doAnalysis(obj, analysisConfig)
            disp(analysisConfig)
            for i = 1:numel(analysisConfig)
                disp(analysisConfig(i));
                obj.doAnalysisRow(analysisConfig(i))
            end
        end
        
        function doAnalysisRow(obj, analysisConfigRow)

            obj.createAnalysisStruct(analysisConfigRow);
            parameters = analysisConfigRow.parameters;
            resName = analysisConfigRow.resName;
            entities = obj.enm.(analysisConfigRow.entities);
            
            obj.(resName) = eval([analysisConfigRow.funcName, '(entities, parameters)']);
        end
        
        function createAnalysisStruct(obj, analysisConfigRow)
            analysisName = analysisConfigRow.resName;
            addprop(obj,analysisName);
        end

       
    end
end

