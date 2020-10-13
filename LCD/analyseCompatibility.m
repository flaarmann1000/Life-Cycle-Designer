function analyseCompatibility(app, asm)

materialGroup = strings(length(asm.components),1);


for c = 1:length(asm.components)
    materialGroup(c) = asm.components(c).materialGroup;
end

for c = 1:length(asm.components)
    asm.components(c).compatibility = [];    
    row = app.compatibility(app.compatibility.materialGroup == asm.components(c).materialGroup,:);    
    asm.components(c).compatibilityStatus = 1;
    for i = 1:length(asm.components)
        asm.components(c).compatibility(i).component = asm.components(i);
        asm.components(c).compatibility(i).value = row.(asm.components(i).materialGroup);
        if (asm.components(c).materialGroup ~= "None")
            setStatus(asm.components(c),asm.components(c).compatibility(i).value);
        end
    end
    asm.components(c).compatibility(c) = [];
    
    for a = 1:length(asm.assemblies)
        analyseCompatibility(app,asm.assemblies(a));
    end
end

    function setStatus(com,compa)
        if compa >= 0.9
            if com.compatibilityStatus == 1
                newStatus = 1;
            else
                newStatus = com.compatibilityStatus;
            end
        elseif isnan(compa)
            if com.compatibilityStatus ~= -1
                newStatus = 0;
            else
                newStatus = com.compatibilityStatus;
            end
        else
            newStatus = -1;
        end
        
        if newStatus == 1
            M = app.recyclingRates;
            area = string(M.Properties.VariableNames(2));
            ratesVector = M.(area);
            com.rates.recycling = ratesVector(M.materialGroup == com.materialGroup,:);
        else
            if string(com.classification.assembly) == 'adhesive'
                com.rates.recycling = 0;
            else
                M = app.recyclingRates;
                area = string(M.Properties.VariableNames(2));
                ratesVector = M.(area);
                com.rates.recycling = ratesVector(M.materialGroup == com.materialGroup,:);
            end
        end
        com.rates.disposal = 1- com.rates.recycling - com.rates.remanufacturing - com.rates.refurbishment;                
        com.rates.virginMaterial = com.rates.production * (1-com.rates.recycling);
        com.rates.recycledMaterial = com.rates.production * com.rates.recycling;
        com.compatibilityStatus = newStatus;
        
    end


end