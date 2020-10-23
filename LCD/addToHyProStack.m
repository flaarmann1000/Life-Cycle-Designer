function stack = addToHyProStack(stack,hyPro,replace)
    for i = 1:length(stack)
        if stack(i).name == hyPro.name
           if replace
               stack(i) = hyPro;
           end
           return
        end
    end
    stack = [stack; hyPro];
end