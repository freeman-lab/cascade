function [r Z_t R_t testInds] = crossVal(d,fit,irnd,iroi)

	Z_t = [];
	R_t = [];
	testInds = [];
	for icv=1:fit.cv.n
		if exist('irnd','var') && ~isempty(irnd)
			[train test] = prepareRoi(d,fit,iroi,icv,0,irnd);
		else
			[train test] = prepareRoi(d,fit,iroi,icv);
		end
		fittmp = fitInit(d,fit.type,fit.error,fit.n);
		fittmp = fitDo(train,test,fittmp);
		Z_t = [Z_t fittmp.test.Z_t];
		R_t = [R_t fittmp.test.R_t];
		testInds = [testInds; test.testInds];
	end
	r = corrcoef(Z_t,R_t);
	r = r(1,2);