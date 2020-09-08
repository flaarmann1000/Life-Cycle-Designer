classdef Assembly
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        assemblyType string
        components Component
        assemblies Assembly
        modelGraph
        stageNames 
    end
    
    methods
        function obj = Assembly(name)            
            obj.name = name;
            obj.id = java.util.UUID.randomUUID.toString;
            
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;10 2];            
            g = digraph(EL(:,1),EL(:,2));            
            obj.modelGraph = g; 
            obj.stageNames = ["material","production","assembly","distribution","use","disposal","maintenance","refurbishment","remanufacturing","recycling"];
        end
        
        function obj = addComponent(obj, com)
           obj.components(length(obj.components)+1) = com;
        end
        
        function obj = addAssembly(obj, asm)
           obj.assemblies(length(obj.assemblies)+1) = asm;
        end
        
        function el = getElementByName(obj,str)
            el = 0;
            if obj.name == string(str)
                el = obj;
            else                
                search(obj);                                    
            end
            
            function search(asm)                
                for i = 1:length(asm.components)
                   if asm.components(i).name == string(str)
                      el = asm.components(i);
                      break
                   end
                end
                for i = 1:length(asm.assemblies)
                    if asm.assemblies(i).name == string(str)
                        el = asm.assemblies(i);
                    else
                        search(asm.assemblies(i));
                   end
                end
            end            
        end
        
        function el = getElementById(obj,id)
            el = 0;
            if obj.id == string(id)
                el = obj;
            else                
                search(obj);                                    
            end
            
            function search(asm)                
                for i = 1:length(asm.components)
                   if asm.components(i).id == string(id)
                      el = asm.components(i);
                      return
                   end
                end
                for i = 1:length(asm.assemblies)
                    if asm.assemblies(i).id == string(id)
                        el = asm.assemblies(i);
                        return
                    else
                        search(asm.assemblies(i));
                   end
                end
            end            
        end
        
        function displayAssemblyTree(asm,tree)            
        %displays Assembly in TreeView

            NodeData.name = asm.name;
            NodeData.id = asm.id;
            root = uitreenode(tree,'Text',asm.name,'NodeData',NodeData, "Icon", "res\asm.png");            
            iterate(root,asm)            

            function iterate(parent,obj)
                for i = 1:length(obj.components)
                    NodeData.name = obj.components(i).name;
                    NodeData.material= obj.components(i).material;
                    %NodeData.mass = obj.components(i).mass;
                    NodeData.volume = obj.components(i).volume;
                    NodeData.id = obj.components(i).id;                                        
                    NodeData.classification = obj.components(i).classification;
                    c = uitreenode(parent,'Text',obj.components(i).name,'NodeData',NodeData, "Icon", "res\part.png");
                    for j = 1:length(obj.components(i).features)
                        fNodeData.name = obj.components(i).features(j).name;                      
                        fNodeData.id = obj.components(i).features(j).id;                                        
                        uitreenode(c,'Text',fNodeData.name ,'NodeData',fNodeData, "Icon", "res\feature.png");                    
                    end
                    for j = 1:length(obj.components(i).joints)
                        fNodeData.name = obj.components(i).joints(j).name;                      
                        fNodeData.id = obj.components(i).joints(j).id;                                        
                        uitreenode(c,'Text',fNodeData.name ,'NodeData',fNodeData, "Icon", "res\joint.png");                    
                    end
                end                
                for i = 1:length(obj.assemblies)
                    NodeData.name = obj.assemblies(i).name;
                    NodeData.id= obj.assemblies(i).id;
                    p = uitreenode(parent,'Text',obj.assemblies(i).name,'NodeData',NodeData, "Icon", "res\asm.png");
                    iterate(p,obj.assemblies(i));
                end
            end
        end        
        
        function obj = displayAssembly(obj,app)                                   
            
            XData = [20,40,60,80,100,120,100,80,60,40];
            YData = [20,20,20,20, 20, 20, 40,40,40,40];
            NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
            EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;                                              
            
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',2,'NodeLabel','','ArrowSize',15);                                                                                      
            
            % show impacts
            hold(app.UIAxes,"on");
             [~,impacts] = obj.generateLCIA(app);     
            col = zeros(length(impacts),3);            
            col(impacts > 0,1) = 1;
            col(impacts < 0,3) = 1;
            impactsNorm = abs(impacts) / app.modelImpact * 10000 + 0.001;
            im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm,'PickableParts' , 'none');            
            alpha(im,.2)
            hold(app.UIAxes,"off");                                    
            
            text(app.UIAxes, h.XData, h.YData-1.6 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')               
            text(app.UIAxes, h.XData, h.YData-2.2 ,string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')                                                                           
            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking                                    
            resetplotview(app.UIAxes);
            
            app.mode = 'Assembly';
            
            %app.DD_Material.Items = cellstr(app.materialList);
            %app.DD_ProcessType.Items = app.processList{app.materialList == obj.material};            
        end   
        
        function [total, vector] = generateLCIA(obj,app)
            vector = zeros(length(obj.components(1).stages),1);            
            for e = 1:length(obj.components)
                [~ , compVector] = obj.components(e).generateLCIA(app);
               vector = vector + compVector;
            end
            
            for e = 1:length(obj.assemblies)
                [~ , asmVector] = obj.assemblies(e).generateLCIA(app);
                vector = vector + asmVector;
            end            
            total = sum(vector);            
            %disp(length(obj.assemblies))
        end
        
        function obj = classify(obj,app)            
            for i = 1:length(obj.components)
                 obj.components(i) = obj.components(i).assignComponentType(app);
            end
            if ~isempty(obj.assemblies)
                for i = 1:length(obj.assemblies)                    
                    obj.assemblies(i) = classify(obj.assemblies(i),app);
                end
            end
        end
        
        
        function obj = updateComponent(obj,app,componentId,material,classification)
            obj = scan(obj);
            function asm = scan(asm)
                for i = 1:length(asm.components)
                    if (asm.components(i).id == componentId)
                        asm.components(i).material = material;  
                        if ~isempty(classification)                                                        
                            asm.components(i).classification.(app.classificationType) = classification;
                        end
                        asm.components(i).rates = app.activeElement.rates;                                                                        
                        asm.components(i) = asm.components(i).updateMass();
                        asm.components(i) = asm.components(i).generateStages(app);
                        asm.components(i).displayComponent(app);
                        return
                    end
                end    
                for i = 1:length(asm.assemblies)
                   asm.assemblies(i) = scan(asm.assemblies(i));
                end
            end            
        end
        
        
        function obj = updateProcess(obj,app,processId,newProcess,quantity,correction)
            obj = scan(obj);            
            function asm = scan(asm)
                for i = 1:length(asm.components)
                    for s = 1:length(asm.components(i).stages)
                        for o = 1:length(asm.components(i).stages(s).operations)
                           for p = 1:length(asm.components(i).stages(s).operations(o).processes)                               
                               if (asm.components(i).stages(s).operations(o).processes(p).id == processId)                                                                      
                                   if asm.components(i).stages(s).operations(o).processes(p).activityName ~= newProcess.activityName
                                       newProcess.alternativeProcesses = asm.components(i).stages(s).operations(o).processes(p).alternativeProcesses;                                       
                                       newProcess.functionalUnit = asm.components(i).stages(s).operations(o).processes(p).functionalUnit;
                                       asm.components(i).stages(s).operations(o).processes(p) = newProcess;                                       
                                   else
                                       if asm.components(i).stages(s).operations(o).processes(p).activityLoc ~= app.DD_availableLocations.Value
                                           process = asm.components(i).stages(s).operations(o).processes(p);
                                           newProcess = app.processEngine.getProcess(app,process.activityName,app.DD_availableLocations.Value,process.refProduct);
                                           newProcess.alternativeProcesses = process.alternativeProcesses;
                                           newProcess.functionalUnit = process.functionalUnit;                                           
                                           %newProcess.stageId = process.stageId;                                           
                                           newProcess.rate = process.rate;
                                           asm.components(i).stages(s).operations(o).processes(p) = newProcess;                                           
                                       end
                                   end
                                   asm.components(i).stages(s).operations(o).processes(p).quantity = quantity;                                                                                                         
                                   asm.components(i).stages(s).operations(o).processes(p).correction = correction;                                                                                                         
                                   return
                               end
                            end
                        end
                    end                    
                end    
                for i = 1:length(asm.assemblies)
                   asm.assemblies(i) = scan(asm.assemblies(i));
                end
            end            
        end
        
        function obj = showStageResults(obj,app,stageId)
            values = []; names = [];
            for c = 1:length(obj.components)
                impact = obj.components(c).stages(stageId).generateLCIA(app);
                values = [values impact];
                names = [names obj.components(c).name + " (" + string(impact) + ")"];
            end
            for a = 1:length(obj.assemblies)
                sum = 0;
                for c = 1:length(obj.assemblies(a).components)
                    sum = sum + obj.assemblies(a).components(c).stages(stageId).generateLCIA(app);
                end                
                values = [values sum];
                names = [names obj.assemblies(a).name + " (" + string(sum) + ")"];
            end
            s.value = values';
            s.name = names';
            t = struct2table(s);
            t = sortrows(t,'value');                   
            values = t.value;
            names = t.name;
                                    
            h = barh(app.UIAxes,values,0.5,'FaceColor','#FFAAAA','EdgeColor','none');                        
            text(app.UIAxes, zeros(length(h.XData),1)+max(values)*0.05, h.XData, names,'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal','Interpreter','none')                                            
            app.L_Stage.Text = obj.name + " / " + obj.stageNames(stageId);                        
            
        end            
    
        function rate = getRateByStageId(obj,stageId)
           rate = 0;
           for c = 1:length(obj.components)               
               for s = 1:length(obj.components(c).stages)
                   if obj.components(c).stages(s).id == stageId
                       rate =  obj.components(c).stages(s).rate;
                       return
                   end
               end
           end      
           for a = 1:length(obj.assemblies)              
               res = obj.assemblies(a).getRateByStageId(stageId);
               if res ~= 0
                  rate = res; 
                  return
               end
           end           
        end
    end
end

