function [asm] = I_Assembly2Assembly(app,i_asm,classifyFlag)
% I_Assembly2Assembly restructures imported I_Assembly
% Removes empty I_Parts
% combines I_Parts with one I_Solid to Component
% Converts I_Parts with multiple I_Solids to Assembly
% Assigns features to Components
    
    h = waitbar(20,['convert assembly...']);            
    asm = Assembly(i_asm.name);    
    asm = Iterate(asm, i_asm);                
    waitbar(60,h,['map features...']);            
    asm = mapfeatures(asm, i_asm.features);    
    waitbar(80,h,['map joints...']);            
    asm = mapjoints(asm, i_asm.joints);
    close(h);            
    
    function parent = Iterate(parent,iparent)        
        for j = 1:length(iparent.solids)                 
            s = iparent.solids(j);                                               
            processParameter.mass.value = str2double(s.mass); %kg
            processParameter.volume.value = str2double(s.volume)/1e6; %cm^3 -> m^3            
            processParameter.density.value = str2double(s.density)*1e6; %g/mm^3 -> kg/m^3            
            processParameter.boundingBoxX.value = s.boundingBox(1)/100; %cm --> m            
            processParameter.boundingBoxY.value = s.boundingBox(2)/100; %cm --> m            
            processParameter.boundingBoxZ.value = s.boundingBox(3)/100; %cm --> m            
            processParameter.surface.value = str2double(s.surface)/10000; %cm^2 -> m^2            
            %https://www.jotun.com/Datasheets/Download?url=%2FTDS%2FTDS__12300__Alkyd+Topcoat__Euk__GB.pdf
            %Density: 1.1kg/l - theoretical spreading rate: 22-11m²/l
            processParameter.paintMass.value = processParameter.surface.value / 16.5 * 1.1;                                    
            ob = Component(app, s.name,s.material,processParameter);            
            parent = parent.addComponent(ob,app,classifyFlag);            
        end
        for j = 1:length(iparent.parts)            
            if iparent.parts(j).getChildrenCount > 1 
                ob = Assembly(iparent.parts(j).name);
                ob = Iterate(ob, iparent.parts(j));                
                ob = mapfeatures(ob,iparent.parts(j).features);
                ob = mapjoints(ob,iparent.parts(j).joints);
                parent = parent.addAssembly(ob);                
            elseif iparent.parts(j).getChildrenCount == 1                 
                p = iparent.parts(j);
                [~,s] = iparent.parts(j).getChildrenCount;                                
                
                processParameter.mass.value = str2double(s.mass); %kg            
                processParameter.volume.value = str2double(s.volume)/1e6; %cm^3 -> m^3
                processParameter.density.value = str2double(s.density)*1e6; %g/mm^3 -> kg/m^3
                processParameter.boundingBoxX.value = s.boundingBox(1)/100; %cm --> m            
                processParameter.boundingBoxY.value = s.boundingBox(2)/100; %cm --> m            
                processParameter.boundingBoxZ.value = s.boundingBox(3)/100; %cm --> m   
                processParameter.surface.value = str2double(s.surface)/10000; %cm^2 -> m^2
                %https://www.jotun.com/Datasheets/Download?url=%2FTDS%2FTDS__12300__Alkyd+Topcoat__Euk__GB.pdf
                %Density: 1.1kg/l - theoretical spreading rate: 22-11m²/l
                processParameter.paintMass.value = processParameter.surface.value / 16.5 * 1.1;                
                ob = Component(app, p.name,s.material,processParameter);                        
                ob.solidName = p.solids.name;
                ob = mapfeatures(ob,iparent.parts(j).features);
                ob = mapjoints(ob,iparent.parts(j).joints);
                parent = parent.addComponent(ob,app,classifyFlag);
            end               
        end  
    end
end

function obj = mapfeatures(obj,features)
% I_parts containing only one solid will be converted to Components
% in this case the mapping must be run for this component only
    if isa(obj,"Assembly")        
        for j = 1:length(features)           
            name = features(j).bodies;            
            for i = 1:length(obj.components)
               if obj.components(i).solidName == name                  
                  obj.components(i) = obj.components(i).addFeature(Feature.fromI_feature(features(j)));
                  return                                
               end
            end            
        end
    else
        for j = 1:length(features)           
            name = features(j).bodies;            
            if obj.solidName == name                
                obj = obj.addFeature(Feature.fromI_feature(features(j)));
                return                                
            end
         end                  
    end
end

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
               if obj.components(i).solidName == nameBody && obj.name == nameOcc
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