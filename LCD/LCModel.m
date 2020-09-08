classdef LCModel
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        assemblies Assembly
        modelGraph = digraph()
        stageNames
    end
    
    methods
        % update LC Model
        % generate LCIA
        % (get Simulation Quality)    
        function obj = LCModel(name)
            obj.name = name;            
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;10 2];            
            g = digraph(EL(:,1),EL(:,2));            
            obj.modelGraph = g;           
        end
        
        function obj = displayLCModel(obj,app)
            obj.stageNames = ["material","production","connection","distribution","use","disposal","maintenance","refurbishment","remanufacturing","recycling"];
            XData = [20,40,60,80,100,120,100,80,60,40];
            YData = [20,20,20,20, 20, 20, 40,40,40,40];
            NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',2,'NodeLabel','','ArrowSize',15);            
            clf(app.UIAxes,'reset')
            text(app.UIAxes, h.XData, h.YData-1.3 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')   
            %text(app.UIAxes, h.XData, h.YData-1.8 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, 'Color', [.6 .6 .7], 'FontWeight','normal')                                                               
            %set(h,'hittest','off'); % so you can click on the Markers            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
            %uiwait(h) %so multiple clicks can be used       
            resetplotview(app.UIAxes);
        end        
        
        function obj = updateElement(obj, element)                                    
            obj.assemblies = ifind(obj.assemblies, element.name);
            
            function asm = ifind(asm, name)
                for i = 1:length(asm.components)
                   if(asm.components(i).name == name)
                       asm.components(i) = element;
                       disp('found element')                       
                       return;
                   end
                end
                for i = 1:length(asm.assemblies)
                    asm.assemblies = ifind(asm.assemblies, name);   
                end
            end
        end
        
    end
end

