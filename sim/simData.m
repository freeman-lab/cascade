function [train test] = simData(d,sim)

% 
% [train test] = simData(d,sim)
% 
% generate simulated data for testing model fits
% 

switch sim.type
case 'L'
	train.S = randn(d.c,d.t)/2;
	train.S_ct = makeStimRows(train.S',d.n)';
	test.S = randn(d.c,d.t)/2;
	test.S_ct = makeStimRows(test.S',d.n)';

	train.R_t = evalNonLin(sim.B_q'*train.S_ct,sim.g);
	test.R_t = evalNonLin(sim.B_q'*train.S_ct,sim.g);

case 'NL'
	train.S = randn(d.c,d.t)/2;
	train.S_ct = makeStimRows(train.S',d.n)';
	test.S = randn(d.c,d.t)/2;
	test.S_ct = makeStimRows(test.S',d.n)';

	train.R_t = evalNonLin(sim.B_q'*evalNonLin(train.S_ct,sim.f),sim.g);
	test.R_t = evalNonLin(sim.B_q'*evalNonLin(test.S_ct,sim.f),sim.g);
end

noise = 0.5;
switch sim.error
case 'mse'
	train.R_t = train.R_t + randn(size(train.R_t))*noise;
	test.R_t = test.R_t + randn(size(test.R_t))*noise;
case 'loglik'
	train.R_t = poissrnd(train.R_t);
	test.R_t = poissrnd(test.R_t);
end

train.roiId = 1;
test.roiId = 1;

