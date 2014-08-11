function r2 = getR2(predic,resp)

%
% r2 = getR2(predic,resp)
%
% quick function for getting r2 with a given
% predictor and response
% 

predic = predic(:);
resp = resp(:);
sse = sum((predic-resp).^2);
sst = sum((resp-mean(resp)).^2);
r2 = 1 - sse/sst;