function saveProject(app)
default = "*.lcd";
[file,path] = uiputfile(default,'save project');
if isequal(file,0) || isequal(path,0)
    return
end

options = app.options;
rootAsm = app.model.root;
G = digraph();
data = struct();
NodeProps = table(rootAsm.id,rootAsm.name,"Assembly",'VariableNames',{'Name','Title','Type'});
fieldname = matlab.lang.makeValidName(rootAsm.id);
data.(fieldname) = asmData(rootAsm);
G = addnode(G, NodeProps);
iterate(rootAsm);
save([path file],"G","data","options");



    function iterate(parentAsm)
        for a=1:length(parentAsm.assemblies)
            asm = parentAsm.assemblies(a);
            asmNodeProps = table(asm.id,asm.name,"Assembly",'VariableNames',{'Name','Title','Type'});
            fn = matlab.lang.makeValidName(asm.id);
            data.(fn) = asmData(asm);
            G = addnode(G, asmNodeProps);
            G = addedge(G, parentAsm.id, asm.id);
            iterate(parentAsm.assemblies(a));
        end
        for c=1:length(parentAsm.components)
            com = parentAsm.components(c);
            comNodeProps = table(com.id,com.name,"Component",'VariableNames',{'Name','Title','Type'});
            fn = matlab.lang.makeValidName(com.id);
            data.(fn) = comData(com);
            G = addnode(G, comNodeProps);
            G = addedge(G, parentAsm.id, com.id);
        end
    end


    function data = asmData(asm)
        data = struct();
        data.modelGraph = asm.modelGraph;
        data.ignore = asm.ignore;
        data.processParameter = asm.processParameter;
        data.exchangable = asm.exchangable;
    end

    function data = comData(com)
        data = struct();
        data.solidName = com.solidName;
        data.classification = com.classification;
        data.material = com.material;
        data.materialGroup = com.materialGroup;
        data.stages = processTable(com);
        %data.compatibility = com.compatibility;
        %data.compativilityStatus = com.compatibilityStatus;
        data.modelGraph = com.modelGraph;
        data.features = com.features;
        data.joints = com.joints;
        data.ignore = com.ignore;
        data.exchangable = com.exchangable;
        data.processParameter = com.processParameter;
        data.customParameter = com.customParameter;
        data.rates = com.rates;
    end

    function tab = processTable(com)
        tab = table();
        for s = 1:length(com.stages)
            stage = com.stages(s);
            for o = 1:length(stage.operations)
                operation = stage.operations(o);
                for p = 1:length(operation.processes)
                    pro = operation.processes(p);
                    row = table(stage.name,operation.name,pro.name,pro.activityLoc,pro.refProduct,pro.quantityExpression,pro.quantity,pro.correction,'VariableNames',{'Stage','Operation','PName','PLoc','PRef','PQuanEx','PQuan','PCorr'});
                    tab = [tab;row];
                end
            end
        end
    end

end