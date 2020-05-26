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
    end
    
    methods
        function obj = I_Part(name,volume, material, mass)
            %constructor
            obj.name = name;
            obj.volume = volume;
            obj.material = material;
            obj.mass = mass;
        end                
    end
end

