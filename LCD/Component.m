classdef Component < handle & matlab.mixin.Copyable
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        id string
        name string
        solidName string % can be differ from name if parts contain only one solid
        classification
        %stageNames string
        %stageTypes string
        stages Stage
        material string
        materialGroup string
        surface double
        
        compatibility
        compatibilityStatus double = 1 % can be -1,0,1 == incompatible - possibly incompatible - compatible with assembly
        
        modelGraph = digraph()
        features Feature
        joints Joint
        
        ignore = false
        exchangable = false;      
        
        processParameter %struct with: mass, volume, density, boundingBox, surface, paintMass, screwMass, weldLength, adhesiveMass
        customParameter struct %can be set in Parameter Editor
        
        rates    %with: maintenance, disposal, refurbishment, remnaufacturing, recycling, material, production, assembly, distribution, use;
    end
    
    methods
        %function obj = Component(app,name,material,volume,mass,density,bbox,surface)
        function obj = Component(app,name,material,processParameter)
            obj.id = java.util.UUID.randomUUID.toString;
            obj.name = name;
            obj.solidName = name;
            obj.material= material;
            obj.processParameter = processParameter;
            
            obj.rates.maintenance = 0;
            obj.rates.disposal = 1;
            obj.rates.refurbishment = 0;
            obj.rates.remanufacturing = 0;
            obj.rates.recycling = 0;
            obj.rates.virginMaterial = 1;
            obj.rates.recycledMaterial = 0;
            obj.rates.production = 1 - obj.rates.refurbishment - obj.rates.remanufacturing;
            obj.rates.assembly = 1 - obj.rates.refurbishment;
            obj.rates.distribution = 1;
            obj.rates.use = 1;
            
            obj.processParameter.lifespan.value = 9999;
            
            obj.processParameter.screwMass.value = 0;
            obj.processParameter.weldLength.value = 0;
            obj.processParameter.adhesiveMass.value = 0;
            obj.processParameter.massRemovedMilling.value = 0;
            obj.processParameter.massRemovedTurning.value = 0;
            
            obj.processParameter.mass.dependant = true;
            obj.processParameter.massBy100km.dependant = true;
            obj.processParameter.massBy100km.value = 1;
            obj.processParameter.volume.dependant = false;
            obj.processParameter.density.dependant = false;
            obj.processParameter.boundingBoxX.dependant = true;
            obj.processParameter.boundingBoxY.dependant = true;
            obj.processParameter.boundingBoxZ.dependant = true;
            obj.processParameter.surface.dependant = true;
            obj.processParameter.paintMass.dependant = false;
            obj.processParameter.adhesiveMass.dependant = false;
            obj.processParameter.weldLength.dependant = false;
            obj.processParameter.screwMass.dependant = false;            
            obj.processParameter.lifespan.dependant = false;
            obj.processParameter.massRemovedMilling.dependant  = false;
            obj.processParameter.massRemovedTurning.dependant  = false;
                        
            %obj.processParameter.massRecycling.dependant = true;
            %obj.processParameter.massDisposal.dependant = true;
            %obj.processParameter.massRefurbishment.dependant = true;
            %obj.processParameter.massRemanufacturing.dependant = true;
            %obj.processParameter.massMaintenance.dependant = true;
            
                        
            obj = obj.updateMass();                        
            
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;11,2];
            g = digraph(EL(:,1),EL(:,2));
            obj.modelGraph = g;
            
            for i = 1:length(app.stageIDs)
                obj.stages(i) = Stage(app.stageIDs(i));
                obj.stages(i).parent = obj;
            end            
        end
        
        function obj = displayComponent(obj,app)
            
            %reset axis
            resetplotview(app.UIAxes);
            app.UIAxes.DataAspectRatio = [1 1 1];
            app.UIAxes.Toolbar.Visible = 'off';
            
            
            XData = [20,40,60,80,100,120,100,80,60,120,40];
            YData = [20,20,20,20, 20, 20, 40, 40,40,40,40];            
                       
            
            if ~obj.ignore
                NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;161 208 168;189 205 161;211 200 154;231 193 146; 247 182 137]/255;
                EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;161 208 168;189 205 161;211 200 154;247 182 137]/255;
                EdgeWidth = [obj.rates.virginMaterial,obj.rates.production,obj.rates.assembly,obj.rates.distribution,obj.rates.disposal,obj.rates.maintenance/50,obj.rates.refurbishment,obj.rates.remanufacturing,obj.rates.recycling,obj.rates.maintenance/50,obj.rates.refurbishment,obj.rates.remanufacturing,obj.rates.recycledMaterial] * 5 + 1;
            else
                NodeColors = [200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200]/255;
                EdgeColors = [200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200;200 200 200]/255;
                EdgeWidth = ones(13,1);
            end
            
            
            legend(app.UIAxes,'off')
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',EdgeWidth,'NodeLabel','','ArrowSize',15);
            
            if app.options.displayFlows
                rectangle(app.UIAxes,'Position',[67,10,46,40],'EdgeColor',[227 240 229]/255,'LineWidth',2,'Curvature',.2);
                rectangle(app.UIAxes,'Position',[47,8,68,46],'EdgeColor',[239 240 226]/255,'LineWidth',2,'Curvature',.22);
                rectangle(app.UIAxes,'Position',[13,6,114,52],'EdgeColor',[248 237 223]/255,'LineWidth',2,'Curvature',.24);
                text(app.UIAxes, 90,50.5 ,'product flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [161 208 169]/255, 'FontWeight','normal');
                text(app.UIAxes, 81,54.5 ,'component flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [212 200 154]/255, 'FontWeight','normal');
                text(app.UIAxes, 70,58.5 ,'material flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [231 193 146]/255, 'FontWeight','normal');
            end                       
            
            %display rates
            labeledge(h,1,2,string(obj.rates.virginMaterial*100) + ' %');
            labeledge(h,2,3,string(obj.rates.production*100) + ' %');
            labeledge(h,3,4,string(obj.rates.assembly*100) + ' %');
            labeledge(h,4,5,string(obj.rates.distribution*100) + ' %');
            labeledge(h,5,6,string(obj.rates.disposal*100) + ' %');
            labeledge(h,5,7,string(obj.rates.maintenance) + 'x');
            labeledge(h,5,8,string(obj.rates.refurbishment*100) + ' %');
            labeledge(h,5,9,string(obj.rates.remanufacturing*100) + ' %');
            labeledge(h,5,10,string(obj.rates.recycling*100) + ' %');
            labeledge(h,11,2,string(obj.rates.recycledMaterial*100) + ' %');
            
            h.EdgeLabelColor = EdgeColors;
            h.EdgeFontSize = 11;
            h.EdgeFontAngle = "normal";
            
            % show impacts
            hold(app.UIAxes,"on");
            [~,impacts] = obj.generateLCIA(app);
            col = zeros(length(impacts),3);
            col(impacts > 0,1) = 1; %red
            col(impacts < 0,3) = 1; %blue
            impactsNorm = abs(impacts) / app.getModelImpact * 10000 + 0.001;
            im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm,'PickableParts' , 'none');
            alpha(im,.2)
            hold(app.UIAxes,"off");
            
            %Names
            text(app.UIAxes, h.XData(1:6), h.YData(1:6)-6 ,app.stageNames(1:6),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
            text(app.UIAxes, h.XData(7:11), h.YData(7:11)+5.5 ,app.stageNames(7:11),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
            
            %Classification
            stageClassifications = strings(11,1);
            uniqueClassificationTypes = unique(app.stageClassificationTypes);
            if ~isempty(obj.classification)
                for c = 1:length(uniqueClassificationTypes)
                    stageClassifications(app.stageClassificationTypes == uniqueClassificationTypes(c)) = obj.classification.(uniqueClassificationTypes(c));
                end
            end
            text(app.UIAxes, h.XData(1:6), h.YData(1:6)-4 ,stageClassifications(1:6),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [247 182 137] / 255, 'FontWeight','normal')            
            text(app.UIAxes, h.XData(7:11), h.YData(7:11)+7.5 ,stageClassifications(7:11),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [247 182 137] / 255, 'FontWeight','normal')
            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
            axis(app.UIAxes,"fill")
            disableDefaultInteractivity(app.UIAxes);
                
            %display component configuration in options
            app.DD_MaterialGroup.Items = cellstr(app.materialGroupList);            
            app.DD_MaterialGroup.Value = string(obj.materialGroup);
            app.listMaterials(string(obj.materialGroup));                     
            app.DD_Material.Value = string(obj.material);                                    
            
            app.E_Mass.Value = double(obj.processParameter.mass.value);
            app.E_Volume.Value = double(obj.processParameter.volume.value);
            app.S_LifespanComponent.Value = double(obj.processParameter.lifespan.value);            
            
            
            if ~strcmp(app.classificationType, "none")
                app.DD_Classification.Items = app.classificationList.(app.classificationType){app.materialGroupList == obj.materialGroup};
            else
                app.DD_Classification.Items = {};
                app.DD_Classification.Value = {};
                app.DD_Classification.Enable = false;
            end
            
            if app.options.normTime
                app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + " / yr)";
                text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(app.UIAxes, h.XData(7:11), h.YData(7:11)+3.5 ,string(round(impacts(7:11),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            else
                app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + ")";
                text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(app.UIAxes, h.XData(7:11), h.YData(7:11)+3.5 ,string(round(impacts(7:11),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            end                       
                      
            
            app.mode = 'Component';
            app.BTN_Close.Enable = false;
            app.BTN_Open.Enable = true;                        
            
        end
        
        function [total, vector] = generateLCIA(obj,app)
            if ~obj.ignore
                vector = zeros(length(obj.stages),1);
                total = 0;
                for i = 1:length(obj.stages)
                    impact = obj.stages(i).generateLCIA(app);
                    total = total + impact;
                    vector(i) = impact;
                end
            else
                total = 0;
                vector = zeros(length(obj.stages),1);
            end
        end
        
        function obj = addFeature(obj, feature)
            obj.features = [obj.features feature];
        end
        
        function obj = addJoint(obj, joint)
            obj.joints= [obj.joints joint];
            obj.processParameter.screwMass.value = obj.processParameter.screwMass.value + joint.processParameter.screwMass;
            obj.processParameter.weldLength.value = obj.processParameter.weldLength.value + joint.processParameter.outline;
            obj.processParameter.adhesiveMass.value = obj.processParameter.adhesiveMass.value + joint.processParameter.area*0.33;
            %https://www.weicon.de/media/pdf/79/5c/bb/TDS_10563860_EN_RK-1500_Structural_Acrylic_Adhesive.pdf
            %activator: 30-150 g/m² - adhesive: 180 - 300g/m²  (smooth-rough)
            %durchschnittlich 0.330 kg/m²
        end
        
        function obj = updateMaterialProperties(obj,app)                  
            
            MP = app.materialProperties;            
            obj.processParameter.density.value = MP.Density(MP.Material == obj.material,:);
            
            MGP = app.materialGroupProperties;                        
            obj.processParameter.lifespan.value = MGP.lifespan(MGP.materialGroup == obj.materialGroup,:);                        
            
            RR = app.recyclingRates;
            area = string(RR.Properties.VariableNames(2));
            ratesVector = RR.(area);
            
            obj.rates.recycling = ratesVector(RR.materialGroup == obj.materialGroup,:);                                               
            obj.rates.recycledMaterial = obj.rates.recycling;                                                                            
            obj.rates.virginMaterial = 1- obj.rates.recycling;            
            obj.rates.disposal = 1- obj.rates.recycling;
        end                        
        
        function obj = updateLifespans(obj)
            parentAsm = obj.parent;
            if ~isempty(parentAsm)
                if parentAsm.processParameter.lifespan.value > obj.processParameter.lifespan.value
                    parentAsm.processParameter.lifespan.value = obj.processParameter.lifespan.value;
                    parentAsm.updateLifespans;
                end
            end
        end
        
        function obj = updateMass(obj)            
            obj.processParameter.mass.value = obj.processParameter.volume.value * obj.processParameter.density.value;            
            obj = obj.updateEOL();
        end
        
        function obj = setMaterialGroup(obj,app)         
            disp(obj)
            MP = app.materialProperties;                                
            obj.materialGroup = string(MP.Group(MP.Material == obj.material));                        
        end
        
        
        function obj = assignComponentType(obj,app)                                                            
            obj.setMaterialGroup(app);
            if obj.materialGroup == "None"
               obj.ignore = true;
               return
            end
            
            uniqueClassificationTypes = unique(app.stageClassificationTypes);
            for ct = 1:length(uniqueClassificationTypes)
                classificationType = uniqueClassificationTypes(ct);                                
                conditionsTable = app.conditionTables.(classificationType);
                classificationTable = app.classificationTables.(classificationType);                
                row = classificationTable(classificationTable.materialGroup == obj.materialGroup,:);
                
                if isempty(row)
                    display(obj.material + " was not found");                    
                    obj = obj.setMaterialGroup();
                    row = classificationTable(string(classificationTable.materialGroup) == obj.materialGroup,:);
                end                                
                
                for c = 1:height(conditionsTable)
                    property1 = conditionsTable.property1{c};
                    operator1 = conditionsTable.operator1{c};
                    value1 = conditionsTable.value1{c};
                    connection1 = conditionsTable.connection1{c};
                    property2 = conditionsTable.property2{c};
                    operator2 = conditionsTable.operator2{c};
                    value2 = conditionsTable.value2{c};
                    flag = false;
                    if property1 == "Feature"
                        if operator1 == "is"
                            for i = 1:length(obj.features)
                                if obj.features(i).type == value1
                                    if connection1 == "and"
                                        if property2 == "Feature.value"
                                            if operator2 == "smaller"
                                                if obj.features(i).value < str2double(value2)
                                                    flag = true;
                                                end
                                            end
                                        elseif property2 == "Feature.operation"
                                            if operator2 == "is"
                                                if obj.features(i).operation == value2
                                                    flag = true;
                                                end
                                            end
                                        end
                                    else
                                        flag = true;
                                    end
                                end
                            end
                        end
                    elseif property1 == "JointType"
                        if operator1 == "is"
                            if ~isempty(obj.joints)
                                if obj.joints(1).type == value1
                                    flag = true;
                                end
                            end
                        end
                    elseif property1 == "Else"
                        flag = true;
                    end
                    if flag == true
                        condition = conditionsTable.name{c};
                    end
                end
                                                
                allowance = app.options.allowance;              
                obj.classification.(classificationType) = row.(condition);
                bbvol = getCylinderVolume([obj.processParameter.boundingBoxX.value obj.processParameter.boundingBoxY.value obj.processParameter.boundingBoxZ.value],allowance);
                obj.processParameter.massRemovedTurning.value = bbvol * obj.processParameter.density.value - obj.processParameter.mass.value;
                
                bbvol = obj.processParameter.boundingBoxX.value * obj.processParameter.boundingBoxY.value * obj.processParameter.boundingBoxZ.value * (1 + allowance/100)^3;
                obj.processParameter.massRemovedMilling.value = bbvol * obj.processParameter.density.value - obj.processParameter.mass.value;
            end
            obj = obj.generateStages(app);
        end
        
        
        function obj = generateStages(obj,app)
            obj = obj.updateMass();
            obj.updateMaterialProperties(app);                
            
            uniqueClassificationTypes = unique(app.stageClassificationTypes);
            for c = 1:length(uniqueClassificationTypes)
                % uses own data types
                %config = app.configList.getConfig(obj.material,obj.classification.(uniqueClassificationTypes(c)));
                % uses tables: way faster                                                
                config = getConfig(app,obj.materialGroup,obj.classification.(uniqueClassificationTypes(c)));                
                for s = 1:length(config.stages)                   
                    stage = Stage(config.stages(s).name);                                        
                    stage.rate = obj.rates.(stage.name);                    
                    %obj.stages(s) = stage;                    
                    %stage.parent = obj;
                    obj.setStage(stage);
                    for o = 1:length(config.stages(s).operations)
                        op = Operation(config.stages(s).operations(o).name);
                        stage.addOperation(op);
                        for p = 1:length(config.stages(s).operations(o).processes)
                            proConfig = config.stages(s).operations(o).processes(p);
                            %get from stack (and create if non existent)
                            pro = app.processEngine.getProcess(app,proConfig.activityName,proConfig.loc,proConfig.refProduct);
                            op.addProcess(pro);
                            pro.correction = proConfig.correction;
                            pro.functionalUnit = proConfig.parameter;                            
                            if proConfig.parameter == 'input'
                                pro.quantity = 0;
                                pro.quantityExpression = 0;
                            else
                                %pro.quantity = obj.processParameter.(proConfig.parameter).value;                                
                                pro.quantityExpression = proConfig.parameter;                                
                                pro.quantity = parseQuantity(pro);                                
                            end
                            for a = 1:length(proConfig.alternativeProcesses)
                                altpro = proConfig.alternativeProcesses(a);
                                ecoAltPro = app.processEngine.getProcess(app,altpro.activityName,altpro.loc,altpro.refProduct);
                                ecoAltPro.parent = op;
                                pro.alternativeProcesses = [pro.alternativeProcesses ecoAltPro];
                            end                            
                        end                        
                    end
                    %%obj = obj.setStage(stage);
                end
            end
        end
        
        
        function obj = setStage(obj, stage)
            for i = 1:length(obj.stages)
                if obj.stages(i).name == stage.name
                    obj.stages(i) = stage;
                    stage.parent = obj;
                    return
                end
            end
            obj = obj.addStage(stage);
        end
        
        function obj = addStage(obj, stage)
            stage.parent = obj;
            obj.stages = [obj.stages stage];
            %obj.stageNames = [obj.stageNames, stage.name];
        end
        
        function obj = updateEOL(obj)
            %obj.processParameter.massDisposal.value = obj.rates.disposal * obj.processParameter.mass.value * -1;
            %obj.processParameter.massMaintenance.value = obj.rates.maintenance * obj.processParameter.mass.value * -1;
            %obj.processParameter.massRefurbishment.value = obj.rates.refurbishment * obj.processParameter.mass.value * -1;
            %obj.processParameter.massRemanufacturing.value = obj.rates.remanufacturing * obj.processParameter.mass.value * -1;
            %obj.processParameter.massRecycling.value = obj.rates.recycling * obj.processParameter.mass.value * -1;
        end
        
        
    end
    
    
end

