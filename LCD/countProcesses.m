function count = countProcesses(asm)

count = 0;

runComponents(asm);
iterate(asm);



    function iterate(asm)
        for a = 1:length(asm.assemblies)
            runComponents(asm.assemblies(a));
            iterate(asm.assemblies(a));
        end
    end

    function runComponents(asm)
        for c = 1:length(asm.components)
            for s = 1:length(asm.components(c).stages)
                for o = 1:length(asm.components(c).stages(s).operations)
                    count = count + length(asm.components(c).stages(s).operations(o).processes);
                end
            end
        end
    end


end

