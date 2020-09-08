classdef ConfigStage
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        operations ConfigOperation
    end
    
    methods
        function obj = ConfigStage(name)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end  
        
        function obj = addOperation(obj, op)
            obj.operations = [obj.operations, op];
        end
        
        function op = getOperation(obj, opName)            
            for i = 1:length(obj.operations)
               if obj.operations(i).name == opName
                  op = obj.operations(i);
                  return
               end
            end                        
            op = ConfigOperation(opName);            
        end
        
        function obj = updateOperation(obj, op)
            for i = 1:length(obj.operations)
               if obj.operations(i).name == op.name             
                  obj.operations(i) = op;
                  return
               end
            end            
            obj = obj.addOperation(op);
        end
        
        
    end
end

