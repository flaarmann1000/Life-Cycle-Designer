classdef Joint
    %FEATURE extracted from CAD    
    properties
        name string %Rigid3...                        
        type string %Screw...
        id string
        processParameter
    end
    
    methods
        function obj = Joint(name)
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end                
    end
    
    methods (Static)
        function obj = fromI_Joint(iJoint)
            obj = Joint(iJoint.name);
            if ~isempty(iJoint.screws)
               obj.type = "Screw";
               obj.processParameter.screwCount = length(iJoint.screws);               
               mass = 0;
               for i = 1:length(iJoint.screws)
                   mass = mass + str2double(iJoint.screws(i).mass);
               end
               obj.processParameter.screwMass = mass;               
            else
               obj.type = "Mount";
               obj.processParameter.screwMass = 0;               
            end
            obj.processParameter.area = min(str2double(iJoint.area1),str2double(iJoint.area2))/100^2; %cm^2 -> m^2
            obj.processParameter.outline= min(str2double(iJoint.outline1),str2double(iJoint.outline2))/100; %cm -> m
            
        end
    end
end

