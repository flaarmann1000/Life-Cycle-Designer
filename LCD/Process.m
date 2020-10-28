classdef Process < handle & matlab.mixin.Copyable & matlab.mixin.Heterogeneous
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        graph % visualisation
        
    end
    
    methods
        function impact = generateLCIA(obj,app)
            disp("can't calculate generic process lcia");
            impact = 0;
        end
        
        function plot(obj,app,axes)
            disp("can't display generic process");
        end
        
        function rateEff = getRateEff(obj,app)
            com = obj.parent.parent.parent;
            stageName = obj.parent.parent.name;
            stageRate = com.rates.(stageName);
            
            if com.exchangable
                recircles = floor((app.options.referenceTime - 0.001 )/ com.processParameter.lifespan.value);
            else
                recircles = floor((app.options.referenceTime - 0.001 )/ app.model.root.processParameter.lifespan.value);
            end
            
            if app.options.transient
                switch stageName
                    case 'virginMaterial'
                        productionRate = com.rates.production;
                        rateEff = stageRate*(1 + recircles*productionRate);
                    case 'recycledMaterial'
                        productionRate = com.rates.production;
                        rateEff = stageRate*(1 + recircles*productionRate);
                    case 'production'
                        rateEff = 1 + stageRate*recircles;
                    case 'assembly'
                        rateEff = 1 + stageRate*recircles;
                    case 'distribution'
                        rateEff = 1 + stageRate*recircles;
                    case 'use'
                        rateEff = app.options.referenceTime / com.processParameter.lifespan.value;
                    case 'disposal'
                        rateEff = stageRate*(recircles + 1);
                    case 'maintenance'
                        rateEff = stageRate * app.options.referenceTime / com.processParameter.lifespan.value;
                    case 'refurbishment'
                        rateEff = stageRate*(recircles + 1);
                    case 'remanufacturing'
                        rateEff = stageRate*(recircles + 1);
                    case 'recycling'
                        rateEff = stageRate*(recircles + 1);
                end
            else
                switch stageName
                    case 'virginMaterial'
                        productionRate = com.rates.production;
                        rateEff = stageRate*(1 + recircles)*productionRate;
                    case 'recycledMaterial'
                        productionRate = com.rates.production;
                        rateEff = stageRate*(1 + recircles)*productionRate;
                    case 'production'
                        rateEff = stageRate*(recircles+1);
                    case 'assembly'
                        rateEff = stageRate*(recircles+1);
                    case 'distribution'
                        rateEff = stageRate*(recircles+1);
                    case 'use'
                        rateEff = app.options.referenceTime / com.processParameter.lifespan.value;
                    case 'disposal'
                        rateEff = stageRate*(recircles + 1);
                    case 'maintenance'
                        rateEff = stageRate * app.options.referenceTime / com.processParameter.lifespan.value;
                    case 'refurbishment'
                        rateEff = stageRate*(recircles + 1);
                    case 'remanufacturing'
                        rateEff = stageRate*(recircles + 1);
                    case 'recycling'
                        rateEff = stageRate*(recircles + 1);
                end
            end
        end
        
    end
    
end

