function fit = fitInit(d,fitType,fitError,n)

%%
% fit = fitInit(d,fitType,fitError,n)
%
% initialize a fit structure with options
% 

% set top-level fit parameters
fit.error = fitError;
fit.displayMode = 'off';
fit.cv.n = 5;
fit.cv.obj = cvpartition(d.k,'kfold',fit.cv.n);
fit.n = n;
fit.type = fitType;
if isfield(d,'stims')
fit.stims = d.stims;
end
fit.u = d.u;
fit.t = d.t;
fit.c = d.c;
fit.samp = d.samp;
fit.rnd.n = d.rnd.n;
fit.boot.n = 0;
if isfield(d,'stats')
	fit.stats = d.stats;
else
	for ic = 1:fit.c
		d.stats.mn(ic) = nanmean(vector(d.S_ctk(ic,:,:)));
		d.stats.sd(ic) = nanstd(vector(d.S_ctk(ic,:,:)));
		d.stats.prc(ic,1) = min(vector(d.S_ctk(ic,:,:)));
		d.stats.prc(ic,2) = max(vector(d.S_ctk(ic,:,:)));
		fit.stats = d.stats;
	end
end


switch fitType

	% set params for linear model
	case {'L','LN'}
		fit.q = fit.n*fit.c;
		fit.B_q = ones(fit.q,1)/5;
		fit.pr.B.L = kron(eye(fit.c),secondDeriv(fit.q/fit.c));
		fit.pr.B.sigma = 0.01;

	% set params for nonlinear-linear model
	case 'NL'

		fit.q = fit.n*fit.c;
		fit.B_q = ones(fit.q,1)/5;
		fit.m = 16;
		for ic=1:fit.c
			fit.f(ic).type = 'tentFunc';
			fit.f(ic).prng = [(ic-1)*fit.n+1:ic*fit.n];
			fit.f(ic).p = 0;
			fit.f(ic).m = fit.m;
			fit.f(ic).mnVal = d.stats.prc(ic,1);
			fit.f(ic).mxVal = d.stats.prc(ic,2);
			fit.f(ic).nd = linspace(fit.f(ic).mnVal,fit.f(ic).mxVal,fit.f(ic).m);
			fit.f(ic).width = (fit.f(ic).mxVal-fit.f(ic).mnVal)/(fit.f(ic).m-1);
			fit.f(ic).w = fit.f(ic).nd' + randn(size(fit.f(ic).nd'));
		end
		fit.pr.B.L = kron(eye(fit.c),secondDeriv(fit.q/fit.c));
		fit.pr.B.sigma = 0.1;
		fit.pr.F.L = kron(eye(fit.c),secondDeriv(fit.m));
		fit.pr.F.sigma = 0.1;
	
end

switch fit.error
		case 'mse'
			fit.g.type = 'linear';
			fit.g.p = [0];
		case 'loglik'
			fit.g.type = 'logexp1';
			fit.g.p = [0 1];
		end