function plotFit(fit,clrs,labels)

clf
set(gcf,'Position',[400 0 650 700]);
%clrs{1} = [0 0 1];
%clrs{2} = [0 0 0.5];
%clrs{2} = [1 0 0];
%clrs{3} = [0.5 0 0];

subplot(3,2,1);
set(gca,'FontSize',16);
filts = reshape(fit.B_q,fit.n,fit.c);
for ic=1:fit.c
	hold on
	plot(linspace(fit.n/7,0,fit.n),filts(:,ic),'Color',clrs{ic},'LineWidth',3);
end
box off;
xlim([0 fit.n/7]);
set(gca,'XDir','reverse');
set(gca,'TickDir','out');
drawHorzLine(0);
ylabel('Change in dF/F');
xlabel('Time before response');
title(sprintf('Derived kernels, ROI: %g',fit.roiId));
subplot(3,2,2);
set(gca,'FontSize',16);
plotNonLin(fit.g);
title('Output nonlinearity');

switch fit.type
case 'L'
	subplot(3,1,2);
	set(gca,'FontSize',16);
	hold on
	plot(fit.test.R_t,'k','LineWidth',5);
	plot(fit.test.Z_t,'r','LineWidth',5);
	title(sprintf('r train: %.2g, r test: %.2g',fit.train.r,fit.test.r));
	legend({'Response','Fit'})
case 'NL'

	for ic=1:fit.c
		sanesubplot(3,fit.c,{2 ic});
		set(gca,'FontSize',16);
		x = linspace(fit.f(ic).nd(1),fit.f(ic).nd(end),100);
		y = evalNonlinPiecewise(x,fit.f(ic));
		x = x*fit.stats.std(ic) + fit.stats.mn(ic);
		hold on
		h = plot(x,y);
		set(h,'LineWidth',3,'Color',clrs{ic});
		ylim([0 1]);
		xlabel(sprintf('%s input',labels{ic}));
		ylabel(sprintf('%s output',labels{ic}));

	end

	subplot(3,1,3);
	set(gca,'FontSize',16);
	hold on
	plot(fit.test.R_t,'k','LineWidth',5);
	plot(fit.test.Z_t,'LineWidth',5,'Color',[0.5 0.5 0.5]);
	title(sprintf('r train: %.2g, r test: %.2g',fit.train.r,fit.test.r));
	legend({'Response','Fit'})
	ylabel('dF/F');
	xlabel('Time point');


end