clear 

%% Open Table
T = readtable('D:\studium\TUM\BA\CE\data_handling\matlab_lca\matlab_zolca\db\Ecoinvent - cut-off system model\ecoinvent 3.6_cut-off_ecoSpold02\FilenameToActivtiyLookup.csv','Format','%s %s %s %s');

%% Search for Activity, Returns Table
%Occ = T(find(strcmp('aluminium alloy production, AlLi',T.ActivityName)),:)
Occ = T(find(strcmp('steel milling, small parts',T.ActivityName)),:)


% Search within Occurrences
%Res = Occ(find(strcmp('RER',Occ.Location)),:)
Res = Occ(1,:)

% Get Filename for Result
filename = string(Res.Filename)

% Read out File
struct = xml2struct("D:\studium\TUM\BA\CE\data_handling\matlab_lca\matlab_zolca\db\Ecoinvent - cut-off system model\ecoinvent 3.6_cut-off_ecoSpold02\datasets\" + filename)

%% Get Exchanges
exchanges = struct.ecoSpold.childActivityDataset.flowData.intermediateExchange

%% Get exchangeNames
exchangeNames = strings(length(exchanges),1);
for i=1:length(exchanges)
   exchangeNames(i) = exchanges{i}.name.Text;
end
exchangeNames 

%% Search for RefProducts, Returns Table
RefProducts = T(find(strcmp(exchangeNames(1),T.ReferenceProduct)),:)

%% Pick first File
filenameRef = string(RefProducts.Filename(1))

%% Read out File for RefProuct
structRef = xml2struct("D:\studium\TUM\BA\CE\data_handling\matlab_lca\matlab_zolca\db\Ecoinvent - cut-off system model\ecoinvent 3.6_cut-off_ecoSpold02\datasets\" + filenameRef )

%% Get Exchanges
exchangesRef = structRef.ecoSpold.childActivityDataset.flowData.intermediateExchange

%% Get exchangeNames
exchangeNamesRef = strings(length(exchangesRef),1);
for i=1:length(exchangesRef)
   exchangeNamesRef(i) = exchangesRef{i}.name.Text;
end
exchangeNamesRef



%% Search for RefProducts2, Returns Table
RefProducts2 = T(find(strcmp(exchangeNamesRef(1),T.ReferenceProduct)),:)

%% Pick first File
filenameRef2 = string(RefProducts2.Filename(1))

%% Read out File for RefProuct
structRef2 = xml2struct("D:\studium\TUM\BA\CE\data_handling\matlab_lca\matlab_zolca\db\Ecoinvent - cut-off system model\ecoinvent 3.6_cut-off_ecoSpold02\datasets\" + filenameRef2 )

%% Get Exchanges
exchangesRef2 = structRef2.ecoSpold.childActivityDataset.flowData.intermediateExchange

%% Get exchangeNames
exchangeNamesRef2 = strings(length(exchangesRef2),1);
for i=1:length(exchangesRef2)
   exchangeNamesRef2(i) = exchangesRef2{i}.name.Text;
end
exchangeNamesRef2






%% Read out intermediateExchanges
clc 

val = 5;
'name: '
struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.name.Text

'unit: '
struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.unitName.Text

'properties: '
try
    for e = 1: length(struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.property)
        struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.property{1,e}.name.Text
    end
catch end

'classificaiton: '
for e = 1: length(struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.classification)
    struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.classification{1,e}.classificationSystem.Text
    struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.classification{1,e}.classificationValue.Text
end



'Amount:'
struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.Attributes.amount

'inputGroup:'
struct.ecoSpold.childActivityDataset.flowData.intermediateExchange{1, val}.inputGroup.Text



%% compare Cell Array & Table
%Occ = T(find(strcmp('steel milling, small parts',T.ActivityName)),:) % 0.190454
%C = table2cell(T)
tic
index = sum(ismember(C, 'steel milling, small parts'),2)
index = logical(index * ones(1,4))
OccC = C(index)
toc
%OccC = C(sum(ismember(C, 'steel milling, small parts'),2)) % 0.002853 sec
%OccC = C( C{:,2} == 'gold production')
