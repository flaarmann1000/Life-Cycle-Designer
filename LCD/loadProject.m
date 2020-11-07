function loadProject(app)

default = "*.lcd";
[file,path] = uigetfile(default,'open project');

load([path file],'-mat','data','G','options');
if isequal(file,0) || isequal(path,0)
    return
end

h = waitbar(0.1,'loading...');

app.options = options;

nodeNames = string(G.Edges.EndNodes);

root = createAssembly(G.Nodes.Title(1),G.Nodes.Name(1));
getChildren(root);

assignin('base','root',root)
app.model.root = root;
app.alternatives.standard= app.model.root;
analyseCompatibility(app,app.model.root);

root.displayAssemblyTree(app,app.CB_ShowFeatures.Value);
root.plot(app);
app.activeElement = app.model.root;
app.projectLoaded = true;
app.L_Mode.Text = lower(app.mode);
app.L_RefTime.Text = "reference time: " + app.options.referenceTime + " yr";
app.setTVSelection();


disp("done");

    function getChildren(asm)
        res = nodeNames(nodeNames(:,1) == string(asm.id),2);
        for i = 1:length(res)
            row = G.Nodes(G.Nodes.Name == res(i),:);
            if string(row.Type) == 'Assembly'
                child = createAssembly(string(row.Title),string(row.Name));
                asm.addAssembly(child);
                getChildren(child);
            else
                child = createComponent(string(row.Title),string(row.Name));
                asm.addComponent(child,app,false);
            end
        end
    end

    function asm = createAssembly(name,id)
        asm = Assembly(name);
        asm.id = id;
        fn = string(matlab.lang.makeValidName(id));
        asm.modelGraph = data.(fn).modelGraph;
        asm.ignore = data.(fn).ignore;
        asm.processParameter = data.(fn).processParameter;
        asm.exchangable = data.(fn).exchangable;
    end

    function com = createComponent(name,id)
        fn = string(matlab.lang.makeValidName(id));
        material = data.(fn).material;
        processParameter = data.(fn).processParameter;
        com = Component(app,name,material,processParameter);
        com.id = id;
        com.solidName = data.(fn).solidName;
        com.classification = data.(fn).classification;
        com.materialGroup = data.(fn).materialGroup;
        com.modelGraph = data.(fn).modelGraph;
        com.features = data.(fn).features;
        com.joints = data.(fn).joints;
        com.ignore = data.(fn).ignore;
        com.exchangable = data.(fn).exchangable;
        com.customParameter = data.(fn).customParameter;
        com.rates = data.(fn).rates;
        com.processParameter = data.(fn).processParameter;
        stageTable = data.(fn).stages;
        stageNames = unique(stageTable.Stage);
        for s = 1:length(stageNames)
            stage = Stage(stageNames(s));
            opTable = stageTable(stageTable.Stage == stageNames(s),:);
            opNames = unique(opTable.Operation);
            for o = 1:length(opNames)
                operation = Operation(opNames(o));
                proTable = opTable(opTable.Operation == opNames(o),:);
                for p = 1:height(proTable)
                    row = proTable(p,:);
                    pro = app.processEngine.getProcess(app,row.PName,row.PLoc,row.PRef);
                    pro.quantityExpression = row.PQuanEx;
                    pro.quantity = row.PQuan;
                    pro.correction = row.PCorr;
                    operation.addProcess(pro);
                end
                stage.addOperation(operation);
            end
            com.setStage(stage);
        end
    end

close(h)

end