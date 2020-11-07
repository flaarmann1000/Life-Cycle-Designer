function showLCIA(app)

originalIndex = app.lciaIndex;

lciaTableMethods = app.LCIA(app.LCIA.method == app.lciaMethod,:);

results = zeros(height(lciaTableMethods),1);

for i = 1:height(lciaTableMethods)
   app.lciaIndex =  lciaTableMethods.index(i);
   results(i) = app.activeElement.generateLCIA(app);
end

app.lciaIndex = originalIndex;

axes = app.UIAxes;
h = barh(axes,results,0.5,'FaceColor','#FFAAAA','EdgeColor','none');

text(axes, ones(length(h.XData),1).*-0.5, h.XData ,string(lciaTableMethods.category) + " - " + string(lciaTableMethods.indicator) ,"FontSize",12,"Color", [.3 .3 .35],'HorizontalAlignment', 'right','VerticalAlignment','baseline','FontWeight',"normal");

if app.options.normTime
    text(axes, ones(length(h.XData),1).*-0.5, h.XData ,string(results) + " " + string(lciaTableMethods.unitName)+' / yr' ,"FontSize",12,"Color", [255 170 170]/255,'HorizontalAlignment', 'right','VerticalAlignment','top','FontWeight',"normal");
else    
    text(axes, ones(length(h.XData),1).*-0.5, h.XData ,string(results) + " " + string(lciaTableMethods.unitName) ,"FontSize",12,"Color", [255 170 170]/255,'HorizontalAlignment', 'right','VerticalAlignment','top','FontWeight',"normal");
end

legend(axes,'off')
axis(axes,"fill")
resetplotview(axes);

enableDefaultInteractivity(app.UIAxes);
app.UIAxes.Interactions = [zoomInteraction, panInteraction];



end