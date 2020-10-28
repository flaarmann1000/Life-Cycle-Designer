classdef Assembly < handle & matlab.mixin.Copyable
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        id string
        name string
        components Component
        assemblies Assembly
        modelGraph
        ignore = false
        
        processParameter
        exchangable = false
        
    end
    
    methods
        function obj = Assembly(name)
            obj.name = name;
            obj.id = java.util.UUID.randomUUID.toString;
            
            EL = [1 2;2 3;3 4;4 5;5 6;5 7;5 8;5 9;5 10;7 5;8 4;9 3;11,2];
            g = digraph(EL(:,1),EL(:,2));
            obj.modelGraph = g;
            %obj.stageNames = ["material","production","assembly","distribution","use","disposal","maintenance","refurbishment","remanufacturing","recycling"];stager
            obj.processParameter.lifespan.value = 99999;
            obj.processParameter.lifespan.dependant = false;
        end
        
        function obj = addComponent(obj, com, app, classifyFlag)            
            com.parent = obj;
            if classifyFlag
                com.assignComponentType(app);
                com.updateLifespans;
            end
            obj.components(length(obj.components)+1) = com;
        end
        
        function obj = addAssembly(obj, asm)
            asm.parent = obj;
            %obj.updateLifespans;
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
        
        function displayAssemblyTree(asm,app,showFeatures)            
            tree = app.TV_Components;            
            %displays Assembly in TreeView
            tree.Children.delete;
            NodeData.name = asm.name;
            NodeData.id = asm.id;
            root = uitreenode(tree,'Text',asm.name,'NodeData',NodeData, "Icon", "res\asm.png");
            iterate(root,asm);
            expand(tree,'all');
            
            
            function iterate(parent,obj)
                for i = 1:length(obj.components)
                    NodeData.name = obj.components(i).name;
                    NodeData.material= obj.components(i).material;
                    %NodeData.mass = obj.components(i).mass;
                    NodeData.volume = obj.components(i).processParameter.volume;
                    NodeData.id = obj.components(i).id;
                    NodeData.classification = obj.components(i).classification;
                    if obj.components(i).ignore
                        c = uitreenode(parent,'Text',obj.components(i).name,'NodeData',NodeData, "Icon", "res\disenabled.png");
                        c.ContextMenu = app.CM_tree;
                        
                    else
                        c = uitreenode(parent,'Text',obj.components(i).name,'NodeData',NodeData, "Icon", "res\part.png");
                        c.ContextMenu = app.CM_tree;
                    end
                    
                    if showFeatures
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
                end
                for i = 1:length(obj.assemblies)
                    NodeData.name = obj.assemblies(i).name;
                    NodeData.id= obj.assemblies(i).id;
                    p = uitreenode(parent,'Text',obj.assemblies(i).name,'NodeData',NodeData, "Icon", "res\asm.png");
                    p.ContextMenu = app.CM_tree;
                    iterate(p,obj.assemblies(i));
                end
            end
        end
        
        function obj = plot(obj,app)                        
            
            %reset axis
            resetplotview(app.UIAxes);
            axis(app.UIAxes,"fill");
            app.UIAxes.DataAspectRatio = [1 1 1];
            app.UIAxes.Toolbar.Visible = 'off';
            disableDefaultInteractivity(app.UIAxes);
            
            
            XData = [20,40,60,80,100,120,100,80,60,120,40];
            YData = [20,20,20,20, 20, 20, 40, 40,40,40,40];
            NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;161 208 168;189 205 161;211 200 154;231 193 146; 247 182 137]/255;
            EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;161 208 168;189 205 161;211 200 154;247 182 137]/255;
            
            h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',2,'NodeLabel','','ArrowSize',15);
            
            if app.options.displayFlows
                rectangle(app.UIAxes,'Position',[67,10,46,40],'EdgeColor',[227 240 229]/255,'LineWidth',2,'Curvature',.2);
                rectangle(app.UIAxes,'Position',[47,8,68,46],'EdgeColor',[239 240 226]/255,'LineWidth',2,'Curvature',.22);
                rectangle(app.UIAxes,'Position',[13,6,114,52],'EdgeColor',[248 237 223]/255,'LineWidth',2,'Curvature',.24);
                text(app.UIAxes, 90,50.5 ,'product flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [161 208 169]/255, 'FontWeight','normal');
                text(app.UIAxes, 81,54.5 ,'component flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [212 200 154]/255, 'FontWeight','normal');
                text(app.UIAxes, 70,58.5 ,'material flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [231 193 146]/255, 'FontWeight','normal');
            end
            
            % show impacts
            legend(app.UIAxes,'off')
            hold(app.UIAxes,"on");
            [~,impacts] = obj.generateLCIA(app);
            col = zeros(length(impacts),3);
            col(impacts > 0,1) = 1;
            col(impacts < 0,3) = 1;
            impactsNorm = abs(impacts) / abs(app.getModelImpact) * 10000 + 0.001;
            im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',impactsNorm,'PickableParts' , 'none');
            alpha(im,.2)
            hold(app.UIAxes,"off");
            
            text(app.UIAxes, h.XData(1:6), h.YData(1:6)-6 ,app.stageNames(1:6),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
            text(app.UIAxes, h.XData(7:11), h.YData(7:11)+5.5 ,app.stageNames(7:11),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
            
            
            set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
            
            
            if app.options.normTime
                app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + " / yr)";
                text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(app.UIAxes, h.XData(7:11), h.YData(7:11)+3.5 ,string(round(impacts(7:11),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            else
                app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + ")";
                text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
                text(app.UIAxes, h.XData(7:11), h.YData(7:11)+3.5 ,string(round(impacts(7:11),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
            end
            
            app.mode = 'Assembly';
        end
        
        function [total, vector] = generateLCIA(obj,app)
            if ~obj.ignore
                vector = zeros(length(app.stageNames),1);
                for e = 1:length(obj.components)
                    [~ , compVector] = obj.components(e).generateLCIA(app);
                    vector = vector + compVector;
                end
                
                for e = 1:length(obj.assemblies)
                    [~ , asmVector] = obj.assemblies(e).generateLCIA(app);
                    vector = vector + asmVector;
                end
                total = sum(vector);
            else
                total = 0;
                vector = zeros(length(obj.components) + length(obj.assemblies),1);
            end
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
        
        
        function obj = updateComponent(obj,app,componentId,material,classification,ignore,lifespan)
            obj = scan(obj);
            function asm = scan(asm)
                for i = 1:length(asm.components)
                    if (asm.components(i).id == componentId)
                        asm.components(i).ignore = ignore;
                        asm.components(i).processParameter.lifespan.value = lifespan;
                        change = false;
                        if  (material ~= asm.components(i).material)
                            change = true;
                        end
                        if ~strcmp(app.classificationType,"none")
                            if ~strcmp(classification,asm.components(i).classification.(app.classificationType))
                                change = true;
                                asm.components(i).classification.(app.classificationType) = classification;
                            end
                        end
                        if change
                            asm.components(i).material = material;
                            asm.components(i).rates = app.activeElement.rates;
                            asm.components(i) = asm.components(i).updateMass();
                            asm.components(i) = asm.components(i).generateStages(app);
                            asm.components(i).plot(app);
                        end
                        return
                    end
                end
                for i = 1:length(asm.assemblies)
                    asm.assemblies(i) = scan(asm.assemblies(i));
                end
            end
        end
        
        
        function obj = updateProcess(obj,app,processId,newProcess,quantity,quantityExpression,correction)
            obj = scan(obj);
            function asm = scan(asm)
                for i = 1:length(asm.components)
                    for s = 1:length(asm.components(i).stages)
                        for o = 1:length(asm.components(i).stages(s).operations)
                            for p = 1:length(asm.components(i).stages(s).operations(o).processes)
                                if (asm.components(i).stages(s).operations(o).processes(p).id == processId)
                                    if asm.components(i).stages(s).operations(o).processes(p).name ~= newProcess.name
                                        newProcess.alternativeProcesses = asm.components(i).stages(s).operations(o).processes(p).alternativeProcesses;
                                        newProcess.functionalUnit = asm.components(i).stages(s).operations(o).processes(p).functionalUnit;
                                        asm.components(i).stages(s).operations(o).processes(p) = newProcess;
                                    else
                                        if asm.components(i).stages(s).operations(o).processes(p).activityLoc ~= app.DD_availableLocations.Value
                                            process = asm.components(i).stages(s).operations(o).processes(p);
                                            newProcess = app.processEngine.getProcess(app,process.name,app.DD_availableLocations.Value,process.refProduct);
                                            newProcess.alternativeProcesses = process.alternativeProcesses;
                                            newProcess.functionalUnit = process.functionalUnit;
                                            newProcess.parent = process.parent;
                                            %newProcess.stageId = process.stageId;
                                            %newProcess.rate = process.rate;
                                            asm.components(i).stages(s).operations(o).processes(p) = newProcess;
                                        end
                                    end
                                    asm.components(i).stages(s).operations(o).processes(p).quantity = quantity;
                                    asm.components(i).stages(s).operations(o).processes(p).quantityExpression = quantityExpression;
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
                if ~obj.components(c).ignore
                    impact = obj.components(c).stages(stageId).generateLCIA(app);
                    values = [values impact];
                    names = [names obj.components(c).name];
                end
            end
            for a = 1:length(obj.assemblies)
                if ~obj.assemblies(a).ignore
                    su = 0;
                    for c = 1:length(obj.assemblies(a).components)
                        su = su + obj.assemblies(a).components(c).stages(stageId).generateLCIA(app);
                    end
                    values = [values su];
                    names = [names obj.assemblies(a).name];
                end
            end
            
            if app.options.normTime
                app.stageId
                app.L_Navi.Text = app.activeElement.name + " / " + app.stageNames(stageId) + " (" + string(round(sum(values),2)) +" "+ app.lciaUnit + " / yr)";
            else
                app.L_Navi.Text = app.activeElement.name + " / " + app.stageNames(stageId) + " (" + string(round(sum(values),2)) +" "+ app.lciaUnit + ")";
            end
            
            s.value = values';
            s.name = names';
            t = struct2table(s);
            t = sortrows(t,'value','descend');
            values = t.value;
            names = t.name;
            
            %mymap = [linspace(242,242,100)', linspace(173,240,100)', linspace(177,173,100)']/255;
            mymap = [linspace(242,220,100)', linspace(173,245,100)', linspace(177,250,100)']/255;
            
            colormap(app.UIAxes,mymap )
            p = pie(app.UIAxes,values./sum(values));
            
            h = rectangle(app.UIAxes,'Position',[-0.75,-0.75,1.5,1.5],'Curvature',[1,1],'FaceColor',[1 1 1], 'EdgeColor', [1 1 1]);
            
            legend(app.UIAxes,names,'Interpreter','none','Location','bestoutside');
            legend(app.UIAxes,'boxoff');
            for i = 1:length(p)
                if isprop(p(i),"EdgeAlpha")
                    p(i).EdgeAlpha = 0;
                end
            end
            
        end
        
        function rate = getRateByStageId(obj,stageId)
            rate = -1;
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
                if res ~= -1
                    rate = res;
                    return
                end
            end
        end
        
        function obj = updateLifespans(obj)
            %checks wether obj lifespan is shorten than it's parent
            parentAsm = obj.parent;
            if ~isempty(parentAsm)
                if parentAsm.processParameter.lifespan.value > obj.processParameter.lifespan.value
                    parentAsm.processParameter.lifespan.value = obj.processParameter.lifespan.value;
                    parentAsm.updateLifespans;
                end
            end
        end
        
        function obj = checkLifespans(obj)
            %checks wether obj's lifespan is still defined by it's shortest
            % inexchangable children
            
            obj.processParameter.lifespan.value = 99999;
            
            for i = 1:length(obj.components)
                if ~obj.components(i).exchangable && obj.components(i).processParameter.lifespan.value < obj.processParameter.lifespan.value
                    obj.processParameter.lifespan.value = obj.components(i).processParameter.lifespan.value;
                    if ~isempty(obj.parent)
                        obj.parent.checkLifespans;
                    end
                end
            end
            for i = 1:length(obj.assemblies)
                if ~obj.assemblies(i).exchangable && obj.assemblies(i).processParameter.lifespan.value < obj.processParameter.lifespan.value
                    obj.processParameter.lifespan.value = obj.assemblies(i).processParameter.lifespan.value;
                    if ~isempty(obj.parent)
                        obj.parent.checkLifespans;
                    end
                end
            end
        end
        
        
        function obj = setLifespans(obj)
            for a = 1:length(obj.assemblies)
                obj.assemblies(a).checkLifespans;
                obj.assemblies(a).setLifespans;
            end
        end
        
    end
end

