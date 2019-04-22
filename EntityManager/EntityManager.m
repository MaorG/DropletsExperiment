classdef EntityManager < dynamicprops
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dm = []
    end
    
    methods
        function obj = EntityManager(dm)
            %Construct an instance of this class
            %   dm is the experiment data manager, it provides access to all imagery 
            obj.dm = dm;
           
        end
        
        function doEntities(obj, entityConfig)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            disp(entityConfig)
            for i = 1:numel(entityConfig)
                disp(entityConfig(i));
                obj.doEntityRowOnAllData(entityConfig(i))
            end
             
        end
        
        function doEntityRowOnAllData(obj, entityConfigRow)
            
            % check if entity type is new
            % only relevant for single entries 
            %   i.e. not {'cell', 'droplets'}
            if (~iscell(entityConfigRow.targetName) && ~isprop(obj, entityConfigRow.targetName)) 
                % if so, create the entity type and relate to dm data
                % entries with uniqueID
                % TODO: is it a good idea to use a class to represent data
                %       and use handles?
                %       if they have handles, perhaps 'next' and 'prev' can
                %       be used for 
                obj.createEntitiesStruct(entityConfigRow);
            end
            
            if (~iscell(entityConfigRow.targetName))
                % handle single entity type
                allEntities = obj.(entityConfigRow.targetName);
                for i = 1:numel(allEntities)

                    entities = allEntities(i);
                    parameters = entityConfigRow.parameters;
                    resName = entityConfigRow.resName;
                    targetName = entityConfigRow.targetName;
                    data = obj.dm.getDataByUniqueID(entities.uniqueID);

                    if (~isempty(resName))
                        allEntities(i).(resName) = eval([entityConfigRow.funcName, '(entities, data, parameters)']);
                    else
                        % should only get here when creating entities for
                        % the first time
                        res = eval([entityConfigRow.funcName, '(entities, data, parameters)']);
                        
                        fns = fieldnames(res);
                        for fn = fns'
                            allEntities(i).(fn{1}) = res.(fn{1});
                        end
                        
                    end

                end
                obj.(entityConfigRow.targetName) = allEntities;
            else
                % handles exactly 2 entity types
                % TODO handle multiple entity types?
                %      requires to pass several types of entities as
                %      arguments and as return values in an array
                
                                
                allEntities = {};
                for iType = 1:numel(entityConfigRow.targetName)
                    allEntities{iType} = obj.(entityConfigRow.targetName{iType});
                end

                for i = 1:numel(allEntities{iType})
                    entities = {};
                    parameters = entityConfigRow.parameters;
                    resName = entityConfigRow.resName;
                    targetName = entityConfigRow.targetName;
                    for iType = 1:numel(allEntities)
                        entities{iType} = allEntities{iType}(i);
                    end
                    data = obj.dm.getDataByUniqueID(entities{1}.uniqueID);

                    [allEntities{1}(i).(resName)] = eval([entityConfigRow.funcName, '(entities, data, parameters)']);


                end
                
                obj.(entityConfigRow.targetName{1}) = allEntities{1};

            end
                
                
        end
        
        function createEntitiesStruct(obj, entityConfigRow)
            entName = entityConfigRow.targetName;
            
            addprop(obj,entName);
            
            obj.(entName) = struct();
            st = obj.(entName);
            for i = 1:numel(obj.dm.allData)
                st(i).uniqueID = obj.dm.allData(i).uniqueID;
                st(i).dataParameters = obj.dm.allData(i).parameters;
                st(i).dataProperties = obj.dm.allData(i).properties;
            end
            obj.(entName) = st;
        end


        
        
    end
end
