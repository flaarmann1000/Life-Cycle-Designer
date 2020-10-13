function compareModels(app)
%compareModels Compares Model with Reference Model
obj = app.model.root;

XData = [20,40,60,80,100,120,100,80,60,40];
YData = [20,20,20,20, 20, 20, 40,40,40,40];
NodeColors = [247 182 137;247 182 137;247 182 137;247 182 137; 105 176 226; 244 136 136;231 193 146;211 200 154;189 205 161;161 208 168]/255;
EdgeColors = [247 182 137;247 182 137;247 182 137;247 182 137;105 176 226;105 176 226;105 176 226;105 176 226;105 176 226;231 193 146;211 200 154;189 205 161;161 208 168]/255;

h = plot(app.UIAxes, obj.modelGraph, 'XData', XData, 'YData', YData, 'ArrowPosition', 0.5,'MarkerSize',30,'NodeColor',NodeColors,'EdgeColor',EdgeColors,'LineWidth',2,'NodeLabel','','ArrowSize',15);

% show impacts
hold(app.UIAxes,"on");
[~,impactsModel] = obj.generateLCIA(app);
%[~,impactsReference] = app.referenceModel.generateLCIA(app);
impacts = impactsModel - app.impactsReference;

col = zeros(length(impacts),3);
col(impacts > 0,1) = 1; %red
col(impacts < 0,3) = 1; %blue
im  = scatter(app.UIAxes,h.XData, h.YData,[], col, 'filled','SizeData',abs(impacts)*200 + 0.001,'PickableParts' , 'none');
alpha(im,.2)
hold(app.UIAxes,"off");

text(app.UIAxes, h.XData(1), h.YData(end)+24 ,'Impact Difference','VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal','FontWeight',"bold")
text(app.UIAxes, h.XData(1), h.YData(end)+22 ,'red: current impact > reference impact','VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.8 .5 .5], 'FontWeight','normal')
text(app.UIAxes, h.XData(1), h.YData(end)+20 ,'blue: current impact < reference impact','VerticalAlignment','bottom', 'HorizontalAlignment', 'left', 'FontSize', 14, 'Color', [.5 .5 .8], 'FontWeight','normal')



%text(app.UIAxes, h.XData, h.YData-1.6 ,obj.stageNames,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
%text(app.UIAxes, h.XData, h.YData-2.2 ,string(round(impacts,2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')

set(h,'ButtonDownFcn',@app.getCoord); % Defining what happens when clicking
resetplotview(app.UIAxes);

app.mode = 'Assembly';

if app.options.displayFlows
    rectangle(app.UIAxes,'Position',[67,10,46,40],'EdgeColor',[227 240 229]/255,'LineWidth',2,'Curvature',.2);
    rectangle(app.UIAxes,'Position',[47,8,68,46],'EdgeColor',[239 240 226]/255,'LineWidth',2,'Curvature',.22);
    rectangle(app.UIAxes,'Position',[13,6,114,52],'EdgeColor',[248 237 223]/255,'LineWidth',2,'Curvature',.24);
    text(app.UIAxes, 90,50.5 ,'product flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [161 208 169]/255, 'FontWeight','normal');
    text(app.UIAxes, 81,54.5 ,'component flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [212 200 154]/255, 'FontWeight','normal');
    text(app.UIAxes, 70,58.5 ,'material flow','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 16, 'Color', [231 193 146]/255, 'FontWeight','normal');
end

text(app.UIAxes, h.XData(1:6), h.YData(1:6)-6 ,obj.stageNames(1:6),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')
text(app.UIAxes, h.XData(7:10), h.YData(7:10)+5.5 ,obj.stageNames(7:10),'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', [.3 .3 .35], 'FontWeight','normal')

if app.options.normTime
    app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + " / yr)";
    text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
    text(app.UIAxes, h.XData(7:10), h.YData(7:10)+3.5 ,string(round(impacts(7:10),2)) + " " + app.lciaUnit + ' / yr','VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
else
    app.L_Navi.Text = obj.name + " (" + string(round(obj.generateLCIA(app),2)) +" "+ app.lciaUnit + ")";
    text(app.UIAxes, h.XData(1:6), h.YData(1:6)-8 ,string(round(impacts(1:6),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
    text(app.UIAxes, h.XData(7:10), h.YData(7:10)+3.5 ,string(round(impacts(7:10),2)) + " " + app.lciaUnit,'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', [.6 .6 .7], 'FontWeight','normal')
end

end

