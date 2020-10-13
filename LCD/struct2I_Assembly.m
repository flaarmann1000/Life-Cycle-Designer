function Asm = struct2I_Assembly(struct)            
%Converts Struct to I_Assembly object
name = struct.product.Attributes.name;
mass = str2double(struct.product.Attributes.mass);
volume = str2double(struct.product.Attributes.volume);
Asm = I_Assembly(name, volume, mass);

Asm = Iterate(struct.product, Asm);

end

function root = Iterate(struct, root)
            if isfield(struct,"solid")
                for i = 1: length(struct.solid)
                    if length(struct.solid) == 1     
                        name = struct.solid.Attributes.name;
                        volume = struct.solid.Attributes.volume;
                        material = struct.solid.Attributes.material;   
                        mass = struct.solid.Attributes.mass;
                        density = struct.solid.Attributes.density;
                        boundingBox = [str2double(struct.solid.Attributes.BoundingBoxX) str2double(struct.solid.Attributes.BoundingBoxY) str2double(struct.solid.Attributes.BoundingBoxZ)];
                        surface = struct.solid.Attributes.surface;
                        solid = I_Solid(name,volume,material,mass,density,boundingBox,surface);
                        solid = Iterate(struct.solid, solid);
                    else
                        name = struct.solid{i}.Attributes.name;
                        volume = struct.solid{i}.Attributes.volume;
                        material = struct.solid{i}.Attributes.material;                        
                        mass = struct.solid{i}.Attributes.mass;
                        density = struct.solid{i}.Attributes.density;
                        boundingBox = [str2double(struct.solid{i}.Attributes.BoundingBoxX) str2double(struct.solid{i}.Attributes.BoundingBoxY) str2double(struct.solid{i}.Attributes.BoundingBoxZ)];
                        surface = struct.solid{i}.Attributes.surface;
                        solid = I_Solid(name,volume,material,mass,density,boundingBox,surface);
                        solid = Iterate(struct.solid{i}, solid);
                    end                    
                    root.solids(length(root.solids)+1) = solid;
                end
            end
            if isfield(struct,"component")                
                for i = 1: length(struct.component)
                    if length(struct.component) == 1
                        name = struct.component.Attributes.name;
                        volume = str2double(struct.component.Attributes.volume);                        
                        material = 'COMPONENT';
                        mass = str2double(struct.component.Attributes.mass);                        
                        part = I_Part(name,volume,material,mass);
                        part = Iterate(struct.component, part);
                    else
                        name = struct.component{i}.Attributes.name;
                        volume = str2double(struct.component{i}.Attributes.volume);                        
                        material = 'COMPONENT';
                        mass = str2double(struct.component{i}.Attributes.mass);     
                        part = I_Part(name,volume,material,mass);
                        part = Iterate(struct.component{i}, part);
                    end                                  
                    root.parts(length(root.parts)+1) = part;                    
                end    
            end
            if isfield(struct,"CAM")
                root.CAM = I_CAM();
                root = Iterate(root.CAM, root);
            end
            if isfield(struct,"setup")
                for i = 1: length(struct.setup)
                    if length(struct.setup) == 1
                        name = struct.setups.Attributes.name;
                        operationType = struct.setups.Attributes.operationType;
                        machiningTime = str2double(struct.setups.Attributes.machiningTime);
                        rapidDistance = str2double(struct.setups.Attributes.rapidDistance);
                        setup = I_Setup(name,operationType,machiningTime,rapidDistance);
                        setup = Iterate(struct.setups,setup);
                    else
                        name = struct.setups{i}.Attributes.name;
                        operationType = struct.setups{i}.Attributes.operationType;
                        machiningTime = str2double(struct.setups{i}.Attributes.machiningTime);
                        rapidDistance = str2double(struct.setups{i}.Attributes.rapidDistance);                        
                        setup = I_Setup(name,operationType,machiningTime,rapidDistance);
                        setup = Iterate(struct.setups{i},setup);
                    end                    
                    root.setups(length(root.setups)+1) = setup;
                end    
            end
            if isfield(struct,"operation")
                for i = 1: length(struct.operation)
                    if length(struct.operation) == 1
                        name = struct.operation.Attributes.name;
                        parent = struct.operation.Attributes.parent;                                                
                        operation = I_Operation(name,parent);
                        operation = Iterate(struct.operation,operation);
                    else
                        name = struct.operation{i}.Attributes.name;
                        parent = struct.operation{i}.Attributes.parent;                                                
                        operation = I_Operation(name,parent);
                        operation = Iterate(struct.operation{i},operation);
                    end                    
                    root.operations(length(root.operations)+1) = operation;
                end    
            end
            if isfield(struct,"model")
                for i = 1: length(struct.model)
                    if length(struct.model) == 1
                        name = struct.model.Attributes.name;                                                
                    else
                        name = struct.model.Attributes.name;                                                                                                
                    end    
                    root.models(length(root.models)+1) = I_Model(name);
                end    
            end
            if isfield(struct,"feature")
                flag = false;
                for i = 1: length(struct.feature)
                    if length(struct.feature) == 1
                        name = struct.feature.Attributes.name;                        
                        objectType = struct.feature.Attributes.objectType;
                        if isfield(struct.feature,"featureDef")
                            featureDef = struct.feature.featureDef;
                        else
                            featureDef = '';
                        end
                        if isfield(struct.feature,"body")
                            bodies = strings(0);
                            for k = 1: length(struct.feature.body)
                                if length(struct.feature.body) == 1
                                    bname = struct.feature.body.Attributes.name;                                                                     
                                else
                                    bname = struct.feature.body{k}.Attributes.name;
                                end
                                bodies = [bodies, bname];
                                flag = true;
                            end                               
                        end
                    else
                        name = struct.feature{i}.Attributes.name;                        
                        objectType = struct.feature{i}.Attributes.objectType;
                        if isfield(struct.feature{i},"featureDef")
                            featureDef = struct.feature{i}.featureDef;
                        else
                            featureDef = '';
                        end
                        if isfield(struct.feature{i},"body")
                            bodies = strings(0);
                            for k = 1: length(struct.feature{i}.body)
                                if length(struct.feature{i}.body) == 1
                                    bname = struct.feature{i}.body.Attributes.name;                                                                        
                                else
                                    bname = struct.feature{i}.body{k}.Attributes.name;                                                                        
                                end
                                bodies = [bodies, bname];
                                flag = true;
                            end                             
                        end                        
                    end      
                    if flag
                        root.features(length(root.features)+1) = I_Feature(name,objectType,featureDef,bodies);
                    end
                end    
            end       
            if isfield(struct,"joint")               
                for i = 1: length(struct.joint)
                    if length(struct.joint) == 1     
                        name = struct.joint.Attributes.name;
                        body1= struct.joint.Attributes.body1;
                        body2= struct.joint.Attributes.body2;
                        occ1= struct.joint.Attributes.occ1;
                        occ2= struct.joint.Attributes.occ2;
                        area1= struct.joint.Attributes.area1;
                        area2= struct.joint.Attributes.area2;
                        outline1= struct.joint.Attributes.outline1;
                        outline2= struct.joint.Attributes.outline2;
                        jointStruct = struct.joint;
                    else
                        name = struct.joint{i}.Attributes.name;
                        body1= struct.joint{i}.Attributes.body1;
                        body2= struct.joint{i}.Attributes.body2;
                        occ1= struct.joint{i}.Attributes.occ1;
                        occ2= struct.joint{i}.Attributes.occ2;  
                        area1= struct.joint{i}.Attributes.area1;
                        area2= struct.joint{i}.Attributes.area2;
                        outline1= struct.joint{i}.Attributes.outline1;
                        outline2= struct.joint{i}.Attributes.outline2;
                        jointStruct = struct.joint{i};
                    end 
                    joint = I_Joint(name,body1,occ1,area1,outline1,body2,occ2,area2,outline2);
                    root.joints(length(root.joints)+1) = joint;
                    if isfield(jointStruct,"screw")    
                        for e = 1: length(jointStruct.screw)
                            if length(jointStruct.screw) == 1 
                                name = jointStruct.screw.Attributes.name;
                                mass = jointStruct.screw.Attributes.mass;
                            else
                                name = jointStruct.screw{e}.Attributes.name;
                                mass = jointStruct.screw{e}.Attributes.mass;
                            end
                            screw = I_Screw(name,mass);
                            root.joints(end).screws = [root.joints(end).screws, screw];
                        end
                    end
                end            
            end
        end