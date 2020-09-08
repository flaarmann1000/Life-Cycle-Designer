classdef I_Part
    %I_Part class
    
   properties
        name string
        volume double
        material string
        mass double
        solids I_Solid
        features I_Feature
        parts I_Part
        joints I_Joint
    end
    
    methods
        function obj = I_Part(name,volume, material, mass)
            %constructor
            obj.name = name;
            obj.volume = volume;
            obj.material = material;
            obj.mass = mass;
        end
        
        function [nChildren, solid] = getChildrenCount(obj)
           nChildren = 0;          
           Iterate(obj);
           
            function Iterate(o)
                for i = 1:length(o.solids)
                    nChildren = nChildren + 1; 
                    solid = o.solids(i);
                end
                for i = 1:length(o.parts)
                    Iterate(o.parts(i));
                end
            end
        end
    end
end

