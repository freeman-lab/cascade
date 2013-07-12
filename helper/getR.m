function r = getR(predic,resp)

%
% r = getR(predic,resp)
%
% quick function for getting r2 with a given
% predictor and response
% 

r = corrcoef(predic,resp);
r = r(1,2);