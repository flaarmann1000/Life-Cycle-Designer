function checkForUpdates(~,~, app)

path = [app.options.exchangeFilePath  'status.txt'];
fileID = fopen(path,'r');
txt = fscanf(fileID,'%s');
fclose(fileID);


if ~strcmp(txt,app.iteration)        

    if isempty(app.model.root)
        c=xml2struct([app.options.exchangeFilePath 'exchange.xml']);
        I_asm = struct2I_Assembly(c);
        app.TV_Components.Children.delete;        
        app.model.root = I_Assembly2Assembly(app,I_asm);        
        h = waitbar(0.2,['classify assembly...']);
        app.model.root = app.model.root.classify(app);
        close(h);        
        disp("huehue");
        app.modelImpact = app.model.root.generateLCIA(app);        
        app.TV_Components.Children.delete;
        app.model.root.displayAssemblyTree(app.TV_Components,app.CB_ShowFeatures.Value)
        expand(app.TV_Components,'all');                
        app.model.root.displayAssembly(app);
        app.activeElement = app.model.root;
        app.L_Navi.Text = app.activeElement.name + " (" + string(app.activeElement.generateLCIA(app)) +" "+ app.lciaUnit + ")";
        app.projectLoaded = true;
        app.L_Mode.Text = lower(app.mode);
        app.L_RefTime.Text = "reference time: " + app.options.referenceTime + " h";        
        app.setTVSelection();
    else
        disp("update Model")
        updateModel(app);
    end
    app.iteration = txt;
            
end


end