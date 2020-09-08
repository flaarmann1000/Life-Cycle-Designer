%% generate Material and process type list  - Start Here

classificationType = ["production","assembly","use","eol"];


for c = 1:length(classificationType)

    t = readtable("tables/"+classificationType(c)+"_classification.xlsx",'sheet','conditions');
    numClassifications = height(t);

    t = readtable("tables/"+classificationType(c)+"_classification.xlsx",'sheet','classification');
    classifications = cell(0);

    materialList = string(t.material);

    for i = 1:length(materialList)
        material = materialList(i);
        d = t( string(t.material) ==  material , :);
        list = [];
        for e = 2:numClassifications+1
            list = [list string(d.(e))];
        end
        list = {unique(list)};        
        classifications(i) = list;
    end
    
    if c == 1
        save('materials.mat','materialList');
    end
    
    save(classificationType(c)+"ClassificationList.mat",'classifications');
    disp(classificationType(c)+" exported");

end

% run first to create stack

stack = ConfigProcessDealer();

proTable = readtable("EcoSelection.xlsx","sheet","processes");

for e=1:height(proTable)   
   p = ConfigProcess(proTable.ActivityName{e},proTable.Location{e},proTable.ReferenceProduct{e});
   stack = stack.addProcess(p);
end

varTable = readtable("EcoSelection.xlsx","sheet","parameters");

% add alternativces
for e = 1:height(varTable)
    t = readtable("EcoSelection.xlsx","sheet",varTable.Parameters{e});
    p = ConfigProcess(t.ActivityName{1},t.Location{1},t.ReferenceProduct{1});   
    for i = 2:height(t)
        a = ConfigProcess(t.ActivityName{i},t.Location{i},t.ReferenceProduct{i});
        p = p.addAlternative(a);
    end
    stack = stack.addProcess(p);
end



% run second to create configs

configList = ConfigWrapper("configs");

%classificationType = ["production","assembly"];

for c = 1:length(classificationType)

    classifications = sheetnames('tables/'+classificationType(c)+'_generation.xlsx');

    for s = 1:length(classifications)  
        classification = classifications(s);               
        classiTable = readtable('tables/'+classificationType(c)+'_generation.xlsx','sheet',classification,'PreserveVariableNames',1);
        varNames = classiTable.Properties.VariableNames;                

        main = classiTable.(varNames{2});        
        for m = 1:height(classiTable)            
            material = classiTable.material{m};

            if  main{m} ~= "#"  && (material ~= "none")                 
                config = Config(material + " - " + classification);                
                config.material = material;
                config.classification = classification;

                for o = 1:(length(varNames)-1)/4 
                    opNr = o*4-2; %2,6,10...
                    columnName = varNames{opNr};
                    entry = string(classiTable.(columnName));
                    entry = entry(m);
                    if ~ismissing(entry) && ~isempty(entry) && (entry ~= "")
                        str = strsplit(columnName,'.');
                        stageName = str(1);
                        operationName = str(2);
                        stage = config.getStage(stageName);
                        operation = stage.getOperation(operationName);
                        p = stack.getProcessByName(entry);                        
                        correctionColumn = string(classiTable.(varNames{opNr+1}));
                        p.correction = correctionColumn(m);
                        parameterColumn = string(classiTable.(varNames{opNr+2}));
                        p.parameter = parameterColumn(m);
                        operation = operation.addProcess(p);
                        stage = stage.updateOperation(operation);
                        config = config.updateStage(stage);
                    end                              
                end
               configList = configList.addConfig(config);    
            end                    
        end
    end
        
end
    
%save('configList.mat','configList')
%disp(string(length(configList.configs)) + " configs saved")    

stack.check();

% convert configList to table

configTable = table;
altProcessesTable = table;

for c = 1:length(configList.configs)
   config = configList.configs(c);
   for  s = 1:length(configList.configs(c).stages)
       stage = configList.configs(c).stages(s);
       for o = 1:length(configList.configs(c).stages(s).operations)
           operation = configList.configs(c).stages(s).operations(o);
           for p = 1:length(configList.configs(c).stages(s).operations(o).processes)
               process = configList.configs(c).stages(s).operations(o).processes(p);
               configStruct = [];
               configStruct.ConfigMaterial = config.material;
               configStruct.Classification = config.classification;
               configStruct.StageName = stage.name;
               configStruct.OperationName = operation.name;
               configStruct.ProcessName = process.activityName;
               configStruct.ProcessLocation = process.loc;
               configStruct.ProcessLocList = join((string(process.locList)+'#')');
               configStruct.ProcessCorrection = process.correction;
               configStruct.ProcessParameter = process.parameter;
               configStruct.ProcessType = process.type;
               configStruct.ProcessRefProduct = string(process.refProduct);                              
               configStruct.AlternativeProcessName = '#';
               configStruct.AlternativeProcessLoc = '#';
               configStruct.AlternativeProcessRefProduct = '#';
               configTable = [configTable;struct2table(configStruct)];               
               if isempty(altProcessesTable) || isempty(altProcessesTable(altProcessesTable.ProcessName == process.activityName,:))               
                   processStruct.ProcessName = process.activityName;
                   for a = 1:length(process.alternativeProcesses)                       
                      processStruct.AlternativeProcessName = process.alternativeProcesses(a).activityName;
                      processStruct.AlternativeProcessLoc = process.alternativeProcesses(a).loc;
                      processStruct.AlternativeProcessRefProduct = string(process.alternativeProcesses(a).refProduct);
                      altProcessesTable = [altProcessesTable;struct2table(processStruct)]; 
                   end                        
               end
           end
       end
   end
end

save('configTable.mat','configTable','altProcessesTable');
disp(string(length(configList.configs)) + " configs saved")    
    
%% config read benchmark

%save('configTable','configTable')
%writetable(configTable,'configTable')


tic 
load configTable
toc
tic
readtable('configTable');
toc   
% tic
% load configList;
% toc