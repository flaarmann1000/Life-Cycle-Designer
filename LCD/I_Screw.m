classdef I_Screw    
    
   properties
       name
       mass
       
    end
    
    methods
        function obj = I_Screw(name,mass)
            %constructor
            obj.name = name;
            obj.mass = mass;          
        end          
    end
end

