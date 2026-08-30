%  testAIC.m

function [AIC, AICc, nAIC, BIC] = testAIC(a, th, yFit, PlotOn)
	% 
	% 	a is the actual vector of y
	% 	yFit is the fit
	% 	th is the coeff
	% 
	if nargin < 4
		PlotOn = true;
	end
	% 
	% 	Get residuals
	% 
	r = yFit - a;
	% 
	%	Display residuals 
	% 
	if PlotOn
		figure, 
	    s = scatter(yFit, r, 'filled','SizeData',10);
		alpha(s,.01)
		title('Residuals vs yFit')
		ylabel('Residual ri = (yFit - a)')
		xlabel('yFit values')
	end
	% 
	% 	Parameters
	% 
	N = numel(a); 		% the number of values being estimated
	E_t = r;			% vector of errors at each timepoint
	n_p = numel(th);	% number of parameters
	n_y = numel(yFit);	% number of model outputs
	% 
	% 	Raw AIC
	% 
	AIC_raw = N*log(det(1/N*sum(r*r'))) + 2*n_p + N*(n_y*(log(2*pi)+1));
	AIC = AIC_raw;
	% 
	% 	Small-sample corrected AIC
	% 
	AICc = AIC_raw + 2*n_p*(n_p+1)/(N-n_p-1);
	% 
	% 	Normalized AIC
	% 
	nAIC = log(det(1/N*sum(r*r'))) + 2*n_p/N;
	% 
	% 	BIC
	% 
	BIC = N*log(det(1/N*sum(r*r'))) + N*(n_y*log(2*pi) + 1) + n_p*log(N);

end