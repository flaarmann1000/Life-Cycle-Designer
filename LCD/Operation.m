classdef Operation
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties                
        processes EcoinventProcess                
        name
    end
    
    methods
        
        function obj = Operation(name)            
            obj.name = name;
        end   
        
        function obj = addProcess(obj, pro)
           obj.processes = [obj.processes pro];
        end               
        
        function obj = displayOperation(obj,app,style)              
            g = digraph();
            g = g.addnode(obj.processes(1).activityName);
            proNames = obj.processes(1).activityName;            
            for i = 2:length(obj.processes)
                g = g.addedge(obj.processes(i-1).activityName,obj.processes(i).activityName);
                proNames = [proNames obj.processes(i).activityName];
            end
            h = plot(app.UIAxes, g, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',[247 182 137]/255,'EdgeColor',[247 182 137]/255,'LineWidth',2,'NodeLabel','','ArrowSize',15);                       
            layout(h,'layered','Direction','down');
            text(app.UIAxes, h.XData + 0.05, h.YData ,proNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')               
            %text(app.UIAxes, h.XData + 0.05, h.YData-0.05 ,obj.processTypes,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 15, 'Color', [.6 .6 .7], 'FontWeight','normal')                        
            
            app.BTN_Open.Text = "open process";
            if string(style) == "impact"
                hold(app.UIAxes,"on");
                [~,impacts] = obj.generateLCIA(app);                                
                col = zeros(length(impacts),3);            
                col(impacts > 0,1) = 1;
                col(impacts < 0,3) = 1;
                impactsNorm = abs(impacts) / app.modelImpact * 10000 + 0.001;
                im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm ,'PickableParts' , 'none');            
                alpha(im,.2)        
                text(app.UIAxes, h.XData +0.05, h.YData-0.05, string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                %text(app.UIAxes, h.XData + 0.05, h.YData-0.1 ,string(impacts),'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 15, 'Color', [.8 .6 .6], 'FontWeight','normal')                                        
                hold(app.UIAxes,"off");
            end
            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking            

        end
        
        function [total, vector] = generateLCIA(obj,app)
            total = 0;
            vector = zeros(length(obj.processes),1);
            for i = 1:length(obj.processes)
               %impact = obj.processes(i).htotal(index+1)* obj.processes(i).correction * obj.processes(i).quantity;
               impact = obj.processes(i).generateLCIA(app);
               total = total + impact;
               vector(i) = impact;
            end
        end
        
    end
end

