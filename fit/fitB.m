function fit = fitB(data,fit,testMode,normFactor)

%
% fit = fitB(data,fit,testMode)
%
% fit the kernels B in a NL or L model
% using gradient descent
% 
% set testMode == 1 to check gradients and hessians
%

% flag to ignore constant if nonlinearity is a spline
if strcmp(fit.g.type,'spline')
    usingSplines = 1;
else
    usingSplines = 0;
end

% get initial parameters
if usingSplines
	x0 = [fit.B_q(:)];
else
	x0 = [fit.B_q(:)*2;fit.g.p(:)];
end

% precompute matrices associated with prior
if fit.pr.B.sigma
	fit.pr.B.D = fit.pr.B.L*fit.pr.B.L';
	fit.pr.B.scale = (1/(2*fit.pr.B.sigma));
end

% if there is an input nonlinearity, apply it
if isfield(fit,'f')
	S_ct = zeros(size(data.S_ct_f(:,:,1)));
	for ic=1:fit.c
		prng = fit.f(ic).prng;
		tmp(1,1,:) = fit.f(ic).w;
		S_ct(prng,:) = sum(bsxfun(@times,data.S_ct_f(prng,:,:),tmp),3);
	end
	if ~ieNotDefined('normFactor')
		S_ct = bsxfun(@rdivide,S_ct,normFactor);
	end
else
	S_ct = data.S_ct;
end
R_t = data.R_t;

% create objective function
fun = @(prs) fitB_err(prs(:),S_ct,R_t,fit);

% check deriviatives and hessians
if ~ieNotDefined('testMode') && testMode
	[a b] = checkDeriv_Elts(fun,x0);
	[a b] = checkHess_Elts(fun,x0);
	return
end

% do the optimization
opts = optimset('Display',fit.displayMode,'GradObj','on','Hessian','on','MaxFunEvals',20000);
prsEst = fminunc(fun,x0,opts);

% collect results
fit.B_q = prsEst(1:fit.q);
if ~usingSplines
fit.g.p(1) = prsEst(fit.q+1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [err grad hess Z_t] = fitB_err(prs,S_ct,R_t,fit)

% flag to ignore constant if we're using splines
if strcmp(fit.g.type,'spline')
    usingSplines = 1;
else
    usingSplines = 0;
end

% get filter parameters
B_q = prs(1:fit.q);

% get nonlinearity parameters (i.e. constant)
if ~usingSplines
	fit.g.p(1) = prs(fit.q+1);
end

% evaluate prediction
[Z_t dZ_t ddZ_t] = evalNonLin(B_q'*S_ct, fit.g);

% get contribution of prior to objective
if fit.pr.B.sigma
	errPrior = fit.pr.B.scale*B_q'*fit.pr.B.D*B_q;
else
	errPrior = 0;
end

% get error
switch fit.error
	case 'mse'
		err = sum((Z_t-R_t).^2) + errPrior;
	case 'loglik'
		etol = 10^-6;
		iiz = Z_t <= etol;
		Z_t(iiz) = etol;
		dZ_t(iiz) = 0;
		ddZ_t(iiz) = 0;
		loglik = getLogLikSpk(Z_t,R_t);
		err = -loglik;
end

% get grads and hessians
switch fit.error
case 'mse'
    if nargout > 1
    	% useful intermediate quantities
    	Q_t = bsxfun(@times,S_ct,dZ_t);
    	F_t = (Z_t-R_t);

    	% components of gradient
    	grad_B = 2*(F_t*Q_t'); % linear
    	grad_f = -2*F_t*dZ_t'; % nonlin constant
    	
    	% contribution of prior
    	if fit.pr.B.sigma
    		grad_B = grad_B + (fit.pr.B.scale*2*fit.pr.B.D*B_q)';
    	end

    	% total gradient
    	if usingSplines
    		grad = [grad_B];
    	else
    		grad = [grad_B,grad_f];
    	end

		end
		if nargout > 2
			% useful intermediate quantities
			QQ_t = dZ_t.^2 + Z_t.*ddZ_t - R_t.*ddZ_t; % mix of derivitatives of Z from product rule

			% components of Hessian
			H_BB = 2*bsxfun(@times,S_ct,QQ_t)*S_ct'; % linear
			H_Bf = -2*(QQ_t*S_ct')'; % linear and baseline
			H_ff = 2*sum(QQ_t); % baseline

			% contribution of prior
			if fit.pr.B.sigma
				H_BB = H_BB + fit.pr.B.scale*2*fit.pr.B.D;
			end

			% total hessian
			if usingSplines
				hess = H_BB;
			else
				hess = [H_BB, H_Bf; H_Bf' H_ff];
			end

		end
end	





