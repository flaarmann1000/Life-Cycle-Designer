classdef EcoinventProcess < Process
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        
        id string
        
        locList string
        
        name string
        refProduct string
        activityLoc string
        functionalUnit string
        unit string %e.g. [m]
        cost double
        index double
        quantity double = 1
        quantityExpression string
        correction = 1;
        
        alternativeProcesses EcoinventProcess
        
        stotal %intermediate flows
        gtotal %elementary flows
        htotal %impact vector
        
        scalarImpact % impact for the selected indicator
        %scalarImpactIndex = 189; %ecological footprint - total
        scalarImpactIndex = 534; %IPCC 2007 (obsolete) - GWP 100a
                
        
    end
    
    methods
        % generate LCIA
        % crateByID
        % visualize Process
        function obj = EcoinventProcess(app, activityName, activityLoc, refProduct)
            obj.id = java.util.UUID.randomUUID.toString;
            obj.name = string(activityName);
            obj.refProduct = string(refProduct);
            obj.activityLoc = string(activityLoc);
            if string(activityName) == "empty"
                obj.scalarImpact = 0;
                return
            end
            
            n = length(app.A_inv);
            row = app.ie((string(app.ie.activityName) == string(activityName) & string(app.ie.geography) == string(activityLoc) & string(app.ie.product) == string(refProduct)),:);
            obj.index = row.index;
            obj.unit = row.unitName;
            
            rowLoc = app.ie((string(app.ie.activityName) == string(activityName) & string(app.ie.product) == string(refProduct)),:);
            obj.locList = string(rowLoc.geography);
            
            f = zeros(n,1);
            f(obj.index+1) = 1;
            
            obj.stotal = app.A_inv*f; %product flows
            obj.gtotal = app.B*obj.stotal; %elementary flows
            obj.htotal = app.Q*obj.gtotal; %impact            
            obj.scalarImpact = obj.htotal(app.lciaIndex);
            obj = obj.generateGraph(app);
        end
        
        function impact = generateLCIA(obj,app)
            lciaIndex = app.lciaIndex;
            rate = obj.getRateEff(app);
            obj.quantity = parseQuantity(obj);
            if app.options.normTime
                norm = app.options.referenceTime;
            else
                norm = 1;
            end
            
            impact = obj.htotal(lciaIndex+1)* obj.correction * obj.quantity * rate / norm;
        end
        
        
        
        function quantity = parseQuantity(obj)
                        
            parameter = obj.parent.parent.parent.processParameter;                                   
            
            dicNames = string(fieldnames(parameter));
            dicValues = zeros(length(dicNames),1);
            
            for i = 1:length(dicNames)                
                dicValues(i) = parameter.(dicNames(i)).value;
            end
            
            cparameter = obj.parent.parent.parent.customParameter;
            if ~isempty(cparameter)
                cdicNames = string(fieldnames(cparameter));
                cdicValues = zeros(length(cdicNames),1);
                for i = 1:length(cdicNames)                    
                    cdicValues(i) = cparameter.(cdicNames(i)).value;
                end
                pe = parserEngine();
                pe.dicNames = [dicNames; cdicNames];
                pe.dicValues = [dicValues; cdicValues];
            else
                pe = parserEngine();
                pe.dicNames = [dicNames];
                pe.dicValues = [dicValues];
            end
            quantity = pe.run(obj.quantityExpression);
        end
        
        
        function displayProcess(obj,app,axes)
                        
            obj.scalarImpact = obj.htotal(app.lciaIndex+1);            
            obj = obj.generateGraph(app);
            
            rate = obj.getRateEff(app);
            obj.quantity = parseQuantity(obj);
            if app.options.normTime
                norm = app.options.referenceTime;
            else
                norm = 1;
            end
            
            if height(obj.graph.Edges) > 0                                
                fig = plot(axes, obj.graph,'NodeLabel',obj.graph.Nodes.Title,'Layout',"layered",'Direction','up','LineWidth',abs(obj.graph.Edges.Weight/obj.htotal(app.lciaIndex+1))*20,'EdgeColor',obj.graph.Edges.edgeColor*0.98-.01, 'MarkerSize',obj.graph.Nodes.Size*25,'NodeColor',obj.graph.Nodes.Color*0.98-.01,'NodeFontAngle','normal', 'NodeLabelColor', [.5 .5 .5] , 'NodeFontSize', 10);
            else
                fig = plot(axes, obj.graph,'NodeLabel',obj.graph.Nodes.Title,'Layout',"layered",'MarkerSize',obj.graph.Nodes.Size*25,'NodeColor',obj.graph.Nodes.Color*0.98-.01,'NodeFontAngle','normal', 'NodeLabelColor', [.5 .5 .5] , 'NodeFontSize', 10);
            end
            
            xLimits = get(axes,'XLim');  %# Get the range of the x axis
            xLimits = xLimits(2)-xLimits(1);
            yLimits = get(axes,'YLim');
            yLimits = yLimits(2)-yLimits(1);
            
            text(axes, fig.XData(1), fig.YData(1)+(0.04*yLimits),obj.graph.Nodes.Title(1),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [.3 .3 .35], 'FontWeight','normal')
            text(axes, fig.XData(2:end)+(0.02.*xLimits), fig.YData(2:end)+(0.01.*xLimits) ,obj.graph.Nodes.Title(2:end),'VerticalAlignment','baseline','HorizontalAlignment', 'left','FontSize', 14, 'Color', [.3 .3 .35])
            if app.options.normTime
                text(axes, fig.XData(1), fig.YData(1)+(0.04*yLimits),string(obj.graph.Nodes.Impact(1)*obj.correction*obj.quantity.*rate / norm) + " " + app.lciaUnit + ' / yr' ,'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(axes, fig.XData(2:end)+(0.02.*xLimits), fig.YData(2:end) ,string(obj.graph.Nodes.Impact(2:end).*obj.correction.*obj.quantity.*rate / norm) + " " + app.lciaUnit + ' / yr','VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 12, 'Color', [.6 .6 .7])
            else
                text(axes, fig.XData(1), fig.YData(1)+(0.04*yLimits),string(obj.graph.Nodes.Impact(1)*obj.correction*obj.quantity.*rate / norm) + " " + app.lciaUnit,'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(axes, fig.XData(2:end)+(0.02.*xLimits), fig.YData(2:end) ,string(obj.graph.Nodes.Impact(2:end).*obj.correction.*obj.quantity.*rate / norm) + " " + app.lciaUnit,'VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 12, 'Color', [.6 .6 .7])
            end
            
            resetplotview(axes);
            enableDefaultInteractivity(axes);
            axes.Interactions = [zoomInteraction, panInteraction];
            %set(fig,'ButtonDownFcn',@app.getCoord);
            fig.NodeLabel = {};
        end
        
        function obj = generateGraph(obj,app)
            n = length(app.A_min);
            threshold = 0.2;
            
            D = digraph();
            OccID = 1;
            ActID = obj.index+1;
            Name = string(ActID);
            Amount = obj.quantity*obj.correction;
            Impact = obj.htotal(app.lciaIndex+1);
            Title = string(obj.name);         
            Size = 1;
            Color = [.3 .3 .35];
            nodeTable = table(Name, OccID, Title, Amount, Impact, ActID, Size, Color);
            D = addnode(D,nodeTable);
            
            maxTier =8;
            
            C = app.C(app.lciaIndex+1,:);
            
            matrixExpand(obj.index+1,Name,1);
            
            obj.graph = D;
            
            function matrixExpand(r,parent,tier)
                if(tier < maxTier)
                    %fFull = zeros(n,1);
                    %fFull(r) = 1;
                    %A_tmp = app.A_min*fFull; %takes 10 seconds
                    A_tmp = app.A_min(:,r);
                    occ = sparse(A_tmp);
                    [i,~,~] = find(occ); % return indices
                    for m=1:length(i)
                        Amount = obj.stotal(i(m));
                        f = zeros(n,1);
                        f(i(m)) = Amount;
                        h = C*f;
                        relImpact = abs(h/obj.scalarImpact);
                        if  relImpact >= threshold
                            ActID = i(m);
                            Impact = h;
                            OccID = OccID + 1;
                            Name = string(ActID);
                            Title = string(app.ie.activityName(i(m)));                            
                            Size = relImpact;
                            Color  = [0.3 + relImpact*0.7  0.5 0.6];
                            nodeTable = table(Name, OccID, Title, Amount, Impact, ActID, Size, Color);
                            if ~findnode(D,Name)
                                D = addnode(D, nodeTable);
                            end
                            if ~findedge(D,parent,Name)
                                Weight = Impact;
                                edgeTitle = 'Amount: ' + string(Amount) + '; Impact: ' + string(Impact);
                                edgeColor = Color;
                                edgeTable = table(Weight, edgeTitle, edgeColor);
                                D = addedge(D,parent,Name,edgeTable);
                                matrixExpand(i(m),Name,tier+1);
                            end
                        end
                    end
                end
            end
        end
        
    end
    
    
end

