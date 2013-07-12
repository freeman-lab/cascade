%% simulate linear model
[dsim sim] = simInit('L','loglik');
[train test] = simData(dsim,sim);
fit = fitInit(dsim,'L','loglik');
fit = doFit(train,test,fit);

%% simulate nonlinear-linear model
[dsim sim] = initSim('NL');
[train test] = genData(dsim,sim);
fit = initFit(dsim,train,'NL');
fit = doFit(train,test,fit);


d.stats.mn = nanmean(d.stimUpRaw,2);
d.stats.std = nanstd(d.stimUpRaw,[],2);
z = bsxfun(@minus,d.stimUpRaw,d.stats.mn);
z = bsxfun(@rdivide,z,d.stats.std);
d.stats.prc = prctile(z,[0.25 99.75],2);