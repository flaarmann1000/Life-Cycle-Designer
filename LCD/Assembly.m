classdef Assembly
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        name
        assemblyType
        components Component
    end
    
    methods
        function obj = Assembly(name)
            obj.name = name;
        end        
        function obj = addComponent(obj, com)
           obj.components(length(obj.components)+1) = com;
        end
        function com = getComponentByName(obj,name)
            for i = 1:length(obj.components)
               if obj.components(i).name == name
                  com = obj.components(i);
                  break
               end
            end
        end
    end
end

