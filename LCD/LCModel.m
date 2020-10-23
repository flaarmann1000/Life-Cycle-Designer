classdef LCModel
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        root Assembly
        %modelGraph = digraph()        
    end
    
    methods
        % update LC Model
        % generate LCIA
        % (get Simulation Quality)    
        function obj = LCModel(name)
            obj.name = name;            
            %EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;10 2];            
            %g = digraph(EL(:,1),EL(:,2));            
            %obj.modelGraph = g;           
        end           
        
        function obj = updateElement(obj, element)                
            obj.root = ifind(obj.root, element.id);            
            function asm = ifind(asm, id)                                                                
                for i = 1:length(asm.components)
                   if(asm.components(i).id == id)
                       asm.components(i) = element;
                       %disp('found element')                       
                       return;
                   end                    
                end
                for i = 1:length(asm.assemblies)
                    asm.assemblies(i) = ifind(asm.assemblies(i), id);   
                end
            end
        end
        
    end
end

