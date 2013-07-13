function f = initSpline(f)

% initialize a spline nonlinearity structure for
% use with various fitting code

f.init = f.type;
f.type = 'spline';
f.p = f.p;
f.nknots = 8;
f.smoothness = 3;
f.extrap = 1;
f.w = [];