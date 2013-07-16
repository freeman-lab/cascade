function [train test] = prepareRoi(d,fit,iroi,icv,bootsmp,rndsmp)

%
% [train test] = prepareRoi(d,fit,iroi,icv,bootsmp,rndsmp)
%
% load train and testing stim and response
% for cross-validation:
% 	set 'icv' to the fold of cross-validation we want
%	train/test indices must be in fit.cv
% for bootstrapping:
%	set 'bootsmp' to 1 
%


% check how many trials have NaNs or 0s
R_tk = squeeze(d.R_ntk(iroi,:,:));
badTrials = (sum(isnan(R_tk)) == d.t);
if sum(~badTrials) < 2
	train = [];
	test = [];
	fprintf('(getRoi) fewer than 50 trials without NaNs, skipping roi\n');
	return
end

% do cross validation splitting
if ~exist('icv','var') || icv == 0
	trainInds = [1:d.k]';
	testInds = 1;
else
	trainInds = find(fit.cv.obj.training(icv));
	testInds = find(fit.cv.obj.test(icv));
end

% resample trials with replacement
if exist('bootsmp','var') && bootsmp == 1
	bootInds = ceil(rand(1,length(trainInds))*length(trainInds));
	trainInds = trainInds(bootInds);
end

train.trainInds = trainInds;
test.testInds = testInds;
train.k = length(trainInds);
test.k = length(testInds);

% form complete predictor and response matrices
train.S_ct = reshape(d.S_ctk(:,:,trainInds),fit.c*fit.n,length(trainInds)*fit.t);
test.S_ct = reshape(d.S_ctk(:,:,testInds),fit.c*fit.n,length(testInds)*fit.t);
if strcmp(fit.type,'NL')
	train.S_ct_f = reshape(d.S_ctk_f(:,:,trainInds,:),fit.c*fit.n,length(trainInds)*fit.t,fit.m);
	test.S_ct_f = reshape(d.S_ctk_f(:,:,testInds,:),fit.c*fit.n,length(testInds)*fit.t,fit.m);
end

% get randomized version of data if requested
if exist('rndsmp','var') && rndsmp
	train.R_t = reshape(d.rnd.R_ntk(iroi,:,train.trainInds,rndsmp),1,length(train.trainInds)*fit.t);
	test.R_t = reshape(d.rnd.R_ntk(iroi,:,test.testInds,rndsmp),1,length(test.testInds)*fit.t);
else
	train.R_t = reshape(d.R_ntk(iroi,:,train.trainInds),1,length(train.trainInds)*fit.t);
	test.R_t = reshape(d.R_ntk(iroi,:,test.testInds),1,length(test.testInds)*fit.t);
end

if isfield(d,'roiIds')
	train.roiId = d.roiIds(iroi);
	test.roiId = d.roiIds(iroi);
else
	train.roiId = iroi;
	test.roiId = iroi;
end







