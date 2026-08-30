function corrected_signal = correct_stim_by_single_trial_step(obj,signal_to_correct, samples_to_measure_on_either_side)
% 
% 	We see that the optical artifact of stimulation onsets immediately, whereas the change of the biological effect is slower
%	We can thus correct the artifact by getting rid of the step on single trials
% 

	if nargin < 2
		signal_to_correct = obj.GLM.rawF;
	end
	if nargin < 3
		samples_to_measure_on_either_side = 20;
	end

	upTimes = obj.GLM.ChR2values > 1.5;
	%
	% flick_pos = nan(obj.iv.num_trials,1);
	% flick_pos(obj.GLM.fLick_trial_num) = obj.GLM.pos.flick;
	% for itrial = 1:obj.iv.num_trials
	% 	% get stim flanking

	% get all the stim time starts
    if numel(signal_to_correct)+2 < numel(upTimes)
        warning(['unexpected sampling rate for ChR2, ratio is ' numel(upTimes)/numel(signal_to_correct)])
        upTimes = upTimes(1:2:end);
    end
	up_starts = find([upTimes(2:end) - upTimes(1:end-1)] == 1);
	up_ends = find([upTimes(2:end) - upTimes(1:end-1)] == -1);
	correction = nan;
	for ii = 1:numel(up_starts)
		% for each stim, check that enough time has elapsed, otherwise use previous correction
		if ii > 1 && up_starts(ii) - up_starts(ii-1) < samples_to_measure_on_either_side
			correction = correction; % reuse the previous correction
		else
			sig_left = signal_to_correct(up_starts(ii) - samples_to_measure_on_either_side:up_starts(ii)-1);
			sig_right = signal_to_correct(up_starts(ii):up_starts(ii) + samples_to_measure_on_either_side);
			correction = median(sig_right) - median(sig_left);
			% [f,ax] = makeStandardFigure(2,[1,2]);
			% histogram(ax(1), sig_left);
			% histogram(ax(2), sig_right);
		end
		signal_to_correct(up_starts(ii):up_ends(ii)) = signal_to_correct(up_starts(ii):up_ends(ii)) - correction;
		% need to remove the points on either side of up-starts
		signal_to_correct(up_starts(ii)-2:up_starts(ii)+2) = nan;
		signal_to_correct(up_ends(ii)-2:up_ends(ii)+2) = nan;
	end

	signal_to_correct = fillmissing(signal_to_correct, 'linear');

	corrected_signal = signal_to_correct;
end



