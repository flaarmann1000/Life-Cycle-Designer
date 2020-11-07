function analyseAssembly(app)
    
resTable = table();
iterate(app.model.root);

results = resTable.Impact;
names = resTable.Name;

axes = app.UIAxes;
h = barh(axes,results,0.5,'FaceColor','#FFAAAA','EdgeColor','none');

text(axes, ones(length(h.XData),1).*-0.5, h.XData ,names ,"FontSize",12,"Color", [.3 .3 .35],'HorizontalAlignment', 'right','VerticalAlignment','baseline','FontWeight',"normal");
if app.options.normTime
    text(axes, ones(length(h.XData),1).*-0.5, h.XData ,string(results) + " " + string(app.lciaUnit + " / yr") ,"FontSize",12,"Color", [255 170 170]/255,'HorizontalAlignment', 'right','VerticalAlignment','top','FontWeight',"normal");
else
    text(axes, ones(length(h.XData),1).*-0.5, h.XData ,string(results) + " " + string(app.lciaUnit) ,"FontSize",12,"Color", [255 170 170]/255,'HorizontalAlignment', 'right','VerticalAlignment','top','FontWeight',"normal");
end

legend(axes,'off')
axis(axes,"fill")
resetplotview(axes);

enableDefaultInteractivity(app.UIAxes);
app.UIAxes.Interactions = [zoomInteraction, panInteraction];




    function iterate(asm)
        addComponents(asm);
        for a = 1:length(asm.assemblies)
           iterate(asm.assemblies(a)); 
        end        
    end


    function addComponents(asm)
        for c = 1:length(asm.components)
           Impact = asm.components(c).generateLCIA(app);
           Name = asm.components(c).name;
           row = table(Name, Impact);
           resTable = [resTable; row];
        end
    end
end