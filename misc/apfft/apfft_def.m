function [ out ] = apfft_def( in, N )
% apfft implemented as defined by the matrix shifts and whathaveyou
% kinda slow, it's here more as a reference than anything practical

    sums = zeros(1, N);

    for i = 1:N
        subseq = in(i:i+N-1);
        center = N - i + 1; %position of the 'center' element
        
        % shift vector so that the center element is at subseq(1)
        subseq = circshift(subseq, [0 -(center-1)])
        
        sums = sums + subseq;
    end
    
    out = fft(sums ./ N);
end

