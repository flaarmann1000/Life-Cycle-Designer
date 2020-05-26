classdef Stage < matlab.mixin.Heterogeneous
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        processGraph digraph
        processes EcoinventProcess
    end
    
    methods
        % update LC Model
        % generate LCIA
        % (get Simulation Quality)        
        function stage = createStage(name,id,type)
            if(type == "material")
                stage = Stage();
                stage.name = name;
                stage.id = id;
            end
        end
        
    end
end

