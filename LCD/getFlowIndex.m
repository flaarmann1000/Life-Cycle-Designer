function index = getFlowIndex(app, Provider, Product, Loc)
row = app.ie((string(app.ie.product) == string(Product)) & (string(app.ie.geography) == string(Loc)) & (string(app.ie.activityName) == string(Provider)),:);
index = row.index;
end