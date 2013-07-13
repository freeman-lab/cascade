function initPrs = initNonLinSpline(f,fOld)

% gets initial parameters for optimization with cubic splines
% given a fit nonlinearity structure (e.g. fit.f), 
% and optionally an earlier estimated nonlinearity

xx = linspace(min(f.knots),max(f.knots),100);

if isempty(f.w)
    % if we haven't estimated a spline yet, set the coefficents
    % based on the choice of initialization
    if strcmp(f.init,'rand')
        % set them randomly
        initPrs = rand(1,size(f.Mspline,2)); 
    elseif strcmp(f.init,'ones')
        % set to all 1s
        initPrs = ones(1,size(f.Mspline,2))*0.1; 
    else
        % find coefficients that give one of the other 
        % nonlinearities availiable in 'evalNonLin'
        tmpNl.type = f.init;
        tmpNl.p(1:2) = f.p;
        yy = evalNonLin(xx,tmpNl);
        [~,~,~,initPrs] = fitSpline(f.knots,xx,yy,f.smoothness,f.extrap);
    end
else
    % find coefficients that give the previously estimated spline
    yy = evalNonLin(xx,fOld);
    [~,~,~,initPrs] = fitSpline(f.knots,xx,yy,f.smoothness,f.extrap);
end