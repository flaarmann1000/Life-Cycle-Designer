activityName = 'aluminium production, primary, ingot';
activityLoc = 'RoW';
refProduct = 'aluminium, primary, ingot';

%E = EcoinventProcess(app,activityName,activityLoc,refProduct);

index = app.ie((string(app.ie.activityName) == string(activityName) & string(app.ie.geography) == string(activityLoc) & string(app.ie.product) == string(refProduct)),5);
 %index = app.ie((string(app.ie.activityName) == string(activityName))&(string(app.ie.geography) == string(activityLoc)) ,:)
 
 
%%
clc

conditionsTable = readtable('tables/production_generation.xlsx','sheet','shell','PreserveVariableNames',1);

varNames = conditionsTable.Properties.VariableNames;
varNamesOriginal = conditionsTable.Properties.VariableDescriptions;

name = varNames{2}
str = strsplit(name,'.');
stageName = str(1);
opName = str(2);

%%

table = readtable('EcoSelection.xlsx','sheet','lorry');
for i = 1:height(table)
    ie(string(ie.activityName) == table.ActivityName{i},:)
end



%%
save('configListU','configList','-nocompression')


%%
tic
load('configList')
toc

tic 
load('configListU')
toc


%%


fn = string(fieldnames(pp));
pp.area.dependant = true;
pp.massMaintenance.dependant = true;
names = [];
for i = 1:length(fn)
    disp("checking: " + fn(i));
   if pp.(fn(i)).dependant == false
      names = [names fn(i)] ;
   end
   
end