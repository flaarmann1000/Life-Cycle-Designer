function compareVersions(app)
names = string(fieldnames(app.alternatives));
impacts = zeros(length(names),1);

app.mode = "Compare Versions";

    for a = 1:length(names)
        impacts(a) = app.alternatives.(names{a}).generateLCIA(app);        
    end
    h = bar(app.UIAxes,impacts,0.5,'FaceColor','#FFAAAA','EdgeColor','none');   
    
    disableDefaultInteractivity(app.UIAxes);
    %app.UIAxes.Interactions = [panInteraction,zoomInteraction];    
    
    axis(app.UIAxes, [min(h.XData)-1 max(h.XData)+1 min(h.YData)-1 max(h.YData)+1]);    
    
    yScale = h.Parent.YLim(2) - h.Parent.YLim(1);
    text(app.UIAxes, h.XData, zeros(length(h.XData),1) - yScale*0.035, names,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal');

      if app.options.normTime
           text(app.UIAxes, h.XData, zeros(length(h.XData),1) - yScale*0.06, string(impacts)  + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal');
      else
          text(app.UIAxes, h.XData, zeros(length(h.XData),1) - yScale*0.06, string(impacts) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
      end             
end