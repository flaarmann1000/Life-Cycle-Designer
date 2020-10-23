function xlsxExport(app)

bomTable = table();
asm = app.model.root;
printComs(asm);
iterate(asm);
%disp(bomTable);
writetable(bomTable,"xlsBom.xlsx");


function iterate(asm)
    for a = 1:length(asm.assemblies)
       printComs(asm.assemblies(a));
    end
end

function printComs(asm)
    for c = 1:length(asm.components)
        component = (asm.components(c).name);
        material = (asm.components(c).material);
        weight = (asm.components(c).processParameter.mass.value);
        if asm.components(c).exchangable
            exchangable = "yes";
        else
            exchangable = "no";
        end
        assembly = asm.name;
        if ~isempty(asm.parent)
            assemblyParent = asm.parent.name;
        else
            assemblyParent = asm.name;
        end
        row = table(assemblyParent, assembly, component, exchangable, material, weight);
        bomTable = [bomTable; row];
    end
end

end