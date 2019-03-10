classdef AnalysisManager < dynamicprops
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enm
    end
    
    methods
        function obj = AnalysisManager(enm)
            obj.enm = enm;
        end
        
        function doAnalysis(obj, analysisConfig)
            disp(analysisConfig)
            for i = 1:numel(analysisConfig)
                disp(analysisConfig(i));
                obj.doAnalysisRow(analysisConfig(i))
            end
             
        end

    end
end

