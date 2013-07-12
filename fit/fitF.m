function fit = fitF(data,fit,testMode)

%
% fit = fitF(data,fit,testMode)
%
% fit the nonlinearities F in a NL model
% using gradient descent
% 
% set testMode == 1 to check gradients and hessians
%

% initalize parameters
x0 = [cat(1,fit.f(:).w)];

% premultiply nonlinearity output by filters to simplify computation
Y_ct = [];
for ic=1:fit.c
    prng = fit.f(ic).prng;
    Y_ct_tmp = squeeze(sum(bsxfun(@times,data.S_ct_f(prng,:,:),fit.B_q(prng)),1));
    Y_ct = cat(2,Y_ct,Y_ct_tmp);
end
Y_ct = Y_ct';
R_t = data.R_t;

% precompute matrices associated with prior
if fit.pr.F.sigma
    fit.pr.F.D = fit.pr.F.L*fit.pr.F.L';
    fit.pr.F.scale = (1/(2*fit.pr.F.sigma));
end

% create objective function
fun = @(prs) fitF_err(prs,Y_ct,R_t,fit);

% check deriviatives and hessians
if ~ieNotDefined('testMode') && testMode == 1
    [a b] = checkDeriv_Elts(fun,x0);
    [a b] = checkHess_Elts(fun,x0);
    return
end

% do the optimization
opts = optimset('Display',fit.displayMode,'GradObj','on','Hessian','on','MaxFunEvals',20000);
%A = [];
%b = [];
%Aeq = [];
%Beq = [];
%lb = [zeros(length(x0)-1,1); -inf];
%ub = [ones(length(x0)-1,1)*inf; inf];
%nonlcon = [];
%estParams = fmincon(fun,x0,A,b,Aeq,Beq,lb,ub,nonlcon,opts);
estParams = fminunc(fun,x0,opts);

% collect results, and normalize so that
% the minimum is 0 and the max is 1 (removes degenerecy!)
estParams = reshape(estParams(1:end),(length(estParams))/fit.c,fit.c);
for ic=1:fit.c
    fit.f(ic).w = estParams(:,ic);
    fit.f(ic).w = fit.f(ic).w-min((fit.f(ic).w));
    fit.f(ic).w = fit.f(ic).w/max((fit.f(ic).w));
end

%fit.g.p(1) = estParams(end);

%-------------------------------------------
function [err grad hess] = fitF_err(prs,Y_ct,R_t,fit)

%fit.g.p(1) = prs(end);
A_m = prs(1:end);

% get the current output
[Z_t dZ_t ddZ_t] = evalNonLin(A_m'*Y_ct, fit.g);

if fit.pr.F.sigma
    errPrior = fit.pr.F.scale*A_m'*fit.pr.F.D*A_m;
else
    errPrior = 0;
end

switch fit.error
    case 'loglik'
        % check for small values, set to 0 for gradient
        etol = 10^-6;
        iiz = Z_t <= etol;
        f(iiz) = etol;
        df(iiz) = 0;
        dff(iiz) = 0;
        
        % compute liklihood
        loglik = getLogLikSpk(Z_t,R_t);
        err = -loglik;
    case 'mse'
        err = sum((Z_t-R_t).^2) + errPrior;
end

% get grads and hessians
switch fit.error
case 'mse'
    if nargout > 1
        % useful intermediate quantities
        Q_t = bsxfun(@times,Y_ct,dZ_t);
        F_t = (Z_t-R_t);

        % components of gradient
        grad_B = 2*(F_t*Q_t'); % linear
        grad_f = -2*F_t*dZ_t'; % nonlin constant
        
        % contribution of prior
        if fit.pr.F.sigma
            grad_B = grad_B + (fit.pr.F.scale*2*fit.pr.F.D*A_m)';
        end
        
        grad = [grad_B];

    end
    if nargout > 2
        % useful intermediate quantities
        QQ_t = dZ_t.^2 + Z_t.*ddZ_t - R_t.*ddZ_t; % mix of derivitatives of Z from product rule

        % components of Hessian
        H_BB = 2*bsxfun(@times,Y_ct,QQ_t)*Y_ct'; % linear
        H_Bf = -2*(QQ_t*Y_ct')'; % linear and baseline
        H_ff = 2*sum(QQ_t); % baseline

        % contribution of prior
        if fit.pr.F.sigma
            H_BB = H_BB + fit.pr.F.scale*2*fit.pr.F.D;
        end

        % total hessian
        hess = H_BB;
        %hess = [H_BB, H_Bf; H_Bf' H_ff];
    end
end 