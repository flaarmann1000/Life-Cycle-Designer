function copyAsm = deepCopy(app,asm)
copyAsm = Assembly(asm.name);
copyAsmProps(asm,copyAsm);
iterateAsm(copyAsm,asm);
iterateCom(copyAsm,asm);

    function copyAsmProps(asm, newAsm)
        newAsm.id = asm.id;
        newAsm.ignore = asm.ignore;
        newAsm.processParameter = asm.processParameter;
        newAsm.exchangable = asm.exchangable;        
    end

    function iterateAsm(copyparent,parent)
        for a = 1:length(parent.assemblies)
            tmpAsm = Assembly(parent.assemblies(a).name);
            copyAsmProps(parent.assemblies(a),tmpAsm);
            tmpAsm.parent = copyparent;
            copyparent.assemblies = [copyparent.assemblies tmpAsm];
            iterateAsm(tmpAsm,parent.assemblies(a));
            iterateCom(tmpAsm,parent.assemblies(a));
        end
    end

    function iterateCom(copyAsm, realAsm)
        for c = 1:length(realAsm.components)
            realCom = realAsm.components(c);            
            tmpCom = Component(app,realCom.name,realCom.material,realCom.processParameter);
            tmpCom.stages = Stage.empty();
            tmpCom.parent = copyAsm;
            copyAsm.components = [copyAsm.components tmpCom];
            copyComProps(tmpCom,realCom);
            for s = 1:length(realAsm.components(c).stages)
                tmpStage = Stage(realAsm.components(c).stages(s).name);
                tmpStage.parent = tmpCom;
                tmpCom.stages = [tmpCom.stages tmpStage];
                for o = 1:length(realAsm.components(c).stages(s).operations)
                    tmpOp = Operation(realAsm.components(c).stages(s).operations(o).name);
                    tmpOp.parent = tmpStage;
                    tmpStage.operations = [tmpStage.operations tmpOp];
                    for p = 1:length(realAsm.components(c).stages(s).operations(o).processes)                        
                        tmpPro = copy(realAsm.components(c).stages(s).operations(o).processes(p));
                        tmpPro.parent = tmpOp;
                        tmpOp.processes = [tmpOp.processes tmpPro];
                    end
                end
            end
        end
    end

    function copyComProps(copyCom, realCom)        
        copyCom.id = realCom.id;
        copyCom.solidName = realCom.solidName;
        copyCom.classification = realCom.classification;
        copyCom.solidName = realCom.solidName;
        copyCom.materialGroup = realCom.materialGroup;
        copyCom.compatibility = realCom.compatibility;
        copyCom.compatibilityStatus = realCom.compatibilityStatus;
        copyCom.features = realCom.features;
        copyCom.joints = realCom.joints;
        copyCom.ignore = realCom.ignore;
        copyCom.exchangable = realCom.exchangable;
        copyCom.processParameter = realCom.processParameter;
        copyCom.customParameter = realCom.customParameter;
        copyCom.rates = realCom.rates;        
    end
end