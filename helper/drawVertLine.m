function drawVertLine(cols,color,style)

% drawVertLine(heights,color,style)

% draws vertical lines at heights in the input

if ~exist('color','var');
  color = 'k';
end

if ~exist('style','var');
  style = '-';
end

tmpProp = get(gca);

ylim = tmpProp.YLim;

for iLine = 1:length(cols)
  h = line([cols(iLine) cols(iLine)],[ylim(1) ylim(2)]);
  set(h,'Color',color);
  set(h,'LineStyle',style);
  uistack(h,'bottom');
end
