function fit = fitG(data,fit)


% evaluate input into nonlinearity
out = fitEval(data,fit);
Z_in = out.Z_t;

% get the range of values for setting the spline knots
mnVal = min(Z_in(:));
mxVal = max(Z_in(:));

% store the old nonlinearity
fOld = fit.g;

% create the spline parameter matrix
fit.g.knots = linspace(mnVal,mxVal,fit.g.nknots);
fit.g.Mspline = splineParamMatrix(fit.g.knots,...
    fit.g.smoothness,fit.g.extrap);

% get initial values for the spline parameters
initPrs = initNonLinSpline(fit.g,fOld);

% do the optimization
options = optimset('maxiter',250,'maxfunevals',1e6,...
    'Display',fit.displayMode,'Largescale','off');
estParams = fminunc(@(prs) fitF_errFun(prs,Z_in,data.R_t,fit),initPrs,options);
fit.g.w = estParams;


%-------------------------------------------
function [err] = fitF_errFun(prs,Z_in,R_t,fit)

fit.g.w = prs;

% get the current RGC output
Z_t = evalNonLin(Z_in,fit.g);

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
        err = sum((Z_t-R_t).^2);
end