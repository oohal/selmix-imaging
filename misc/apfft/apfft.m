function [ out ] = apfft( in, window )
% apfft - takes a vector of length 2*N-1 and computes the N point all phase
% FFT.

    assert(mod(length(in), 2) == 1, 'apfft input vector length must be odd');
    N = (length(in) + 1) / 2;
    
    if nargin < 2
        window = ones(size(in)); % default to no window
    end
    
    windowed = in(:) .* window(:);
    
    % summing all the shifted input vectors boils down to this
    %
    % FIXME: this could be made much simpler
    
    f1 = zeros(N, 1); f1(1) = N * windowed(N);
    f2 = zeros(N, 1); f2(1) = 0;

    for i = 1:N-1
        f1(i+1) = (N - i) * windowed(N + i);
        f2(i+1) = i       * windowed(i);
    end
    
    folded = f1 + f2;
    out = fft(folded ./ N);

    % fix the output orientation if we have to
    if iscolumn(in) ~= iscolumn(out)
        out = transpose(out);
    end
end