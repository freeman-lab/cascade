function data = removeNaNs(data,fit)

	% remove any time points with nans
	% remove any trials where response is NaN or 0 throughout

	switch fit.type
	case 'L'

		% reshape and remove trials that are all nans or zeros
		R_tk = reshape(data.R_t,fit.t,data.k);
		S_ctk = reshape(data.S_ct,fit.c*fit.n,fit.t,data.k);
		badTrials = (sum(isnan(R_tk)) == fit.t) | sum(abs(R_tk))==0;
		data.k = sum(~badTrials);
		data.S_ct = reshape(S_ctk(:,:,~badTrials),fit.c*fit.n,fit.t*data.k);
		data.R_t = reshape(R_tk(:,~badTrials),1,fit.t*data.k);

		% remove time points with nans
		badInds = isnan(sum(data.S_ct,1)) | isnan(data.R_t);
		data.S_ct = data.S_ct(:,~badInds);
		data.R_t = data.R_t(~badInds);

	case 'NL'

		% reshape and remove trials that are all nans or zeros
		R_tk = reshape(data.R_t,fit.t,data.k);
		S_ctk_f = reshape(data.S_ct_f,fit.c*fit.n,fit.t,data.k,fit.m);
		badTrials = (sum(isnan(R_tk)) == fit.t) | sum(abs(R_tk))==0;
		data.k = sum(~badTrials);
		data.S_ct_f = reshape(S_ctk_f(:,:,~badTrials,:),fit.c*fit.n,fit.t*data.k,fit.m);
		data.R_t = reshape(R_tk(:,~badTrials),1,fit.t*data.k);

		% remove time points with nans
		badInds = isnan(sum(sum(data.S_ct_f,3),1)) | isnan(data.R_t);
		data.S_ct_f = data.S_ct_f(:,~badInds,:);
		data.R_t = data.R_t(~badInds);

	end