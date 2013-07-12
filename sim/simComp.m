function compSimFit(sim,fit)

% 
% compSimFit(sim,fit)
%
% plot a comparison between simulated parameters and fitting results
%

clf

switch fit.type
case 'L'
	fit_B_q = fit.B_q/max(fit.B_q);
	sim_B_q = sim.B_q/max(sim.B_q);

	mxY = max(fit_B_q);
	mnY = min(fit_B_q);

	fit_B_qc = reshape(fit_B_q,fit.q/fit.c,fit.c);
	sim_B_qc = reshape(sim_B_q,fit.q/fit.c,fit.c);

	for ic=1:fit.c
		sanesubplot(fit.c,2,{ic 2},0.1);
		hold on
		plot(sim_B_qc(:,ic),'k','LineWidth',5);
		plot(fit_B_qc(:,ic),'r','LineWidth',2);
		ylim([mnY mxY]);
		box off; set(gca,'TickDir','out');
	end

case 'NL'
	fit_B_q = fit.B_q/max(fit.B_q);
	sim_B_q = sim.B_q/max(sim.B_q);

	mxY = max(fit_B_q);
	mnY = min(fit_B_q);

	fit_B_qc = reshape(fit_B_q,fit.q/fit.c,fit.c);
	sim_B_qc = reshape(sim_B_q,fit.q/fit.c,fit.c);

	for ic=1:fit.c
		sanesubplot(fit.c,2,{ic 1},0.1);
		x = linspace(fit.f(ic).mnVal,fit.f(ic).mxVal,100);
		hold on
		plot(x,evalNonLin(x,sim.f(ic)),'k','LineWidth',5);
		plot(x,evalNonlinPiecewise(x,fit.f(ic)),'b','LineWidth',2);
		hold off
		box off; set(gca,'TickDir','out');

		sanesubplot(fit.c,2,{ic 2},0.1);
		hold on
		plot(sim_B_qc(:,ic),'k','LineWidth',5);
		plot(fit_B_qc(:,ic),'r','LineWidth',2);
		ylim([mnY mxY]);
		box off; set(gca,'TickDir','out');
	end
end
