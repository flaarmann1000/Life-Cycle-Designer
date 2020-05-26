function Asm = struct2I_Assembly(struct)            
%Converts Struct to I_Assembly object
name = struct.assembly.Attributes.name;
material = struct.assembly.Attributes.material;
mass = str2double(struct.assembly.Attributes.mass);
volume = str2double(struct.assembly.Attributes.volume);
Asm = I_Assembly(name, volume, material, mass);

Asm = Iterate(struct.assembly, Asm);

end

function root = Iterate(struct, root)
            if isfield(struct,"solid")
                for i = 1: length(struct.solid)
                    if length(struct.solid) == 1     
                        name = struct.solid.Attributes.name;
                        volume = str2double(struct.solid.Attributes.volume);
                        material = struct.solid.Attributes.material;                        
                        solid = I_Solid(name,volume,material);
                        solid = Iterate(struct.solid, solid);
                    else
                        name = struct.solid{i}.Attributes.name;
                        volume = str2double(struct.solid{i}.Attributes.volume);
                        material = struct.solid{i}.Attributes.material;                        
                        solid = I_Solid(name,volume,material);
                        solid = Iterate(struct.solid{i}, solid);
                    end                    
                    root.solids(length(root.solids)+1) = solid;
                end
            end
            if isfield(struct,"part")                
                for i = 1: length(struct.part)
                    if length(struct.part) == 1
                        name = struct.part.Attributes.name;
                        volume = str2double(struct.part.Attributes.volume);
                        material = struct.part.Attributes.material;
                        mass = str2double(struct.part.Attributes.mass);                        
                        part = I_Part(name,volume,material,mass);
                        part = Iterate(struct.part, part);
                    else
                        name = struct.part{i}.Attributes.name;
                        volume = str2double(struct.part{i}.Attributes.volume);
                        material = struct.part{i}.Attributes.material;
                        mass = str2double(struct.part{i}.Attributes.mass);     
                        part = I_Part(name,volume,material,mass);
                        part = Iterate(struct.part{i}, part);
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
                for i = 1: length(struct.feature)
                    if length(struct.feature) == 1
                        name = struct.feature.Attributes.name;
                        baseFeature = struct.feature.Attributes.baseFeature;
                        objectType = struct.feature.Attributes.objectType;
                        featureDef = struct.feature.featureDef;
                    else
                        name = struct.feature{i}.Attributes.name;
                        baseFeature = struct.feature{i}.Attributes.baseFeature;
                        objectType = struct.feature{i}.Attributes.objectType;
                        featureDef = struct.feature{i}.featureDef;
                    end      
                    root.features(length(root.features)+1) = I_Feature(name,baseFeature,objectType,featureDef);
                end    
            end                                  
        end