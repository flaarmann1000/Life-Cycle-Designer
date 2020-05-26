classdef I_Feature
    %I_Part class
    
   properties
       name
       baseFeature
       objectType
       featureDef
    end
    
    methods
       function obj = I_Feature(name,baseFeature,objectType,featureDef)
            %constructor
            obj.name = name;
            obj.baseFeature = baseFeature;            
            obj.objectType = objectType;
            obj.featureDef = featureDef;
       end     
    end
end

