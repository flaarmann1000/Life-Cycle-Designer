%% 

path = 'C:\Users\Z420\Desktop\exchange_folder\F-BOM.xml';
c=xml2struct(path); 


%%



%G = addnode(G,'asm')
%G = addedge(G,'asm','part')




G = digraph
asmName = c.assembly.Attributes.name
G = addnode(G,asmName)


plot(G)


function [res] = addNode()

end

