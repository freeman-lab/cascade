% simulate from linear model
[dsim sim] = simInit('L','loglik');
dsim = simData(dsim,sim);
% run fit
fit = fitInit(dsim,'L','loglik',40);
%dsim = prepareStim(dsim,fit);
[train test] = prepareRoi(dsim,fit,1,0);
fit = fitDo(train,test,fit);

% simulate from a nonlinear-linear model
[dsim sim] = simInit('NL','mse');
dsim = simData(dsim,sim);
% run fit
fit = fitInit(dsim,'NL','mse',dsim.n);
dsim = prepareStim(dsim,fit);
[train test] = prepareRoi(dsim,fit,1,0);
fit = fitDo(train,test,fit);
