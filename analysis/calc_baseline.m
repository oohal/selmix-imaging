function [ baseline, period, threshold ] = calc_baseline( capture )
    selmix  = capture(:,1);   
    threshold = max(diff(selmix)) / 3;

    % try to extract a single period, trigger off the rising edge of the
    % reference

    if threshold < 0
        possible = find(diff(selmix) < threshold);
    else
        possible = find(diff(selmix) > threshold);
    end
    
    if isempty(possible)
        error('No starts detected, check capture');
    end
    
    d2 = diff(possible);
    m = mean(d2)/2;    
    starts = possible(d2 > m);
    
    periods = length(starts);
    period  = round(mean(diff(starts)));
    
    baseline = zeros(period, 1);
    
    for i = 1: periods - 1 
        baseline = baseline + selmix(starts(i) + [0:period-1]);
    end
    
    baseline = baseline ./ (periods - 1);
end

