function [ out ] = apfft2( in, window )
% NB: doesn't actually work
%
    N = (length(in) + 1) / 2;
    
    assert(mod(length(in), 2) == 1); % N must be odd for apfft to work
    
    if nargin < 2
        window = ones(length(in), 1); % no window by default
    end
    
    if iscolumn(window)
        window = window.'; % fix window orientation if we have to
    end
    
    windowed = in .* window;

    f = fliplr(in);
    f = f .* window;
    
    upper = in(1:N-1);
    lower = in(N:length(in));

    folded = fliplr(lower + [0 upper]);
    
    out = fft(folded);
end