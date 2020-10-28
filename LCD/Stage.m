classdef Stage < handle & matlab.mixin.Copyable
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties                
        name
        parent
        operations Operation
        %rate double
        id string;
    end
    
    methods
        % update LC Model        
        % (get Simulation Quality)        
        function obj = Stage(name)            
            obj.name = name;   
            obj.id = java.util.UUID.randomUUID.toString;
        end   
        
        function obj = plot(obj,app)              
            g = digraph();
            
            if isempty(obj.operations)
                cla(app.UIAxes);
                return
            end
            
            g = g.addnode(obj.operations(1).name);
            opNames = obj.operations(1).name;            
            for i = 2:length(obj.operations)
                g = g.addedge(obj.operations(i-1).name,obj.operations(i).name);
                opNames = [opNames obj.operations(i).name];                
            end
            h = plot(app.UIAxes, g, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',[247 182 137]/255,'EdgeColor',[247 182 137]/255,'LineWidth',2,'NodeLabel','','ArrowSize',15);                       
            layout(h,'layered','Direction','down');
            xScale = app.UIAxes.XLim(2) - app.UIAxes.XLim(1);
            text(app.UIAxes, h.XData + xScale*0.02, h.YData ,opNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')               
            %text(app.UIAxes, h.XData + 0.05, h.YData-0.05 ,obj.processTypes,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 15, 'Color', [.6 .6 .7], 'FontWeight','normal')                                                
                        
            hold(app.UIAxes,"on");
            [~,impacts] = obj.generateLCIA(app);                
            col = zeros(length(impacts),3);            
            col(impacts > 0,1) = 1;
            col(impacts < 0,3) = 1;
            impactsNorm = abs(impacts) / app.getModelImpact * 10000 + 0.001;
            im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm,'PickableParts' , 'none');            
            alpha(im,.2)                                 
            hold(app.UIAxes,"off");            
            
            if app.options.normTime
                app.L_Navi.Text = obj.parent.name + ' / ' + obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + " / yr)";
                text(app.UIAxes, h.XData + xScale*0.02, h.YData-xScale*0.02, string(round(impacts,2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            else
                app.L_Navi.Text = obj.parent.name + ' / ' + obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + ")";
                text(app.UIAxes, h.XData + xScale*0.02, h.YData-xScale*0.02, string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            end
                        
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking                                    
        end 
        
        function [total, vector] = generateLCIA(obj,app)
            total = 0;    
            vector = zeros(length(obj.operations),1);
            for i = 1:length(obj.operations)
                [opImpact,~] = obj.operations(i).generateLCIA(app);
                total = total + opImpact;
                vector(i) = opImpact;
            end
        end
        
        function obj = addOperation(obj, op)
            op.parent = obj;
            obj.operations = [obj.operations op];
        end           
        
    end
end

