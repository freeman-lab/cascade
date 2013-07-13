function plotNonLinSpline(nl,clr,plotType)

%-------------------------------------------
%
% plotNonLinSpline(nl)
%
% plot a nonlinearity
%
% inputs:
% nl -- structure containing the parameters
%       of a nonlinearity (see 'evalNonLin.m')
% 
% optional inputs:
% clr -- color of plotted line (default = 'k')
%
% freeman, 4-8-2012
%-------------------------------------------

if ~exist('clr','var')
    clr = 'k';
end

if ~exist('plotType','var')
    plotType = 'dots';
end


res = 100;
if ~isfield(nl,'rng')
    defMn = -2.5;
    defMx = 2.5;
else
    defMn = nl.rng(1);
    defMx = nl.rng(2);
end

switch nl.type
    case {'splinePos','spline'}
        if isempty(nl.w);
            % if the weights aren't defined,
            % we'll just plot the initialization
            tmpnl.type = nl.init;
            xx = linspace(defMn,defMx,res);
            f = evalNonLin(xx,tmpnl);
        else
            % if the weights are defined,
            % plot the nonlinearity at its node points
            mnVal = nl.knots(1);
            mxVal = nl.knots(end);
            xx = linspace(mnVal,mxVal,res);
            f = evalNonLin(xx,nl);
        end
    otherwise
        xx = linspace(defMn,defMx,res);
        f = evalNonLin(xx,nl);
end

hold on
rangeValsXX = range(xx);
rangeValsF = range(f);
xBoundLow = min(xx(:))-0.1*rangeValsXX;
xBoundHigh = max(xx(:))+0.1*rangeValsXX;
yBoundLow = min(f(:))-0.1*rangeValsF;
yBoundHigh = max(f(:))+0.1*rangeValsF;

if xBoundLow > 0
    xBoundLow = -0.5;
end
%if yBoundLow > -0.3
%    yBoundLow = -0.3;
%end
%if yBoundHigh < 1
%    yBoundHigh = 1.1;
%end

%plot([xBoundLow xBoundHigh],[xBoundLow xBoundHigh],'Color',[0.5 0.5 0.5],'LineStyle',':');
%plot([xBoundLow xBoundHigh],[-xBoundLow -xBoundHigh],'Color',[0.5 0.5 0.5],'LineStyle',':');
axis equal tight
hold on


if strcmp(nl.type,'spline') && strcmp(plotType,'dots')
  hdots = plot(nl.knots,evalNonLin(nl.knots,nl),strcat(clr,'.'));
  set(hdots,'MarkerSize',20);
end
hline = plot(xx,f,clr);

axis tight
xlim([xBoundLow,xBoundHigh]);
ylim([yBoundLow,yBoundHigh]);
set(gca,'TickDir','out');
set(hline,'LineWidth',2);
set(gca,'XTick',[fix(xBoundLow),max(fix(xBoundHigh),1)]);
%set(gca,'YTick',[fix(yBoundLow),fix(yBoundHigh)]);
set(gca,'YTick',[(yBoundLow),(yBoundHigh)]);
drawVertLine(0,[0 0 0],'--');
drawHorzLine(0,[0 0 0],'--');

box off;
hold off