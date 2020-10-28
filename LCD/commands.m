%% set all remanufacturing rates to 100%

clc
iterate(app.model.root);

batchResults(app)

function iterate(asm)
for a = 1:length(asm.assemblies)
    iterate(asm.assemblies(a));
    setRates(asm.assemblies(a));
end
end

function setRates(asm)
for c = 1:length(asm.components)
    asm.components(c).rates.recycling = 0;
    asm.components(c).rates.disposal = 0;    
    asm.components(c).rates.remanufacturing = 1;
    asm.components(c).rates.assembly = 1;
    asm.components(c).rates.production = 0;
end
end




 