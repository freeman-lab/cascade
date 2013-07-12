function [d sim] = initSim(simType,simError);

%
% fit = prepareFit(d,data,fitType)
%
% initialize a simulation with options
% 

d.n = 40;
d.t = 2000;
d.c = 2;

sim.type = simType;
sim.error = simError;

switch simType
case 'L'
	B_n_base = normpdf(linspace(-4,4,d.n),0,1);
	B_n_1 = normVec(circshift(B_n_base,[0 0]))';
	B_n_2 = normVec(circshift(B_n_base,[0 10]))'*2;
	sim.B_q = [B_n_1; B_n_2];

case 'NL'
	B_n_base = normpdf(linspace(-4,4,d.n),0,1);
	B_n_1 = normVec(circshift(B_n_base,[0 0]))';
	B_n_2 = normVec(circshift(B_n_base,[0 10]))'*2;
	sim.B_q = [B_n_1; B_n_2];

	sim.f(1).type = 'linear';
	sim.f(1).p = 0;
	sim.f(1).prng = [1:d.n];
	sim.f(2).type = 'linear';
	sim.f(2).p = 0;
	sim.f(2).prng = [d.n+1:d.n*2];

end

switch simError
case 'mse'
	sim.g.type = 'linear';
	sim.g.p = [0];

case 'loglik'
	sim.g.type = 'logexp1';
	sim.g.p = [0 1];

end