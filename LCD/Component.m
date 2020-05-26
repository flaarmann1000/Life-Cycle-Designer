classdef Component
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id double
        name string
        componentType string
        stageNames string
        stageTypes string
        stages Stage
        material string
        %mass double
        volume double
        modelGraph = digraph()
    end
    
    methods
        function obj = Component(name,material,volume)                       
            obj.name = name;
            obj.material= material;
            %obj.mass = mass;
            obj.volume = volume;
            %obj.componentType = componentType;                    
            obj.stageNames = ["material","production","assembly","distribution","use","disposal","maintenance","refurbishment","remanufacturing","recycling"];
            obj.stageTypes = ["closed loop mix","alu die casting","screw","transportation","no consumption","landfill","reassembly","cleaning","surface finish","closed loop"];
                      
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;10 2];            
            g = digraph(EL(:,1),EL(:,2));            
            obj.modelGraph = g;  
            
            for i = 1:length(obj.stageNames)
                obj.stages(i) = Stage(obj.stageNames(i));
            end
        end
        
        function obj = displayComponent(obj,app)            
            XData = [20,40,60,80,100,120,100,80,60,40];
            YData = [20,20,20,20, 20, 20, 40,40,40,40];
            NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',2,'NodeLabel','','ArrowSize',15);            
            text(app.UIAxes, h.XData, h.YData-1.3 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')   
            text(app.UIAxes, h.XData, h.YData-1.8 ,obj.stageTypes,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, 'Color', [.6 .6 .7], 'FontWeight','normal')                                                               
            %set(h,'hittest','off'); % so you can click on the Markers            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
            %uiwait(h) %so multiple clicks can be used               
            %resetplotview(h,'InitializeCurrentView');
            resetplotview(app.UIAxes);
        end     
    end
end

