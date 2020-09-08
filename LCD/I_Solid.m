classdef I_Solid
    %I_Part class
    
   properties
        name
        volume
        material               
        mass
        density
        boundingBox
        surface
    end
    
    methods
        function obj = I_Solid(name,volume, material, mass, density, boundingBox, surface)
            %constructor
            obj.name = name;
            obj.volume = volume;
            obj.material = material;            
            obj.mass = mass;
            obj.density = density;
            obj.boundingBox = boundingBox;
            obj.surface = surface;
        end                
    end
end

