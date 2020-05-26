classdef I_Assembly
%I_Assembly Import Class

    
    properties
        name string
        volume double
        material string
        mass double
        parts I_Part
        solids I_Solid
        CAM I_CAM
        features I_Feature
    end
    
    methods
        function obj = I_Assembly(name,volume, material, mass)            
            obj.name = name;
            obj.volume = volume;
            obj.material = material;
            obj.mass = mass;
        end
        
        function part = getPartByName(obj, name)
            %get part by name            
            part = obj.parts(obj.parts.name == name);
        end
        
        function obj = addPart(obj, part)
           obj.parts(length(obj.parts)+1) = part;
        end
        
    end    
end


