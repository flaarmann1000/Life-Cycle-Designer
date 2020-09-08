function [config] = getConfig(app,material,classification)
%getConfig returns config struct from material and classification

stagesTable = app.configTable(string(app.configTable.ConfigMaterial) == material & string(app.configTable.Classification) == classification,:);
stageNames = unique(stagesTable.StageName);

config = [];
for s = 1:length(stageNames)
    config.stages(s).name = stageNames(s);
    operationsTable = stagesTable(string(stagesTable.StageName) == stageNames(s),:);
    operationNames = unique(operationsTable.OperationName);
    for o = 1:length(operationNames)
        config.stages(s).operations(o).name = operationNames(o);
        processTable = operationsTable(string(operationsTable.OperationName) == operationNames(o),:);
        for p = 1:height(processTable)
            config.stages(s).operations(o).processes(p).activityName = processTable.ProcessName(p);
            config.stages(s).operations(o).processes(p).loc = processTable.ProcessLocation(p);            
            config.stages(s).operations(o).processes(p).locList = strsplit(processTable.ProcessLocList(p),'# ');
            config.stages(s).operations(o).processes(p).correction = processTable.ProcessCorrection(p);
            config.stages(s).operations(o).processes(p).parameter = processTable.ProcessParameter(p);
            config.stages(s).operations(o).processes(p).type = processTable.ProcessType(p);
            config.stages(s).operations(o).processes(p).refProduct = processTable.ProcessRefProduct(p);                           
            altTable = app.altProcessesTable(app.altProcessesTable.ProcessName == processTable.ProcessName(p),:);
            for a = 1:height(altTable)
                config.stages(s).operations(o).processes(p).alternativeProcesses(a).activityName = altTable.AlternativeProcessName(a);
                config.stages(s).operations(o).processes(p).alternativeProcesses(a).loc = altTable.AlternativeProcessLoc(a);
                config.stages(s).operations(o).processes(p).alternativeProcesses(a).refProduct = altTable.AlternativeProcessRefProduct(a);
            end
            
        end        
    end
end

end

