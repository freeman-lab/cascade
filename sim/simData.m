function d = simData(d,sim)

% 
% d = simData(d,sim)
% 
% generate simulated data for testing model fits
% 

switch sim.type
case 'L'
	d.S = randn(d.c,d.t*d.k)/2;
	d.S_ct = makeStimRows(d.S',d.n)';
	d.R_t = evalNonLin(sim.B_q'*d.S_ct,sim.g);

case 'NL'
	d.S = randn(d.c,d.t*d.k)/2;
	d.S_ct = makeStimRows(d.S',d.n)';
	d.R_t = evalNonLin(sim.B_q'*evalNonLin(d.S_ct,sim.f),sim.g);
end

noise = 0.5;
switch sim.error
case 'mse'
	d.R_t = d.R_t + randn(size(d.R_t))*noise;
case 'loglik'
	d.R_t = poissrnd(d.R_t);
end

d.S_ctk = reshape(d.S_ct,d.c,d.t,d.k);
d.R_ntk = reshape(d.R_t,1,d.t,d.k);