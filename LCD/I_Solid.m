classdef I_Solid
    %I_Part class
    
   properties
        name
        volume
        material               
    end
    
    methods
        function obj = I_Solid(name,volume, material)
            %constructor
            obj.name = name;
            obj.volume = volume;
            obj.material = material;            
        end                
    end
end

