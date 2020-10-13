function displayTime(app)
fullTime = app.options.referenceTime;

year = zeros(fullTime+1,1);

h = waitbar(0,'Calculating...');

for i = 1:fullTime+1
    waitbar(i/fullTime,h,'year ' + string(i));
    app.options.referenceTime = (i);
    year(i) = app.activeElement.generateLCIA(app);
end

delete(h);

fig = figure('Name','course of time: ' + app.activeElement.name,'NumberTitle','off');
set(fig, 'MenuBar', 'none');
set(fig, 'ToolBar', 'none');
fig.Color = [1 1 1];
stairs([0:length(year)-1] , year, 'LineWidth',2,'Color',[244 136 136]/255);
grid on
xlabel 'years'
if app.options.normTime
    ylabel(app.lciaIndicator + ' [' + app.lciaUnit + ' / yr]');
else
    ylabel(app.lciaIndicator + ' [' + app.lciaUnit + ']');
end
title('course of time: ' + app.activeElement.name);

app.options.referenceTime = fullTime;

end