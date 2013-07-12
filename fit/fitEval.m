function out = evalFit(data,fit,normFactor)

%
% function out = evalFit(data,fit)
%
% evaluate a fit by computing a generator signal
% and getting r2
%

switch fit.type
case 'L'
	Z_t = evalNonLin(fit.B_q'*data.S_ct, fit.g);
	r2 = getR2(Z_t,data.R_t);
	r = getR(Z_t,data.R_t);
case 'NL'
	in = zeros(size(data.S_ct_f(:,:,1)));
	for ic=1:fit.c
		prng = fit.f(ic).prng;
		tmp(1,1,:) = fit.f(ic).w;
		in(prng,:) = sum(bsxfun(@times,data.S_ct_f(prng,:,:),tmp),3);
	end
	if ~ieNotDefined('normFactor')
		in = bsxfun(@rdivide,in,normFactor);
	end
	Z_t = evalNonLin(fit.B_q'*in, fit.g);
	r2 = getR2(Z_t,data.R_t);
	r = getR(Z_t,data.R_t);
end

out.r2 = r2;
out.r = r;
out.Z_t = Z_t;
out.R_t = data.R_t;