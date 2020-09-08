classdef ConfigOperation
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        processes ConfigProcess
    end
    
    methods
        function obj = ConfigOperation(name)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end                
        
        function obj = addNewProcess(obj,activityName,loc,ref)
           obj.processes = [obj.processes ConfigProcess(activityName,loc,ref)];
        end
        
        function obj = addProcess(obj, process)
           obj.processes = [obj.processes process];
        end
    end
end

