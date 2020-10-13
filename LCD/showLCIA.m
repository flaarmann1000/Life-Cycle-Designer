function showLCIA(app)

originalIndex = app.lciaIndex;

lciaTableMethods = app.LCIA(app.LCIA.method == app.lciaMethod,:);

results = zeros(height(lciaTableMethods),1);

for i = 1:height(lciaTableMethods)
   app.lciaIndex =  lciaTableMethods.index(i);
   results(i) = app.activeElement.generateLCIA(app);
end

app.lciaIndex = originalIndex;

h = barh(app.UIAxes,results,0.5,'FaceColor','#FFAAAA','EdgeColor','none');

text(app.UIAxes, ones(length(h.XData),1).*-0.5, h.XData ,string(lciaTableMethods.category) + " - " + string(lciaTableMethods.indicator) ,"FontSize",12,"Color", [.3 .3 .35],'HorizontalAlignment', 'right','VerticalAlignment','baseline','FontWeight',"normal");
text(app.UIAxes, ones(length(h.XData),1).*-0.5, h.XData ,string(results) + " " + string(lciaTableMethods.unitName) ,"FontSize",12,"Color", [255 170 170]/255,'HorizontalAlignment', 'right','VerticalAlignment','top','FontWeight',"normal");

enableDefaultInteractivity(app.UIAxes);
app.UIAxes.Interactions = [zoomInteraction, panInteraction];



end