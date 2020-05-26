function [asm] = I_Assembly2Assembly(i_asm)
% I_Assembly2Assembly restructures imported Assembly
% Removes empty Parts, combines Parts with one Solid, Establishes
% Assemblies with more than one 

    asm = Assembly(i_asm.name);    
    asm = Iterate(asm, i_asm);
       
    function parent = Iterate(parent,iparent)
        for j = 1:length(iparent.solids)     
            s = iparent.solids(j);
            ob = Component(s.name,s.material,s.volume);            
            parent = parent.addComponent(ob);            
        end
        for j = 1:length(iparent.parts)            
            if iparent.parts(j).getChildrenCount > 1 
                ob = Assembly(iparent.parts(j).name);                
                ob = Iterate(ob, iparent.parts(j));
                parent = parent.addAssembly(ob);                            
            elseif iparent.parts(j).getChildrenCount == 1                 
                s = iparent.parts(j);
                ob = Component(s.name,s.material,s.volume);
                parent = parent.addComponent(ob);            
            end        
        end        
    end
end



%
% if isa(obj,'Assembly')
%                 AsmParent = AsmParent.addAssembly(obj);                
%             end