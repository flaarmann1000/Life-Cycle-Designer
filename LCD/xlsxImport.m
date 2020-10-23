function xlsxImport(app)

%default = "C:\Users\Z420\Google Drive\circular economy\15 communication\lorenz\*.xlsx";
%default = "*.xlsx";
%[file,path] = uigetfile(default,'Select an xlsx-File');

%profile on

file = 'Bom.xlsx';
path = 'C:\Users\Z420\Google Drive\circular economy\15 communication\lorenz\';

%file = 'xlsBom.xlsx';
%path = '';

% --- generate Assembly

bomTable = readtable([path file],'Sheet','BOM');

maxsteps = height(bomTable);
step = 0;
h = waitbar(0,['importing xlsx...']);

assemblyNames = unique(bomTable.assembly);
parentNames = unique(bomTable.assemblyParent);

asmList = Assembly.empty;
root = Assembly.empty;

for i = 1:length(parentNames)
   asm = getAsm(parentNames(i));   
end

for i =1:length(assemblyNames)    
    asm = getAsm(assemblyNames(i));    
    asmTable = bomTable(string(bomTable.assembly) == string(assemblyNames(i)),:);
    for j = 1:height(asmTable)       
        row = asmTable(j,:);        
        waitbar(step/maxsteps,h,[strcat("importing ",row.component)]);
        step = step+1;
        if row.material{1} ~= '-'
            processParameter.mass.value = row.weight;            
            processParameter.density.value = app.materialProperties.Density(string(app.materialProperties.Material) == string(row.material));            
            processParameter.volume.value = processParameter.mass.value / processParameter.density.value;            
            bx = processParameter.volume.value^(1/3);
            by = processParameter.volume.value^(1/3);
            bz = processParameter.volume.value^(1/3);
            processParameter.boundingBoxX.value = bx;
            processParameter.boundingBoxY.value = by;
            processParameter.boundingBoxZ.value = bz;
            processParameter.surface.value = 2 * (bx*by + by*bz + bz*bx);
            processParameter.paintMass.value = processParameter.surface.value / 16.5 * 1.1;
            if row.exchangable == "yes"
                com.exchangable = true;
            end            
            com = Component(app,row.component,row.material, processParameter);                                 
            asm.addComponent(com,app, true);                              
        end
    end
end       
waitbar(1,h,["displaying component..."]);

app.model.root = root;
root.displayAssemblyTree(app.TV_Components,false);
root.displayAssembly(app);
app.activeElement = app.model.root;

% --- generate hybridProcesses
replace = true;
hyProTable = readtable([path file],'Sheet','hybridProcesses');
names = string(unique(hyProTable.name));

load("hprocessStack","stack")

for n = 1:length(names)
    tab = hyProTable(hyProTable.name == names(n),:);
    action = string(tab.action(1));
    if action == "create"
        hyPro = HybridProcess(names(n));
        hyPro.refProduct = string(tab.product(1));
        hyPro.unit = string(tab.unit(1));
        iFlowTab = tab(tab.flowType == "intermediate",:);
        for i = 1:height(iFlowTab)            
            FlowName = iFlowTab.flowName(i);
            Amount = string(iFlowTab.quantity(i));
            Unit = iFlowTab.flowUnit(i);
            ProviderName = iFlowTab.flowProvider(i);
            ProviderLoc = iFlowTab.flowProviderLoc(i);
            row = table(FlowName,Amount,Unit,ProviderName,ProviderLoc);
            hyPro.intermediateFlowTable = [hyPro.intermediateFlowTable; row];
        end       
        hyPro.calculateLCIA(app);
        stack = addToHyProStack(stack, hyPro, replace);
    end
end

save("hprocessStack","stack");

% --- execute overwrites

overwritesTable = readtable([path file],'Sheet','overwrites');

for i = 1:height(overwritesTable)
    name = overwritesTable.component(i);
    com = root.getElementByName(name);    
    stage = com.stages(string({com.stages.name}) == overwritesTable.stageId(i));
    op = stage.operations(string({stage.operations.name}) == overwritesTable.operation(i));
    if isempty(op)
        op = Operation(overwritesTable.operation(i));
        stage.addOperation(op);
    end
    if overwritesTable.processType(i) == "hybridProcess"
        original = stack(string({stack.name})' == overwritesTable.Name(i));
        pro = copy(original);
    else
        name = overwritesTable.Name(i);
        loc = overwritesTable.Loc(i);
        product = overwritesTable.Product(i);
        pro = app.processEngine.getProcess(app,name,loc,product);
    end
    pro.quantityExpression = overwritesTable.quantityExpression(i);
    op.addProcess(pro);
end



close(h); 

%profile viewer

    function asm = getAsm(name)
        name = string(name);
        for a = 1:length(asmList)
           if asmList(a).name == name
              asm = asmList(a);
              return
           end
        end
        asm = Assembly(name);
       if (~sum((name ~= string(bomTable.assembly)) & (string(bomTable.assembly) == string(bomTable.assemblyParent))) && (sum(name == string(bomTable.assemblyParent)) > 0))       
           root = asm;           
           disp(asm.name + ' is root');
       else
           res = bomTable.assemblyParent(bomTable.assembly == name);           
           asm.parent = getAsm(res(1));
           asm.parent.addAssembly(asm);
           disp('added ' + asm.name + " to " + asm.parent.name);
           disp(length(asm.parent.assemblies));
       end
       asmList = [asmList asm];
    end       
end   