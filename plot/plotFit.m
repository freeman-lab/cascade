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
if isfield(fit.boot,'out')
	filtslow = prctile([fit.boot.out(:).B_q],16,2);
	filtshigh = prctile([fit.boot.out(:).B_q],84,2);
	filtsmed = prctile([fit.boot.out(:).B_q],50,2);
	filtsmed = reshape(filtsmed,fit.n,fit.c);
	filtslow = reshape(filtslow,fit.n,fit.c);
	filtshigh = reshape(filtshigh,fit.n,fit.c);
end
for ic=1:fit.c
	hold on
	if isfield(fit.boot,'out')
		plot(linspace(fit.n/7,0,fit.n),filtsmed(:,ic),'Color',clrs{ic},'LineWidth',3);
		plot(linspace(fit.n/7,0,fit.n),filtslow(:,ic),'Color',clrs{ic},'LineWidth',1);
		plot(linspace(fit.n/7,0,fit.n),filtshigh(:,ic),'Color',clrs{ic},'LineWidth',1);
	else
		plot(linspace(fit.n/7,0,fit.n),filts(:,ic),'Color',clrs{ic},'LineWidth',3);
	end
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
		xtrans = x*fit.stats.std(ic) + fit.stats.mn(ic);
		y = evalNonlinPiecewise(x,fit.f(ic));
		hold on
		if isfield(fit.boot,'out')
			fboot = [fit.boot.out(:).f];
			errlow = prctile(fboot((ic-1)*fit.m+1:ic*fit.m,:),16,2);
			errhigh = prctile(fboot((ic-1)*fit.m+1:ic*fit.m,:),84,2);
			errmid = prctile(fboot((ic-1)*fit.m+1:ic*fit.m,:),50,2);
			tmp = fit.f(ic);
			tmp.w = errlow; 
			errlow = evalNonlinPiecewise(x,tmp);
			tmp.w = errhigh;
			errhigh = evalNonlinPiecewise(x,tmp);
			tmp.w = errmid;
			errmid = evalNonlinPiecewise(x,tmp);
			plot(xtrans,errlow,'Color',clrs{ic});
			plot(xtrans,errhigh,'Color',clrs{ic});
			h = plot(xtrans,errmid);
			set(h,'LineWidth',3,'Color',clrs{ic});
		else
			h = plot(xtrans,y);
			set(h,'LineWidth',3,'Color',clrs{ic});
		end
		xlim([min(xtrans) max(xtrans)]);
		ylim([0 1])
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


if isfield(fit.boot,'out') && fit.c==2
	normval = getNorm(reshape(fit.B_q,fit.n,fit.c),'L2',1);
	rndWeight = reshape([fit.rnd.out(:).B_q],fit.n,fit.c,fit.rnd.n);
	bootWeight = reshape([fit.boot.out(:).B_q],fit.n,fit.c,fit.rnd.n);
	for ic=1:fit.c
		rndNorm(ic,:) = getNorm(squeeze(rndWeight(:,ic,:)),'L2',1);
		bootNorm(ic,:) = getNorm(squeeze(bootWeight(:,ic,:)),'L2',1);
	end
	if fit.c==2
		frac = normval / sum(normval);
		rndFrac = rndNorm(1,:)./(rndNorm(1,:)+rndNorm(2,:));
		bootFrac = bootNorm(1,:)./(bootNorm(1,:)+bootNorm(2,:));
	end
	bins = linspace(0,1,20);
	h1 = hist(rndFrac,bins);
	h2 = hist(bootFrac,bins);
	figure;
	set(gca,'FontSize',16);
	hold on
	plot(bins,h1/sum(h1),'Color',[0.5 0.5 0.5],'LineWidth',3);
	plot(bins,h2/sum(h2),'Color',[0.1 0.1 0.1],'LineWidth',3);
	drawVertLine(frac(1));
	xlim([0 1]);
	set(gca,'TickDir','out');
	xlabel('Touch / (Touch + Whisk)')
	ylabel('Fraction of distribution')
end