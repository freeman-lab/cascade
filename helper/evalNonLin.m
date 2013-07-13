function [out df dff] = evalNonLin(x,nlParams)

%-------------------------------------------
%
% evalNonLin(x,nlParams)
%
% get outputs and derivitives for several 
% different nonlinearities f(x)
%
% inputs:
% x -- the input over which to evaluate the nonlinearity
% nlParams -- structure parameterizing the nonlinearitiy
%             contains the fields:
%             type -- options are 'linear','square',
%                     'rectLinear','halfSquare',
%                     'rectLinearNeg','halfSquareNeg',
%                     'exp','logexp1','logexp1neg'
%             p -- parameters controlling the nonlinearity
%
% outputs:
% out -- f(x)
% df -- d/dx f(x)
% dff -- d^2/d^2x f(x)
%
% freeman, 1-1-2012
%-------------------------------------------


if length(nlParams) > 1
    % if passed an struct array of nonlinearities
    % loop over the whole input, applying nonlin to each subgroup
    out = zeros(size(x));
    df = out;
    dff = out;
    for inl = 1:length(nlParams)
        prng = nlParams(inl).prng;
        [out(prng,:) df(prng,:) dff(prng,:)] = evalNonLin(x(prng,:),nlParams(inl));
    end

else
    % if the nonlinearity is a spline but we haven't defined its
    % parameters yet, use the initialization instead
    if strcmp(nlParams.type,'spline') || strcmp(nlParams.type,'splinePos')
        if isempty(nlParams.w)
            nlParams.type = nlParams.init;
            nlParams.p(1) = 0;
        end 
    end

    % get the output and derivs for lots of different nonlinearities
    switch nlParams.type
        case 'linear'
            % params: p(1) = c (constant)
            out = (x-nlParams.p(1));
            if nargout > 1
                df = ones(size(out)); % df is 1 everywhere
            end
            if nargout > 2
                dff = zeros(size(out));
            end
        case 'square'
            % params: p(1) = c (constant)
            out = (x-nlParams.p(1)).^2;
            if nargout > 1
                df = 2*(x-nlParams.p(1)); % df is 2x
            end
            if nargout > 2
                dff = 2*ones(size(out)); % dff is 2 everywhere
            end
            
        case 'rectLinear'
            % params: p(1) = c (constant)
            out = max(nlParams.p(1),x)-nlParams.p(1);
            if nargout > 1
                df = double(x>nlParams.p(1)); % df is 1 when x is greater than 0
            end
            if nargout > 2
                dff = zeros(size(out));
            end
            
        case 'halfSquare'
            % params: p(1) = c (constant)
            out = (max(nlParams.p(1),x)-nlParams.p(1)).^2;
            if nargout > 1
                df = 2*(double(x>nlParams.p(1)).*x); % df is 2x when x is greater than c
            end
            if nargout > 2
                dff = 2*(double(x>nlParams.p(1))); % dff is 2 when x is greater than 
            end
            
        case 'rectLinearNeg'
            % params: p(1) = c (constant)
            out = abs(min(nlParams.p(1),x)-nlParams.p(1));
            if nargout > 1
                df = -1*double(x<nlParams.p(1)); % df is -1 when x is less than 0
            end
            if nargout > 2
                dff = zeros(size(out));
            end
            
        case 'halfSquareNeg'
            % params: p(1) = c (constant)
            out = (abs(min(nlParams.p(1),x)-nlParams.p(1))).^2;
            if nargout > 1
                df = -2*(double(x<nlParams.p(1)).*x); % df is -2x when x is less than constant
            end
            if nargout > 2
                dff = -2*(double(x>nlParams.p(1))); % dff is -2 when x is less than constant
            end
        case 'exp'
            % params: p(1) = c (constant)
            out = exp(x-nlParams.p(1));
            if nargout > 1
                df = out; % df and dff are both exp
            end
            if nargout > 2
                dff = out;
            end
            
        case 'logexp1'
            % params: p(1) = c (constant)
            %         P(2) = r (power)
            pow = 1;
            out0 = log(1+exp(x-nlParams.p(1)));
            out = out0.^pow;
            if nargout > 1
                df = pow*out0.^(pow-1).*exp(x-nlParams.p(1))./(1+exp(x-nlParams.p(1)));
            end
            if nargout > 2
                dff = pow*out0.^(pow-1).*exp(x-nlParams.p(1))./(1+exp(x-nlParams.p(1))).^2;
            end
            
        case 'logexp1neg'
            % params: p(1) = c (constant)
            %         P(2) = r (power)
            pow = nlParams.p(2);
            out0 = log(1+exp(-(x-nlParams.p(1))));
            out = out0.^pow;
            if nargout > 1
                df = -pow*out0.^(pow-1).*exp(-(x-nlParams.p(1)))./(1+exp(-(x-nlParams.p(1))));
            end
            if nargout > 2
                dff = pow*out0.^(pow-1).*exp(-(x-nlParams.p(1)))./(1+exp(-(x-nlParams.p(1)))).^2;
            end
            
        case 'loglinear'
            % params: p(1) = c (constant)
            %         p(2) = b (scale factor)
            %         p(3) = a (scale factor outside)
            %         p(4) = d (constant controlling linearity)
            a = nlParams.p(1);
            b = nlParams.p(2);
            %c = nlParams.p(3);
            d = nlParams.p(3);
            e = nlParams.p(4);
            out = d*((log(1+exp(b*x+a)))) + e;
            % these are wrong!
            if nargout > 1
                %df = b * c * exp(b*x+a) ./ (d + exp(b*x + a));
                df = b * exp(d)*log(1+exp(b*x+a)).^(exp(d)-1) .* exp(b*x+a) ./ (1 + exp(b*x + a));
            end
            if nargout > 2
                %dff = b^2 * c * d * exp(b*x + a) ./ (d + exp(b*x+a)).^2;
                q = exp(b*x+a);
                term1 = (exp(d)-1)*log(1+q).^(exp(d)-2)*b.*q.^2;
                term2 = q.*b.*log(1+q).^(exp(d)-1).*(1+q) - b*q.^2;
                dff = b*exp(d).*(term1 + term2)./(1+q).^2;
            end
            
        case 'cumnorm'
            a = nlParams.p(1);
            b = nlParams.p(2);
            c = nlParams.p(3);
            d = nlParams.p(4);
            out = c*normcdf(b*x + a) + d;
      
        case 'polynomial'
            a = nlParams.p(1);
            b = nlParams.p(2);
            c = nlParams.p(3);
            d = nlParams.p(4);
            e = nlParams.p(5);
            out = a*x + b*x.^2 + c*x.^3 + d*x.^4 + e*x.^5;
            
        case {'spline','splinePos'}
            [fhand pp] = makeSplineFun(nlParams.knots,nlParams.Mspline*nlParams.w(:));
            out = fhand(x);
            if nargout > 1
                %[breaks,coefs,l,k,d] = unmkpp(pp);
                %pp2 = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
                %dfhand = @(x) ppval(pp2,x);
                %df = dfhand(x);
                p_der = fnder(pp,1);
                df = ppuval(x,p_der);
            end
            if nargout > 2
                %[breaks,coefs,l,k,d] = unmkpp(pp2);
                %pp3 = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
                %dffhand = @(x) ppval(pp3,x);
                %dff = dffhand(x);
                p_der_2 = fnder(pp,2);
                dff = ppuval(x,p_der_2);
            end
    end
end