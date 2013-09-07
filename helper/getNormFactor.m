function normFactor = getNormFactor(data,fit)

%
% normFactor = getNormFactor(data,fit)
%
% get the normalizing factor based on training data
% and fit
%

S_ct = zeros(size(data.S_ct_f(:,:,1)));
for ic=1:fit.c
	prng = fit.f(ic).prng;
	tmp(1,1,:) = fit.f(ic).w;
	S_ct(prng,:) = sum(bsxfun(@times,data.S_ct_f(prng,:,:),tmp),3);
end
for ic=1:fit.c
	prng = fit.f(ic).prng;
	normFactor(ic) = std(S_ct(prng(end),:));
end