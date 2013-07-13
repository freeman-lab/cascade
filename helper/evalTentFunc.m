function y = evalTentFunc(x,c,dc)

x = ((x-c)/dc);

y = zeros(size(x));
y(isnan(x)) = NaN;
inds1 = x >= 0 & x < 1;
y(inds1) = 1-x(inds1);
inds2 = x < 0 & x > -1;
y(inds2) = x(inds2)+1;



