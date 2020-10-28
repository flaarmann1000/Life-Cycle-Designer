function batchResults(app)

%indicators = [760 759 743 490 101 103 104 100 102 105 106 107 547];

indicators = [101 103 104 100 102 105 106 107 547];

originalLciaIndex = app.lciaIndex;

results = zeros(length(indicators),1);

for i = 1:length(indicators)
    app.lciaIndex = indicators(i);
    results(i) = app.model.root.generateLCIA(app);
    
    tab = app.LCIA(app.LCIA.index == indicators(i),:);
    method = string(tab.method);
    category = string(tab.category);
    indicator = string(tab.indicator);
        
    disp(method + ' - ' + category + ' - ' + indicator);
    disp(round(results(i),2));
end

app.lciaIndex = originalLciaIndex;

end