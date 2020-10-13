function resTable = asmSensitivity(app, asm)

w = waitbar(0,"simulating parameter change");
resTable = table();
scanAsm(asm);
delete(w);

    function scanAsm(assembly)
        for c = 1:length(assembly.components)            
            waitbar(0.2,w,assembly.components(c).name);            
            [sensitivity , indiParameters] = analyseSensitivity(app, assembly.components(c), asm);
            componentName = strings(length(sensitivity),1);            
            componentName(:) = assembly.components(c).name;
            addTable = table(componentName, indiParameters,sensitivity);
            resTable = [resTable; addTable];
        end
        for a = 1: length(assembly.assemblies)
            scanAsm(assembly.assemblies(a));
        end
    end


end