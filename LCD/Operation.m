classdef Operation < handle & matlab.mixin.Copyable
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        parent
        processes Process
        name
    end
    
    methods
        
        function obj = Operation(name)
            obj.name = name;
            obj.id = java.util.UUID.randomUUID.toString;
        end
        
        function obj = addProcess(obj, pro)
            for i = 1:length(obj.processes)
               if obj.processes(i).id == pro.id
                  pro.id = java.util.UUID.randomUUID.toString;
               end
            end
            pro.parent = obj;
            obj.processes = [obj.processes pro];
        end
        
        function obj = plot(obj,app)
            g = digraph();
            if ~isempty(obj.processes)                
                g = g.addnode(obj.processes(1).name);
                proNames = obj.processes(1).name;
                for i = 2:length(obj.processes)
                    g = g.addedge(obj.processes(i-1).name,obj.processes(i).name);
                    proNames = [proNames obj.processes(i).name];
                end
                h = plot(app.UIAxes, g, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',[247 182 137]/255,'EdgeColor',[247 182 137]/255,'LineWidth',2,'NodeLabel','','ArrowSize',15);
                layout(h,'layered','Direction','down');
                
                xScale = app.UIAxes.XLim(2) - app.UIAxes.XLim(1);
                text(app.UIAxes, h.XData + xScale*0.02, h.YData ,proNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
                
                hold(app.UIAxes,"on");
                [~,impacts] = obj.generateLCIA(app);
                col = zeros(length(impacts),3);
                col(impacts > 0,1) = 1;
                col(impacts < 0,3) = 1;
                impactsNorm = abs(impacts) / app.getModelImpact * 10000 + 0.001;
                im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm ,'PickableParts' , 'none');
                alpha(im,.2)
                hold(app.UIAxes,"off");
                
                set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
                disableDefaultInteractivity(app.UIAxes);
                resetplotview(app.UIAxes);
                app.UIAxes.Toolbar.Visible = 'off';
                
                app.BTN_Exchange.Enable = false;
                app.BTN_Remove.Enable = false;
                
                if app.options.normTime
                    app.L_Navi.Text = obj.parent.parent.name + ' / ' + obj.parent.name + ' / ' + obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + " / yr)";
                    text(app.UIAxes, h.XData +xScale*0.02, h.YData-xScale*0.02, string(round(impacts,2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                else
                    app.L_Navi.Text = obj.parent.parent.name + ' / ' + obj.parent.name + ' / ' + obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + ")";
                    text(app.UIAxes, h.XData +xScale*0.02, h.YData-xScale*0.02, string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                end
                
            else                
                cla(app.UIAxes);
            end
            
            
            
        end
        
        function [total, vector] = generateLCIA(obj,app)
            total = 0;
            vector = zeros(length(obj.processes),1);
            for i = 1:length(obj.processes)
                impact = obj.processes(i).generateLCIA(app);
                total = total + impact;
                vector(i) = impact;
            end
        end
        
    end
end

