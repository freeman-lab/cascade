function data = prepareStim(data,fit)

data.S_ct = reshape(data.S_ctk,fit.c,data.k*round(fit.t*fit.u));

switch fit.type

	case 'L'
		switch fit.samp
			case 'same'
				data.S_ct = makeConvTrialMat(data.S_ct,data.k,fit);		
				data.S_ctk = reshape(data.S_ct,fit.c*fit.n,fit.t,data.k);
			case 'up'
				data.S_ct = downSampTrialMat(data.S_ct,data.k,fit)
				data.S_ct = makeConvTrialMat(data.S_ct,data.k,fit);	
		end
	case 'NL'
		switch fit.samp
			case 'same'
				% generate nonlin transformed version
				[~,data.S_ct_f] = evalNonlinPiecewise(data.S_ct,fit.f,1);
				% make convolutional version	
				convOut = zeros(fit.c*fit.n,size(data.S_ct,2),fit.f(1).m);
				for im=1:fit.f(1).m
					convOut(:,:,im) = makeConvTrialMat(data.S_ct_f(:,:,im),data.k,fit);	
				end
				data.S_ct_f = convOut;

				% make convolutional version of raw input
				data.S_ct = makeConvTrialMat(data.S_ct,data.k,fit);	
				% store trial versions
				data.S_ctk = reshape(data.S_ct,fit.c*fit.n,fit.t,data.k);
				data.S_ctk_f = reshape(data.S_ct_f,fit.c*fit.n,fit.t,data.k,fit.m);
			
			case 'up'
				% APPLY NONLINEARITY THEN DOWNSAMPLE
				% generate nonlin transformed version
				[~,data.S_ct_f] = evalNonlinPiecewise(data.S_ct,fit.f,1);
				% downsample
				downsampOut = zeros(fit.c,fit.t*data.k,fit.f(1).m);
				for im=1:fit.f(1).m
					downsampOut(:,:,im) = downSampTrialMat(data.S_ct_f(:,:,im),data.k,fit);
				end
				data.S_ct_f = downsampOut;
				data.S_ct = downSampTrialMat(data.S_ct,data.k,fit);

				% DOWNSAMPLE AND THEN APPLY NONLINEARITY
				%data.S_ct = downSampTrialMat(data.S_ct,data.k,fit);
				%[~,data.S_ct_f] = evalNonlinPiecewise(data.S_ct,fit.f,1);
				
				% make convolutional version of NL parts
				convOut = zeros(fit.c*fit.n,size(data.S_ct_f,2),fit.f(1).m);
				for im=1:fit.f(1).m
					convOut(:,:,im) = makeConvTrialMat(data.S_ct_f(:,:,im),data.k,fit);	
				end
				data.S_ct_f = convOut;

				% make convolutional version of raw input
				data.S_ct = makeConvTrialMat(data.S_ct,data.k,fit);	
				
				% store trial versions
				data.S_ctk = reshape(data.S_ct,fit.c*fit.n,fit.t,data.k);
				data.S_ctk_f = reshape(data.S_ct_f,fit.c*fit.n,fit.t,data.k,fit.m);
		end
end

data.cv = cvpartition(data.k,'kfold',fit.cv.cvn);

function S_ct = downSampTrialMat(S_ct,k,fit)

t = fit.t;
n = fit.n;
c = fit.c;
u = fit.u;

S_ctk = reshape(S_ct,c,round(u*t),k);
S_ctk_d = zeros(c,t,k);

for ik=1:k
	for ic=1:c
		tmp = S_ctk(ic,:,ik);
		[~,bins] = histc(1:length(tmp),[round(1:fit.u:length(tmp))]);
		binVals = unique(bins);
		binVals = binVals(binVals~=0);
		for it=1:length(binVals)
			S_ctk_d(ic,it,ik) = nanmean(tmp(bins==it));
		end
	end
end
S_ct = reshape(S_ctk_d,c,t*k);

function S_ct = makeConvTrialMat(S_ct,k,fit)

% inputs are the stim by time matrix, the number of trials,
% the time per trial, the number of conditions, and the
% number of time points to estiamte

t = fit.t;
n = fit.n;
c = fit.c;

S_ctk = reshape(S_ct,c,t,k);
S_ctk_v = zeros(c*n,t,k);
warning('off')
for ik=1:k
	S_ctk_v(:,:,ik) = makeStimRows(S_ctk(:,:,ik)',n)';
end
warning('on')
S_ct = reshape(S_ctk_v,c*n,t*k);
