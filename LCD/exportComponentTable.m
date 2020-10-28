
function exportComponentTable(root)

compTable = table();
classiTable = table();
iterate(root);

writetable(compTable,"componentTable.xlsx");
writetable(classiTable,"classificationTable.xlsx");

    function iterate(asm)
        for i =1:length(asm.components)
            Name = asm.components(i).name;
            Baugruppe = asm.name;
            Material = asm.components(i).material;
            Volumen = asm.components(i).processParameter.volume.value;
            Masse = asm.components(i).processParameter.mass.value;
            Dichte = asm.components(i).processParameter.density.value;
            row = table(Name, Baugruppe, Material, Volumen, Dichte, Masse);
            compTable = [compTable; row];    
            if ~isempty(asm.components(i).classification)
                Production = asm.components(i).classification.production;
                Assembly = asm.components(i).classification.assembly;
                Use = asm.components(i).classification.use;
                Eol = asm.components(i).classification.eol;
            else
               Production = "-";
               Assembly = "-";
               Use = "-";
               Eol = "-";
            end
            row = table(Name, Production, Assembly, Use, Eol);
            classiTable = [classiTable; row];            
        end
        
        for a = 1:length(asm.assemblies)
           iterate(asm.assemblies(a));
        end
        
    end

end