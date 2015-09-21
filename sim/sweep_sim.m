function [ waveform ] = sweep_sim(L, sweep, C, alpha)
% sweep_sim - simulates a CWFM self-mixing signal with the given frequency
% mod waveform
%
% L     - external cavity length
% sweep - vector of wavelengths at each point of the sweep
% C     - Feedback parameter
% alpha - linewidth enhancement factor (optional, default = 5)
%

    if ~exist('alpha', 'var')
        alpha = 5; % (n/a) linewidth enhancement factor    
    end
    
    % generate self-mixing waveforms
    k   = 2 * pi ./ sweep(:);
    phi = 2 * L * k;
        
    waveform = selmixpower_v(C, phi(:), alpha);
end