function drawHorzLine(heights,color,style)

% drawHorzLine(heights,color,style)
%
% draws horizontal line at heights in the input

if ~exist('color','var');
  color = 'k';
end

if ~exist('style','var');
  style = '-';
end

tmpProp = get(gca);
xlim = tmpProp.XLim;

for iLine = 1:length(heights)
  h = line([xlim(1) xlim(2)],[heights(iLine) heights(iLine)]);
  set(h,'Color',color);
  set(h,'LineStyle',style);
  uistack(h,'bottom');
end

