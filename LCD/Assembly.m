classdef Assembly
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id double
        name string
        assemblyType string
        components Component
        assemblies Assembly
    end
    
    methods
        function obj = Assembly(name)
            obj.name = name;
        end
        
        function obj = addComponent(obj, com)
           obj.components(length(obj.components)+1) = com;
        end
        
        function obj = addAssembly(obj, asm)
           obj.assemblies(length(obj.assemblies)+1) = asm;
        end
        
        function el = getElementByName(obj,str)
            el = 0;
            if obj.name == string(str)
                el = obj;
            else                
                search(obj);                                    
            end
            
            function search(asm)                
                for i = 1:length(asm.components)
                   if asm.components(i).name == string(str)
                      el = asm.components(i);
                      break
                   end
                end
                for i = 1:length(asm.assemblies)
                    if asm.assemblies(i).name == string(str)
                        el = asm.assemblies(i);
                    else
                        search(asm.assemblies(i));
                   end
                end
            end
            
        end
        
        function displayAssembly(asm,tree)            
        %displays Assembly in TreeView

            NodeData.name = asm.name;
            root = uitreenode(tree,'Text',asm.name,'NodeData',NodeData, "Icon", "res\asm.png");
            iterate(root,asm)

            function iterate(parent,obj)
                for i = 1:length(obj.components)
                    NodeData.name = obj.components(i).name;
                    NodeData.material= obj.components(i).material;
                    %NodeData.mass = obj.components(i).mass;
                    NodeData.volume = obj.components(i).volume;
                    
                    uitreenode(parent,'Text',obj.components(i).name,'NodeData',NodeData, "Icon", "res\part.png");
                end
                for i = 1:length(obj.assemblies)
                    NodeData.name = obj.assemblies(i).name;
                    p = uitreenode(parent,'Text',obj.assemblies(i).name,'NodeData',NodeData, "Icon", "res\asm.png");
                    iterate(p,obj.assemblies(i));
                end
            end
        end        
    end
end

