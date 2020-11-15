%% generate Material and process type list 

classificationType = ["production","assembly","use","eol"];


for c = 1:length(classificationType)

    t = readtable("tables/"+classificationType(c)+"_classification.xlsx",'sheet','conditions');
    numClassifications = height(t);

    t = readtable("tables/"+classificationType(c)+"_classification.xlsx",'sheet','classification');
    classifications = cell(0);

    materialGroupList = string(t.materialGroup);

    for i = 1:length(materialGroupList)
        materialGroup = materialGroupList(i);
        d = t( string(t.materialGroup) ==  materialGroup , :);
        list = [];
        for e = 2:numClassifications+1
            list = [list string(d.(e))];
        end
        list = {unique(list)};        
        classifications(i) = list;
    end       
    
    save(classificationType(c)+"ClassificationList.mat",'classifications');
    disp(classificationType(c)+" exported");

end

%%
% run first to create stack

stack = ConfigProcessDealer();

%proTable = readtable("tables/EcoSelection.xlsx","sheet","processes");

% for e=1:height(proTable)   
%    p = ConfigProcess(proTable.ActivityName{e},proTable.Location{e},proTable.ReferenceProduct{e});
%    stack = stack.addProcess(p);
% end

GroupTable = readtable("tables/processGroups.xlsx","sheet","groups");

% add alternativces
for e = 1:height(GroupTable)
    t = readtable("tables/processGroups.xlsx","sheet",GroupTable.GroupNames{e});
    p = ConfigProcess(t.ActivityName{1},t.Location{1},t.ReferenceProduct{1});   
    for i = 2:height(t)
        a = ConfigProcess(t.ActivityName{i},t.Location{i},t.ReferenceProduct{i});
        p = p.addAlternative(a);
    end
    stack = stack.addProcess(p);
end



% run second to create configs

configList = ConfigWrapper("configs");

for c = 1:length(classificationType)

    classifications = sheetnames('tables/'+classificationType(c)+'_generation.xlsx');

    for s = 1:length(classifications)  
        classification = classifications(s);               
        classiTable = readtable('tables/'+classificationType(c)+'_generation.xlsx','sheet',classification,'PreserveVariableNames',1);
        varNames = classiTable.Properties.VariableNames; % all column names
        main = classiTable.(varNames{2}); %decides if this classification will be generated (~= #)  
        for m = 1:height(classiTable)            
            materialGroup = classiTable.materialGroup{m}; % e.g. aluminium

            if  main{m} ~= "#"  && (materialGroup ~= "none")                 
                config = Config(materialGroup + " - " + classification);                
                config.materialGroup = materialGroup;
                config.classification = classification;

                for o = 1:(length(varNames)-1)/6 
                    opNr = o*6-4; %2,8,14...
                    columnName = varNames{opNr};                    
                    row = string(classiTable.(columnName));
                    processName = row(m);
                    if ~ismissing(processName) && ~isempty(processName) && (processName ~= "")
                        str = strsplit(columnName,'.');
                        stageName = str(1);
                        operationName = str(2);
                        stage = config.getStage(stageName);
                        operation = stage.getOperation(operationName);
                        %p = stack.getProcessByName(entry);                        
                        RefColumn = string(classiTable.(varNames{opNr+4}));
                        ref = RefColumn(m);
                        LocColumn = string(classiTable.(varNames{opNr+5}));
                        loc = LocColumn(m);
                        p = stack.getProcess(processName,ref,loc);
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
               configStruct.ConfigMaterial = config.materialGroup;
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