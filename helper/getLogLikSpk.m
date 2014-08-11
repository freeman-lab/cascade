function loglik = getLogLikSpk(predic,spks)

%-------------------------------------------
%
% loglik = getLogLikSpk(predic,spks)
%
% get loglikelihood for an inhomogenous
% poisson process (ignoring constants)
%
% inputs:
% predic -- prediction in each time bin
% spks -- number of events in each time bin
%
% outputs:
% loglik -- loglikihood of events
%
% freeman, 1-1-2011
%-------------------------------------------

etol = 10^-6;
predic(predic<etol) = etol;

loglik = (sum(spks(:).*log(predic(:))) - sum(predic(:)));

