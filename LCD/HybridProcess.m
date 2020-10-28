classdef HybridProcess < Process
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        
        id string              
        name string                                     
        
        refProduct string
        unit string %e.g. [m]
        quantity double = 1
        quantityExpression string     
        
        intermediateFlowTable table %containing flowName | QuantityExpression | Unit | Provider | ProviderLoc
        elementaryFlowTable table %containing flowName | QuantityExpression | Unit | ID
                                
        htotal %impact vector
        stotal %intermediate flows
        
        scalarImpact % impact for the selected indicator        
        scalarImpactIndex = 534; %IPCC 2007 (obsolete) - GWP 100a                        
    end
    
    methods
        % generate LCIA
        % crateByID
        % visualize Process
                
        function obj = HybridProcess(name)
            obj.id = java.util.UUID.randomUUID.toString;
            obj.name = string(name);            
            obj.quantityExpression = "1";
            obj.refProduct = "reference product";
            obj.unit = "kg";
        end       
        
        function obj = calculateLCIA(obj,app)
            %create f
            n = length(app.A_inv);
            f = zeros(n,1);
            for i = 1:height(obj.intermediateFlowTable)                
                ifRow = obj.intermediateFlowTable(i,:);                
                row = app.ie( (string(app.ie.activityName) == string(ifRow.Provider)) & (string(app.ie.geography) == string(ifRow.ProviderLoc)) & (string(app.ie.product) == string(ifRow.FlowName)),:);                 
                %disp(ifRow);                
                f(row.index+1) = obj.parseQuantity(string(ifRow.QuantityExpression));
                %f(row.index+1) = str2double(ifRow.Amount);                
            end
            
            h = app.C * f;
            obj.stotal = app.A_inv*f;
            
            g = zeros(length(app.Q),1);
            
            for i = 1:height(obj.elementaryFlowTable)
                row = app.ee( (string(app.ee.name) == string(obj.elementaryFlowTable.FlowName(i))) &( string(app.ee.compartment) == string(obj.elementaryFlowTable.Compartment(i))) & (string(app.ee.subcompartment) == string(obj.elementaryFlowTable.Subcompartment(i))),:);
                %g(row.index+1) = str2double(obj.elementaryFlowTable.Amount(i));
                g(row.index+1) = obj.parseQuantity(string(obj.elementaryFlowTable.QuantityExpression));
            end
            
            obj.htotal = h + app.Q * g;               
        end
        
        function impact = generateLCIA(obj,app)
            lciaIndex = app.lciaIndex;
            rate = obj.getRateEff(app);
            obj.quantity = obj.parseQuantity(obj.quantityExpression);
            if app.options.normTime
                norm = app.options.referenceTime;
            else
                norm = 1;
            end            
            impact = obj.htotal(lciaIndex+1)* obj.quantity * rate / norm;
        end
        
        function addIntermediateFlow(obj,FlowName, QuantityExpression, Unit, Provider, ProviderLoc)
            row = table(FlowName, QuantityExpression, Unit, Provider, ProviderLoc);
            obj.intermediateFlowTable = [obj.intermediateFlowTable; row];
        end
        
        function addElementaryFlow(obj,FlowName, QuantityExpression, Unit, Compartment, Subcompartment)
            Compartment = string(Compartment);
            Subcompartment = string(Subcompartment);
            row = table(FlowName, QuantityExpression, Unit, Compartment, Subcompartment);
            obj.elementaryFlowTable = [obj.elementaryFlowTable; row];
        end
        
        
        
        function quantity = parseQuantity(obj,expression)
                        
            parameter = obj.parent.parent.parent.processParameter;            
            
            dicNames = string(fieldnames(parameter ));
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
            quantity = pe.run(expression);
        end
        
        
        function plot(obj,app,axes)                        
                                    
            obj.generateGraph(app);
            
            rate = obj.getRateEff(app);            
            obj.quantity = obj.parseQuantity(obj.quantityExpression);
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
                text(axes, fig.XData(1), fig.YData(1)+(0.04*yLimits),string(obj.graph.Nodes.Impact(1)*obj.quantity.*rate / norm) + " " + app.lciaUnit + ' / yr' ,'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(axes, fig.XData(2:end)+(0.02.*xLimits), fig.YData(2:end) ,string(obj.graph.Nodes.Impact(2:end).*obj.quantity.*rate / norm) + " " + app.lciaUnit + ' / yr','VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 12, 'Color', [.6 .6 .7])
            else
                text(axes, fig.XData(1), fig.YData(1)+(0.04*yLimits),string(obj.graph.Nodes.Impact(1)*obj.quantity.*rate / norm) + " " + app.lciaUnit,'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(axes, fig.XData(2:end)+(0.02.*xLimits), fig.YData(2:end) ,string(obj.graph.Nodes.Impact(2:end).*obj.quantity.*rate / norm) + " " + app.lciaUnit,'VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 12, 'Color', [.6 .6 .7])
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
            %ActID = obj.index+1;
            ActID = -1;
            Name = string(ActID);
            root = Name;
            Amount = obj.quantity;
            Impact = obj.htotal(app.lciaIndex+1);
            Title = string(obj.name);
            Size = 1;
            Color = [.3 .3 .35];
            nodeTable = table(Name, OccID, Title, Amount, Impact, ActID, Size, Color);
            D = addnode(D,nodeTable);
            
            maxTier =8;
            
            C = app.C(app.lciaIndex+1,:);                                                          
            
            for a = 1:height(obj.intermediateFlowTable)                                
                t = obj.intermediateFlowTable(a,:);                                    
                flowIndex = getFlowIndex(app,t.Provider,t.FlowName,t.ProviderLoc);                                
                Amount = obj.stotal(flowIndex+1);                              
                f = zeros(n,1);
                f(flowIndex+1) = Amount;
                h = C*f;               
                relImpact = abs(h/obj.htotal(app.lciaIndex+1));                                
                if  relImpact >= threshold                       
                    ActID = flowIndex+1;
                    Impact = h;
                    OccID = OccID + 1;
                    Name = string(ActID);
                    Title = string(app.ie.activityName(flowIndex+1));                    
                    Size = relImpact;
                    Color  = [0.3 + relImpact*0.7  0.5 0.6];
                    nodeTable = table(Name, OccID, Title, Amount, Impact, ActID, Size, Color);
                    if ~findnode(D,Name)
                        D = addnode(D, nodeTable);                            
                    end
                    if ~findedge(D,root,Name)                                   
                        Weight = Impact;
                        edgeTitle = 'Amount: ' + string(Amount) + '; Impact: ' + string(Impact);
                        edgeColor = Color;
                        edgeTable = table(Weight, edgeTitle, edgeColor);
                        D = addedge(D,root,Name,edgeTable);                        
                        matrixExpand(flowIndex+1,Name,1);
                    end
                end                                                                
            end
            
            obj.graph = D;  
            
            
            function matrixExpand(r,parent,tier)                
                if(tier < maxTier)                    
                    A_tmp = app.A_min(:,r);                    
                    occ = sparse(A_tmp);
                    [index,~,~] = find(occ); % return indices
                    for m=1:length(index)                                                
                        Amount = obj.stotal(index(m));
                        f = zeros(n,1);
                        f(index(m)) = Amount;
                        h = C*f;
                        relImpact = abs(h/obj.htotal(app.lciaIndex+1));
                        if  relImpact >= threshold
                            ActID = index(m);
                            Impact = h;
                            OccID = OccID + 1;
                            Name = string(ActID);
                            Title = string(app.ie.activityName(index(m)));
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
                                matrixExpand(index(m),Name,tier+1);
                            end
                        end
                    end
                end
            end
        end
        
    end
    
    
end

