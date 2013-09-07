function out = collectFit(fit,collectType)

	switch collectType
	case 'cv'
		out.r2 = fit.test.r2;
		out.r = fit.test.r;
	case 'boot'
		out.f = cat(1,fit.f(:).w);
		out.B_q = fit.B_q;
	case 'rnd'
		out.f = cat(1,fit.f(:).w);
		out.B_q = fit.B_q;
		out.r = fit.train.r;
	end