classdef Stage < matlab.mixin.Heterogeneous
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties                
        processes EcoinventProcess        
        processList
        processTypes
        name
    end
    
    methods
        % update LC Model
        % generate LCIA
        % (get Simulation Quality)        
        function obj = Stage(name)            
            obj.name = name;   
            %if (name == "production")
                obj.processList = ["semi production","transport","primary shaping","reshaping","cutting","joining","change properties", "surface finish"];
                obj.processTypes = ["briquett production","internal","aluminium die cast","none","machining","none","none","polishment"];
            %end
        end   
        
        function obj = displayStage(obj,app)            
            %XData = [20,40,60,80,100,120,100,80,60,40];
            %YData = [20,20,20,20, 20, 20, 40,40,40,40];
            %NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            %EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            
            g = digraph();
            g = g.addnode(obj.processList(1));
            for i = 2:length(obj.processList)
                g = g.addedge(obj.processList(i-1),obj.processList(i));
            end
            
            h = plot(app.UIAxes, g, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',[247 182 137]/255,'EdgeColor',[247 182 137]/255,'LineWidth',2,'NodeLabel','','ArrowSize',15);                       
            layout(h,'layered','Direction','right');
            text(app.UIAxes, h.XData, h.YData-0.1 ,obj.processList,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')   
            text(app.UIAxes, h.XData, h.YData-0.14 ,obj.processTypes,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, 'Color', [.6 .6 .7], 'FontWeight','normal')            
            %set(h,'hittest','off'); % so you can click on the Markers            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
            %uiwait(h) %so multiple clicks can be used    
            app.BTN_Open.Text = "open process";
        end 
    end
end

