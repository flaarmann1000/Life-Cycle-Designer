function obj = mapjoints(obj,joints)
% I_parts containing only one solid will be converted to Components, so 
% in this case the mapping must be run for this component only

% todo: in subasm suchen und kombination aus occ & body finden
    if isa(obj,"Assembly")        
        for j = 1:length(joints) 
            nameBody = joints(j).body1;
            nameOcc = joints(j).occ1;
            %check if one joint partner is screw
            if ~isempty(joints(j).screws)                
                charName = char(joints(j).occ1);
                if strlength(joints(j).occ1) > 8 && charName(1) == '9'                    
                    nameBody = joints(j).body2;                    
                    nameOcc = joints(j).occ2;
                end            
            end                     
            for i = 1:length(obj.components)                
               if obj.components(i).solidName == nameBody && obj.components(i).name == nameOcc
                  obj.components(i) = obj.components(i).addJoint(Joint.fromI_Joint(joints(j)));                  
                  break                                                              
               end
            end   
            for i = 1:length(obj.assemblies)
                obj.assemblies(i) = mapjoints(obj.assemblies(i),joints(j));
                
            end
        end   
    end
end