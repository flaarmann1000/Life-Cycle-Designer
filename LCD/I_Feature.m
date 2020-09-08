classdef I_Feature
    %I_Part class
    
   properties
       name string      
       objectType string
       featureDef struct
       bodies
    end
    
    methods
       function obj = I_Feature(name,objectType,featureDef,bodies)
            %constructor
            obj.name = name;           
            obj.objectType = objectType;
            obj.featureDef = featureDef;
            obj.bodies = bodies;            
       end     
    end
end

