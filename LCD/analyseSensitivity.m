function [sensitivity , indiParameters] = analyseSensitivity(app, obj, refobj)

referenceImpact = refobj.generateLCIA(app);

%get only independant parameters
processParameters = string(fieldnames(obj.processParameter));
indiParameters = [];
for i = 1:length(processParameters)
    if (obj.processParameter.(processParameters(i)).dependant == false)
        indiParameters = [indiParameters; processParameters(i)] ;
    end
end

sensitivity = zeros(length(indiParameters),1);
referenceParameter = obj.processParameter;

% process parameter
for i = 1:length(indiParameters)    
    obj.processParameter = referenceParameter;
    obj.processParameter.(indiParameters(i)).value = referenceParameter.(indiParameters(i)).value * 1.1;
    obj.updateMass();
    sensitivity(i) = refobj.generateLCIA(app) / referenceImpact * 100 - 100;
end
rateNames = ["recycledMaterial","remanufacturing","refurbishment"];
obj.processParameter = referenceParameter;
obj.updateMass();

%rates
referenceRates = obj.rates;
num = length(indiParameters);
for i = 1:length(rateNames)    
    indiParameters = [indiParameters; rateNames(i)] ;
    obj.rates = referenceRates;
    obj.rates.(rateNames(i)) = min(obj.rates.(rateNames(i)) + 0.1 ,1);
    obj.rates.disposal = 1 - obj.rates.recycling - obj.rates.refurbishment - obj.rates.remanufacturing;
    obj.rates.material = 1 - obj.rates.recycling - obj.rates.refurbishment - obj.rates.remanufacturing;
    obj.rates.production = 1 - obj.rates.refurbishment - obj.rates.remanufacturing;
    obj.rates.assembly = 1 - obj.rates.refurbishment;
    sensitivity(num+i) = abs(refobj.generateLCIA(app) / referenceImpact * 100 - 100);
end
obj.rates = referenceRates;

%custom parameter
customParameterNames = string(fieldnames(obj.customParameter));
if ~isempty(customParameterNames)
    customSensitivity = zeros(length(customParameterNames),1);
    for i = 1:length(customParameterNames)        
        current = obj.customParameter.(customParameterNames(i)).value;        
        obj.customParameter.(customParameterNames(i)).value = current * 1.1;
        customSensitivity(i) = abs(refobj.generateLCIA(app) / referenceImpact * 100 - 100);
        obj.customParameter.(customParameterNames(i)).value = current;
    end
    sensitivity = [sensitivity; customSensitivity];
end
indiParameters = [indiParameters; customParameterNames];