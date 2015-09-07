function [phases, peaks, rms_amp, specs] = analyze(data, baseline, period, threshold, avgs, ref)
    % Split the data into waveforms for each period. This needs a bit of care
    % since the function gen and the DAQ's sampling clock aren't perfect so
    % there's a bit of frequency jitter. If you resync based on the rising edge
    % it's mostly ok though.

    tic;

%    [baseline, period, threshold] = calc_baseline(bl_data);

    if exist('ref', 'var')
        ref_th = -1.5; % threshold for a "period reset" from the reference

        r_start = period + sync_to(ref(period:3*period), period, ref_th);

        % we need to skip the initial data period since the filtering transient
        % alters things, we also need to ensure the first reference edge and the
        % first waveform are aligned.

        min_start = floor(r_start - period/2); min_start = max([1 min_start]);
        max_start = floor(r_start + period);

        d_start = min_start + sync_to(data(min_start:max_start), period, threshold);

        skew = d_start - r_start;
    else
        % otherwise just use the main waveform as the reference channel too
        ref = data;
        skew = 0;
        ref_th = threshold;
    end

%    fprintf('sync took: %.2f\n', toc());

    periods = floor(length(data) / period);
    starts = zeros(periods, 1);

    averaged = zeros(1, period); % stores the averaged signal

    % we only take a segment of each period, after averaging
    trunc_start = floor(period * 0.4);
    trunc_end   = ceil(period  * 0.9);
    truncated   = trunc_start:trunc_end;

    % fft processing
    window = hann(length(truncated));

    phases  = zeros(length(averaged), 1);
    peaks   = zeros(length(averaged), 1);
    rms_amp = zeros(length(averaged), 1);
    
    % i is the index of the current extracted period
    % j is the index into the raw waveform
    i = 1;
    
    for j = 1:period:length(data) - 2*period
        [start, found] = sync_to(ref(j:j+2*period), period, ref_th);
        first = start + j + skew;
        last  = first + period - 1;
        
        % in this case we were unable to find a fringe signal in this
        % capture so just return.
        if ~found 
            peaks   = 0;
            phases  = 0;
            rms_amp = 0;
            
            specs   = {};
            
            return;
        end
        
        starts(i) = first;

        % extract the current period 
        %
        % FIXME: this could be brittle since the period may change slightly
        %         due to jitter.
        %
        waveform = data(first:last);
        
        % handle waveform averaging
        averaged = averaged(:) + waveform(:); % compute the rolling average

        if i > avgs
            first = starts(i - avgs);
            last  = starts(i - avgs) + period - 1;

            averaged = averaged - data(first:last);
        end

        % truncate and remove the baseline
        working = averaged(truncated) ./ avgs - baseline(truncated);
        working = working - mean(working);
        
        spec = fft(window .* working);

        % find the spectral peak
        [~, b] = max(abs(spec(1:floor(period/2))));

        peaks(i)  = b;
        phases(i) = angle(spec(b));
        rms_amp(i) = rms(working);

        % just store the lower half of the spectrum
        specs(:, i) = spec(1:floor(period/2));

        i = i + 1;
    end

    waveforms = i - 1;
    peaks = peaks(1:waveforms);
    rms_amp = rms_amp(1:waveforms);
    
    % Due to noise the spectral peak will occasionally shift to another bin
    % to avoid errors from this we track the phase of the most common peak 
    % value.
    actual_peak = mode(peaks);
    
    phases = zeros(waveforms, 1);
    
    for i = 1:waveforms
       spec = specs(:,i);
       phases(i) = angle(spec(actual_peak));
    end

%    fprintf('analyze took %.2fs\n', toc());
end