function DisplayI_Assembly(tree,asm,flag)            
%displays I_Assembly in TreeView

    NodeData.name = asm.name;
    NodeData.volume = asm.volume;
    NodeData.material = asm.material;
    NodeData.mass = asm.mass;
    root = uitreenode(tree,'Text',asm.name,'NodeData',NodeData, "Icon", "res\asm.png");

    iterate(root,asm)



    function iterate(parent,obj)
        if isprop(obj,"solids")
            for i = 1: length(obj.solids)            
                NodeData.name = obj.solids(i).name;
                NodeData.volume = obj.solids(i).volume;
                NodeData.material = obj.solids(i).material;
                uitreenode(parent,'Text',obj.solids(i).name,'NodeData',NodeData,"icon","res\solid.png");                                        
            end
        end
        if isprop(obj,"parts")                
            for i = 1: length(obj.parts)            
                NodeData.name = obj.parts(i).name;
                NodeData.volume = obj.parts(i).volume;
                NodeData.material = obj.parts(i).material;
                part = uitreenode(parent,'Text',obj.parts(i).name,'NodeData',NodeData,"icon","res\part.png");                                                           
                iterate(part,obj.parts(i));
            end    
        end

        if flag        
            if isprop(obj,"CAM")
                cam = uitreenode(parent,'Text','CAM','NodeData',[],"icon","res\cam.png");            
                iterate(cam,obj.CAM);
            end
            if isprop(obj,"setups")
                for i = 1: length(obj.setups)            
                    NodeData.name = obj.setups(i).name;
                    NodeData.operationType = obj.setups(i).operationType;
                    NodeData.machiningTime = obj.setups(i).machiningTime;
                    NodeData.rapidDistance = obj.setups(i).rapidDistance;
                    setup = uitreenode(parent,'Text',obj.setups(i).name,'NodeData',NodeData,"icon","res\setup.png");
                    iterate(setup,obj.setups(i));
                end    
            end
            if isprop(obj,"operations")
                for i = 1: length(obj.operations)            
                    NodeData.name = obj.operations(i).name;
                    NodeData.parent = obj.operations(i).parent;                        
                    operation = uitreenode(parent,'Text',obj.operations(i).name,'NodeData',NodeData,"icon","res\operation.png");
                    iterate(operation,obj.operations(i));
                end    
            end
            if isprop(obj,"models")
                for i = 1: length(obj.models)            
                    NodeData.name = obj.models(i).name;            
                    model = uitreenode(parent,'Text',obj.models(i).name,'NodeData',NodeData,"icon","res\part.png");
                    iterate(model,obj.models(i));
                end    
            end
            if isprop(obj,"features")
                for i = 1: length(obj.features)            
                    NodeData.name = obj.features(i).name;              
                    NodeData.baseFeature = obj.features(i).baseFeature ;
                    NodeData.objectType = obj.features(i).objectType;
                    NodeData.featureDef = obj.features(i).featureDef;
                    feature = uitreenode(parent,'Text',obj.features(i).name,'NodeData',NodeData,"icon","res\feature.png");
                    iterate(feature,obj.features(i));
                end    
            end    
        end
    end

end