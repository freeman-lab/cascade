function fit = fitDo(train,test,fit)

%
% fit = doFit(train,test,fit)
%
% do fitting optimization
% 

trainOrig = train;
testOrig = test;
train = removeNaNs(train,fit);
test = removeNaNs(test,fit);

switch fit.type
	case 'L'
		% just fit B
		fit = fitB(train,fit);
		fit.train = fitEval(train,fit);
		fit.test = fitEval(test,fit);

	case 'LN'
		fit = fitB(train,fit);
		fit = fitG(train,fit);
		fit.g = initSpline(fit.g);
		fit = fitG(train,fit);
		fit.train = fitEval(train,fit);
		fit.test = fitEval(test,fit);

	case 'NL'
		
		% iterate between fitting nonlinearities and kernels
		niter = 5;
		for i=1:niter
			fit = fitF(train,fit);
			fit = fitB(train,fit);
		end

		S_ct = zeros(size(train.S_ct_f(:,:,1)));
		for ic=1:fit.c
			prng = fit.f(ic).prng;
			tmp(1,1,:) = fit.f(ic).w;
			S_ct(prng,:) = sum(bsxfun(@times,train.S_ct_f(prng,:,:),tmp),3);
		end
		for ic=1:fit.c
			prng = fit.f(ic).prng;
			normFactor(ic) = std(S_ct(prng(end),:));
		end
		normFactor = vector(repmat(normFactor,fit.n,1));
		
		fit = fitB(train,fit,0,normFactor);
		fit.train = fitEval(train,fit,normFactor);
		fit.test = fitEval(test,fit,normFactor);

end

fit.roiId = train.roiId;