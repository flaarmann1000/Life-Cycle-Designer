classdef Config
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        stages ConfigStage
        materialGroup string
        classification string
    end
    
    methods
        function obj = Config(name)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end
        
        function obj = addStage(obj, stage)
           obj.stages = [obj.stages stage];
        end
        
        function stage = getStage(obj, stageName)            
            for i = 1:length(obj.stages)
               if obj.stages(i).name == stageName                  
                  stage = obj.stages(i);
                  return
               end
            end                        
            stage = ConfigStage(stageName);            
        end
        
        function obj = updateStage(obj, stage)
            for i = 1:length(obj.stages)
               if obj.stages(i).name == stage.name             
                  obj.stages(i) = stage;
                  return
               end
            end   
            obj = obj.addStage(stage);
        end
        
    end
end

