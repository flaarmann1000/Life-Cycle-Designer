classdef EcoinventProcess
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        id
        activityName
        functionalUnit
        cost
        index
        
        stotal %intermediate flows
        gtotal %elementary flows
        htotal %impact                           
    end
    
    methods        
        % generate LCIA
        % crateByID
        % visualize Process      
        function obj = EcoinventProcess(app, activityName, activityLoc)
            methodName = 'IPCC 2007';
            lciaIndicator = 'GWP 100a';           
            n = length(app.A_min);
    
            activityTable = app.ie(find(contains(app.ie.activityName,activityName)),:); %get index for activity            
            indexTable = activityTable(find(contains(activityTable.geography,activityLoc)),5);
            if length(indexTable.index) > 1
                obj.index = indexTable.index(2);   
            else
                obj.index = indexTable.index;   
            end

            lciaTableMethods = app.LCIA(find(contains(app.LCIA.method,methodName)),:);
            lciaTableIndicators = lciaTableMethods(find(contains(lciaTableMethods.indicator,lciaIndicator)),:);
            lciaIndex = lciaTableIndicators.index(1);
            select = app.Q(lciaIndex+1,:);       

            f= zeros(n,1);                
            f(obj.index+1) = 1;  
            obj.stotal = app.A_inv*f; %product flows
            obj.gtotal = app.B*obj.stotal; %elementary flows
            obj.htotal = select*obj.gtotal; %impact     
        end
        
        function displayProcess(obj,app)
            n = length(app.A_min);
            threshold = 0.1;            

            D = digraph();
            OccID = 1;
            ActID = obj.index+1;    
            Name = string(ActID);
            Amount = 1;
            Impact = obj.htotal;            
            Title = string(app.ie.activityName(obj.index+1));
            Size = 1;
            Color = [.3 .3 .35];    
            nodeTable = table(Name, OccID, Title, Amount, Impact, ActID, Size, Color);
            D = addnode(D,nodeTable);

            maxTier =20;
            matrixExpand(obj.index+1,Name,1);            
            
            fig = plot(app.UIAxes, D,'NodeLabel',D.Nodes.Title,'Layout',"layered",'LineWidth',abs(D.Edges.Weight)/obj.htotal*20, 'NodeColor','black','EdgeColor',D.Edges.edgeColor, 'MarkerSize',D.Nodes.Size*25,'NodeColor',D.Nodes.Color,'NodeFontAngle','normal', 'NodeLabelColor', [.5 .5 .5] , 'NodeFontSize', 10);    
            
            text(app.UIAxes, fig.XData(1), fig.YData(1)+0.25 ,D.Nodes.Title(1),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [.3 .3 .35], 'FontWeight','normal')   
            text(app.UIAxes, fig.XData(1), fig.YData(1)+0.25 ,string(D.Nodes.Impact(1)),'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')    
            text(app.UIAxes, fig.XData(2:end)+.05, fig.YData(2:end)+0.02 ,D.Nodes.Title(2:end),'VerticalAlignment','baseline','HorizontalAlignment', 'left','FontSize', 14, 'Color', [.3 .3 .35])   
            text(app.UIAxes, fig.XData(2:end)+.05, fig.YData(2:end) ,string(D.Nodes.Impact(2:end)),'VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 12, 'Color', [.6 .6 .7])
            set(fig,'ButtonDownFcn',@app.getCoord);
            resetplotview(app.UIAxes);
            
%             text(app.UIAxes, fig.XData(1), fig.YData(1) ,D.Nodes.Title(1),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.3 .3 .35], 'FontWeight','normal')   
%             text(app.UIAxes, fig.XData(1), fig.YData(1) ,string(D.Nodes.Impact(1)),'VerticalAlignment','top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'Color', [.6 .6 .7], 'FontWeight','normal')    
%             text(app.UIAxes, fig.XData(2:end), fig.YData(2:end) ,D.Nodes.Title(2:end),'VerticalAlignment','baseline','HorizontalAlignment', 'left','FontSize', 10, 'Color', [.3 .3 .35])   
%             text(app.UIAxes, fig.XData(2:end), fig.YData(2:end) ,string(D.Nodes.Impact(2:end)),'VerticalAlignment','top','HorizontalAlignment', 'left','FontSize', 10, 'Color', [.6 .6 .7])
            
            
            fig.NodeLabel = {};             

            function matrixExpand(r,parent,tier)                      
                if(tier < maxTier)  
                    fFull = zeros(n,1);                
                    fFull(r) = 1;
                    A_tmp = app.A_min*fFull;
                    occ = sparse(A_tmp);            
                    [i,~,~] = find(occ); % return indices                               
                    for m=1:length(i)
                        Amount = obj.stotal(i(m));
                        f = zeros(n,1);
                        f(i(m)) = Amount;                
                        h = app.com*f;           
                        relImpact = abs(h/obj.htotal);
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
                                %edgeColor = [relImpact  (1-relImpact)/3 (1-relImpact)/3 ];                        
                                edgeColor = Color;
                                edgeTable = table(Weight, edgeTitle, edgeColor);                    
                                D = addedge(D,parent,Name,edgeTable);
                                %D = addedge(D,Name,parent,edgeTable);
                                matrixExpand(i(m),Name,tier+1);
                            end                    
                        end
                    end                    
                end
            end

            
        end
    end
    
    
end

