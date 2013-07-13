function [out outRaw] = evalNonlinPiecewise(X,nlParams,solo)

%
% [out outRaw] = evalNonlinPiecewise(X,nlParams)
%
% evaluate a nonlinear function f on X, where f is parameterized as
% as a piecewise sum of nonlinear basis functions
%
% f(.) = sum a_j * h_j(.)
% 
% first output argument is f(X), second is a matrix 
% loaded with h_j(X) for all j
%
% if multiple nonlinearities are passed (as a structure), apply
% each to the specified range of the input
%

if length(nlParams) > 1
	out = zeros(size(X));
	outRaw = zeros([size(X,1) size(X,2) nlParams(1).m]);
	for inl=1:length(nlParams)
		if ~exist('solo','var') || solo == 0
      prng = nlParams(inl).prng;
    else
    	prng = inl;
    end
    [out(prng,:) outRaw(prng,:,:)] = evalNonlinPiecewise(X(prng,:),nlParams(inl));
	end
else
		switch nlParams.type
		case 'tentFunc'
			fname = 'evalTentFunc';
			outRaw = zeros([size(X,1) size(X,2) nlParams.m]);
		  for i=1:nlParams.m
		      outRaw(:,:,i) = feval(fname,X,nlParams.nd(i),nlParams.width);
		  end
		  tmp(1,1,:) = nlParams.w;
		  out = sum(bsxfun(@times,outRaw,tmp),3);
		end
end 