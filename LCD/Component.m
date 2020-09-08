    classdef Component
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        solidName string % can be differ from name if parts contain only one solid        
        classification
        stageNames string
        stageTypes string
        stages Stage
        material string
        surface double
        density double
        mass double
        boundingBox        
        %mass double
        volume double
        modelGraph = digraph()
        features Feature
        joints Joint
        processParameter %struct with: mass, volume, density, boundingBox, surface, paintMass, screwMass, weldLength, adhesiveMass
        
        rates        
    end
    
    methods
        %function obj = Component(app,name,material,volume,mass,density,bbox,surface)
        function obj = Component(app,name,material,processParameter)                       
            obj.id = java.util.UUID.randomUUID.toString;
            obj.name = name;
            obj.solidName = name;
            obj.material= material;
            obj.processParameter = processParameter;            
                         
            obj.rates.maintenance = 0.5;   
            obj.rates.disposal = 0.3;
            obj.rates.refurbishment = 0.3;
            obj.rates.remanufacturing = 0.2;
            obj.rates.recycling = 0.2;        
            obj.rates.material = 1 - obj.rates.refurbishment - obj.rates.remanufacturing - obj.rates.recycling;
            obj.rates.production = 1 - obj.rates.refurbishment - obj.rates.remanufacturing;
            obj.rates.assembly = 1 - obj.rates.refurbishment;
            obj.rates.distribution = 1;
            obj.rates.use = 1;     
            
            obj.processParameter.screwMass.value = 0;             
            obj.processParameter.weldLength.value = 0;            
            obj.processParameter.adhesiveMass.value = 0;
            
            obj.processParameter.mass.dependant = true;
            obj.processParameter.volume.dependant = false;
            obj.processParameter.density.dependant = false;
            obj.processParameter.boundingBox.dependant = true;
            obj.processParameter.surface.dependant = true;
            obj.processParameter.paintMass.dependant = false;                
            obj.processParameter.adhesiveMass.dependant = false;
            obj.processParameter.weldLength.dependant = false;
            obj.processParameter.screwMass.dependant = false;                        
            obj.processParameter.massBy100km.dependant  = true;
            obj.processParameter.massRemovedMilling.dependant  = false;
            obj.processParameter.massRemovedTurning.dependant  = false;
            obj.processParameter.massRecycling.dependant = true;
            obj.processParameter.massDisposal.dependant = true;
            obj.processParameter.massRefurbishment.dependant = true;
            obj.processParameter.massRemanufacturing.dependant = true;
            obj.processParameter.massMaintenance.dependant = true;
            
            obj = obj.updateMass();

            obj.stageNames = ["material","production","assembly","distribution","use","disposal","maintenance","refurbishment","remanufacturing","recycling"];
                      
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;10 2];            
            g = digraph(EL(:,1),EL(:,2));            
            obj.modelGraph = g;  
            
             for i = 1:length(obj.stageNames)
                 obj.stages(i) = Stage(obj.stageNames(i));
             end           
        
        end
        
        function obj = displayComponent(obj,app)                             
            
            XData = [20,40,60,80,100,120,100,80,60,40];
            YData = [20,20,20,20, 20, 20, 40,40,40,40];
            NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;                                              
            EdgeWidth = [obj.rates.material,obj.rates.production,obj.rates.assembly,obj.rates.distribution,obj.rates.disposal,obj.rates.maintenance,obj.rates.refurbishment,obj.rates.remanufacturing,obj.rates.recycling,obj.rates.maintenance,obj.rates.refurbishment,obj.rates.remanufacturing,obj.rates.recycling] * 5 + 1;
            
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',EdgeWidth,'NodeLabel','','ArrowSize',15);                                                                                      
            
            % show impacts
            hold(app.UIAxes,"on");
            [~,impacts] = obj.generateLCIA(app);                              
            col = zeros(length(impacts),3);            
            col(impacts > 0,1) = 1; %red
            col(impacts < 0,3) = 1; %blue
            impactsNorm = abs(impacts) / app.modelImpact * 10000 + 0.001;
            im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm,'PickableParts' , 'none');            
            alpha(im,.2)
            hold(app.UIAxes,"off");
            %text(app.UIAxes, h.XData, h.YData-2.4 ,string(impacts),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, 'Color', [.8 .6 .6], 'FontWeight','normal')                                                                           
            
            text(app.UIAxes, h.XData, h.YData-1.6 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')   
            text(app.UIAxes, h.XData, h.YData-2.2 ,string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking                                    
            resetplotview(app.UIAxes);
            
            app.DD_Material.Items = cellstr(app.materialList);
            if ~isempty(app.classificationType)
                app.DD_Classification.Items = app.classificationList.(app.classificationType){app.materialList == obj.material};                
            else
                app.DD_Classification.Items = {};
                app.DD_Classification.Value = {};
                app.DD_Classification.Enable = false;
            end
            app.mode = 'LCModel';
            app.BTN_Close.Enable = false;
            app.BTN_Open.Enable = true;
            
            app.E_Mass.Value = double(obj.processParameter.mass.value);
            app.E_Volume.Value = double(obj.processParameter.volume.value);
            
        end     
        
        function [total, vector] = generateLCIA(obj,app)
            vector = zeros(length(obj.stages),1);            
            total = 0;
            for i = 1:length(obj.stages)
                impact = obj.stages(i).generateLCIA(app);
                total = total + impact;
                vector(i) = impact;
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
        
        function obj = updateDensity(obj)
            M = readtable("tables/material_properties.xlsx");       
            obj.processParameter.density.value = M.density(M.material == obj.material,:);
        end
        
        function obj = updateMass(obj)                             
            obj.processParameter.mass.value = obj.processParameter.volume.value * obj.processParameter.density.value;
            obj.processParameter.massBy100km.value = obj.processParameter.mass.value / 1000 * 100;
            obj = obj.updateEOL();
        end
        
        function obj = assignComponentType(obj,app)                                          
            
            for ct = 1:length(app.classificationTypes)
                classificationType = app.classificationTypes(ct);            
            
                conditionsTable = readtable('tables/'+classificationType+'_classification.xlsx','sheet','conditions');
                classificationTable = readtable('tables/'+classificationType+'_classification.xlsx','sheet','classification');            
                row = classificationTable(classificationTable.material == obj.material,:);

                if isempty(row)
                   display(obj.material + " was not found");
                   obj.material = "Plastic - Glossy (Black)";
                   row = classificationTable(classificationTable.material == obj.material,:);               
                end 
                
                obj = obj.updateDensity();
                obj = obj.updateMass();                

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

                obj.classification.(classificationType) = row.(condition);                 
                bbvol = getCylinderVolume(obj.processParameter.boundingBox.value);
                obj.processParameter.massRemovedTurning.value = bbvol * obj.processParameter.density.value - obj.processParameter.mass.value;
                bbvol = obj.processParameter.boundingBox.value(1) * obj.processParameter.boundingBox.value(2) * obj.processParameter.boundingBox.value(3) * 1.05^3; % 5% machining allowance added
                obj.processParameter.massRemovedMilling.value = bbvol * obj.processParameter.density.value - obj.processParameter.mass.value;                
            end
            obj = obj.generateStages(app);
        end                
       
        
        function obj = generateStages(obj,app)  
            obj = obj.updateMass();
                        
            for c = 1:length(app.classificationTypes)                
                % uses own data types
                %config = app.configList.getConfig(obj.material,obj.classification.(app.classificationTypes(c)));
                % uses tables: way faster
                config = getConfig(app,obj.material,obj.classification.(app.classificationTypes(c)));
                for s = 1:length(config.stages)
                    stage = Stage(config.stages(s).name);
                    stage.rate = obj.rates.(stage.name);
                    for o = 1:length(config.stages(s).operations)
                        op = Operation(config.stages(s).operations(o).name);
                        for p = 1:length(config.stages(s).operations(o).processes)
                            proConfig = config.stages(s).operations(o).processes(p);
                            %get from stack (and create if non existent)                        
                            pro = app.processEngine.getProcess(app,proConfig.activityName,proConfig.loc,proConfig.refProduct);
                            pro.correction = proConfig.correction;
                            pro.functionalUnit = proConfig.parameter;
                            %pro.stageId = stage.id;
                            pro.rate = stage.rate;
                            %create from scratch
                            %pro = EcoinventProcess(app,proConfig.activityName,proConfig.loc,proConfig.refProduct);                          
                            if proConfig.parameter == 'input'
                                pro.quantity = 0;
                            else                                
                                pro.quantity = obj.processParameter.(proConfig.parameter).value;                            
                            end                            
                            for a = 1:length(proConfig.alternativeProcesses)
                                altpro = proConfig.alternativeProcesses(a);                                
                                pro.alternativeProcesses = [pro.alternativeProcesses app.processEngine.getProcess(app,altpro.activityName,altpro.loc,altpro.refProduct)];
                            end
                            op = op.addProcess(pro);
                        end
                        stage = stage.addOperation(op);
                    end
                    obj = obj.setStage(stage);
                end
            end
        end
            
        
        function obj = setStage(obj, stage)
           for i = 1:length(obj.stages)              
              if obj.stages(i).name == stage.name                 
                 obj.stages(i) = stage;
                 return
              end             
           end
           obj = obj.addStage(stage);
        end
        
        function obj = addStage(obj, stage)            
            obj.stages = [obj.stages stage];
            obj.stageNames = [obj.stageNames, stage.name];
        end
        
        function obj = updateEOL(obj)            
           obj.processParameter.massDisposal.value = obj.rates.disposal * obj.processParameter.mass.value * -1;
           obj.processParameter.massMaintenance.value = obj.rates.maintenance * obj.processParameter.mass.value * -1;
           obj.processParameter.massRefurbishment.value = obj.rates.refurbishment * obj.processParameter.mass.value * -1;
           obj.processParameter.massRemanufacturing.value = obj.rates.remanufacturing * obj.processParameter.mass.value * -1;                           
           obj.processParameter.massRecycling.value = obj.rates.recycling * obj.processParameter.mass.value * -1;                      
        end           
        
    end
    
     
end

