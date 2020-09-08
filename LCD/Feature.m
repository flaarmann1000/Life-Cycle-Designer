classdef Feature
    %FEATURE extracted from CAD    
    properties
        name string %Extrude1 ...
        type string %extrude...
        operation string %new body...
        value double %main parameter - used for classification
        id string
    end
    
    methods
        function obj = Feature(name)
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end                
    end
    
    methods (Static)
        function obj = fromI_feature(iFeat)
            obj = Feature(iFeat.name);
            if iFeat.objectType == "adsk::fusion::ExtrudeFeature"
                obj.type = "Extrude";
                obj.operation = iFeat.featureDef.Attributes.operation;               
                obj.value = double(iFeat.featureDef.Attributes.extent);
            elseif iFeat.objectType == "adsk::fusion::RevolveFeature"
                obj.type = "Revolve";
                obj.operation = iFeat.featureDef.Attributes.operation;                               
            elseif iFeat.objectType == "adsk::fusion::ShellFeature"
                obj.type = "Shell";
                obj.value = str2double(iFeat.featureDef.Attributes.thickness);
            elseif iFeat.objectType == "adsk::fusion::FormFeature"
                obj.type = "Form";
            else
                obj.type = iFeat.objectType;
            end 
                           
        end
    end
end

