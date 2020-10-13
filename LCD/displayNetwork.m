function displayNetwork(app)

h = waitbar(0,['creating network...']);

ref = app.model.root.generateLCIA(app);
D = digraph();
D = addnode(D,getNodeTable(app.activeElement));

if isa(app.activeElement, "Assembly")
    addBranches(app.activeElement);
else
    scanStages(app.activeElement);
end

assignin("base",'D',D) % copies app object to workspace

axes = app.UIAxes;
fig = plot(axes, D,'NodeLabel',D.Nodes.Title,'Layout',"force",'LineWidth',abs(D.Edges.Weight)*20,'EdgeColor',D.Edges.edgeColor-.01, 'MarkerSize',D.Nodes.Size*25,'NodeColor',D.Nodes.Color-.01,'NodeFontAngle','normal', 'NodeLabelColor', [.5 .5 .5] , 'NodeFontSize', 10,'SelectionHighlight','off');
text(axes, fig.XData(1:end), fig.YData(1:end),D.Nodes.Title(1:end),'VerticalAlignment','baseline','HorizontalAlignment', 'center','FontSize', 10, 'Color', [.3 .3 .35]);
axis(axes,"fill")

resetplotview(axes);
axes.Toolbar.Visible = 'off';
enableDefaultInteractivity(axes);
axes.Interactions = [regionZoomInteraction,zoomInteraction];
fig.NodeLabel = {};

close(h);




    function addBranches(asm)
        for a = 1:length(asm.assemblies)
            D = addnode(D, getNodeTable(asm.assemblies(a)));
            D = addedge(D,asm.id,asm.assemblies(a).id,getEdgeTable(asm.assemblies(a)));
            addBranches(asm.assemblies(a));
        end
        
        for c = 1:length(asm.components)
            waitbar((c-1)/length(asm.components),h,['creating network...']);
            comp = asm.components(c);
            D = addnode(D, getNodeTable(comp));
            D = addedge(D,asm.id,comp.id,getEdgeTable(comp));
            scanStages(comp);
        end
        
    end

    function scanStages(com)
        for s = 1:length(com.stages)
                st = com.stages(s);
                D = addnode(D, getNodeTable(st));
                D = addedge(D,com.id,st.id,getEdgeTable(st));
                for o = 1:length(st.operations)
                    op = st.operations(o);
                    D = addnode(D, getNodeTable(op));
                    D = addedge(D,st.id,op.id,getEdgeTable(op));
                    for p = 1:length(op.processes)
                        pro = op.processes(p);
                        D = addnode(D, getNodeTable(pro));
                        D = addedge(D,op.id,pro.id,getEdgeTable(pro));
                    end
                end
                
            end
    end

    function nodeTable = getNodeTable(thing)
        Title = thing.name;
        Name = thing.id;
        Amount = thing.generateLCIA(app) + 0.001;
        Color  = [0.3 + abs(Amount)/ref*0.65  0.5 0.6];
        Size = abs(Amount/ref);
        nodeTable = table(Title, Name, Amount, Color, Size);
    end

    function nodeTable = getEdgeTable(thing)
        edgeTitle = thing.name;
        Weight = abs(thing.generateLCIA(app)) / ref + 0.001;
        edgeColor  = [0.3 + Weight*0.699  0.5 0.6];
        nodeTable = table(Weight, edgeTitle, edgeColor);
    end
end