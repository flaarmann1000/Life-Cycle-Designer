function updateModel(app)

import=xml2struct([app.options.exchangeFilePath 'exchange.xml']);
I_asm = struct2I_Assembly(import);
asm = I_Assembly2Assembly(app,I_asm,false);
activeAsm = app.model.root;

h = waitbar(0.2,"Comparing Assemblies...");
compareAsm(asm,activeAsm);

waitbar(0.8,h,"Comparing Assemblies...");
app.TV_Components.Children.delete;
activeAsm.displayAssemblyTree(app,app.CB_ShowFeatures.Value)
expand(app.TV_Components,'all');
activeAsm.plot(app);

app.setTVSelection();

close(h);

    function compareAsm(asm,activeAsm)
        for c = 1:length(asm.components)
            found = 0;
            for i = 1:length(activeAsm.components)
                if asm.components(c).name == activeAsm.components(i).name
                    updateComponent(asm.components(c),activeAsm.components(i));
                    found = 1;
                    break
                end
            end
            if found == 0
                createComponent(asm.components(c),activeAsm);
            end
        end
        for a = 1:length(asm.assemblies)
            found = 0;
            for i = 1:length(activeAsm.assemblies)
                if asm.assemblies(a).name == activeAsm.assemblies(i).name
                    compareAsm(asm.assemblies(a),activeAsm.assemblies(i));
                    found = 1;
                    break
                end
                
            end
            if found == 0
                createAssembly(asm.assemblies(a),activeAsm);
            end
        end
    end


    function updateComponent(com,activeCom)
        if ~strcmp(com.material,activeCom.material)
            %classificationType = app.classificationTypes(1);
            %classificationTable = readtable('tables/'+classificationType+'_classification.xlsx','sheet','classification');
            %matNew = classificationTable(classificationTable.material == com.material,:);
            
            %classTable = app.classificationTables.(app.stageClassificationTypes(1));
            %matNew = classTable(classTable.material == com.material,:);
            
            matNew = app.materialProperties(app.materialProperties.Material == com.material,:);
            
            %if ~(isempty(matNew) && strcmp('Plastic - Glossy (Black)',activeCom.material)) % dont refresh if default material was applied
            if ~(isempty(matNew))
                disp("material-change: " + com.material);
                activeCom.material = com.material;
                if matNew.Group ~= 'None'
                    activeCom.assignComponentType(app);
                    activeCom.generateStages(app);
                else
                    activeCom.ignore = true;
                end
            end
        end
        if ~isequal(activeCom.processParameter , com.processParameter)
            activeCom.processParameter = com.processParameter;
            activeCom.updateMaterialProperties(app);
            activeCom.updateMass();
        end
    end

    function createComponent(com,activeAsm)
        com = com.assignComponentType(app);
        %com = com.updateDensity();
        %com = com.updateMass();
        activeAsm.components = [activeAsm.components com];
    end

    function createAssembly(asm, activeAsm)
        newAsm = Assembly(asm.name);
        for a = 1:length(asm.assemblies)
            createAssembly(asm.assemblies(a),newAsm);
        end
        for c = 1:length(asm.components)
            createComponent(asm.components(c),newAsm);
        end
        activeAsm.addAssembly(newAsm);
    end
end