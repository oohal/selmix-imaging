% reproduction of the example in xiangdong2008
% http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=4697084

freq      = [50.3 85.33 121.72];
phase     = [10 20 30];
amplitude = [2 2 2];

Fs = 256;
N  = 256;
n  = -N+1:N-1; % apfft needs 2N-1 input points


%% generate signal
signal = zeros(size(n));

for i = 1:length(freq);
    f = 2 * pi * freq(i) / Fs;
    p = phase(i) * pi / 180;
    
    signal = signal + amplitude(i) * cos(f * n + p);
end

%% crunch numbers
fftwindow = hanning(N)';
apwindow  = conv(fftwindow, fftwindow);

% Something to note: The FFT uses the first time domain sample as the phase
% reference while the apFFT uses the central (Nth) sample.

reg = fft(signal(N:2*N-1) .* fftwindow);
ap  = apfft(signal, apwindow);

% only take lower half
reg = reg(1:N/2); 
ap  = ap(1:N/2);

% normalise
reg = reg ./ max(abs(reg));
ap  =  ap ./ max(abs(ap));


%% do plots
bins = [0:length(reg) - 1] ./ N * Fs;

figure; clf;
subplot(211); hold on; 
    plot(bins, abs(reg), 'b'); 
    plot(bins, abs(ap), 'r');
    title('Magnitude spectrum (linear scale)');
    
subplot(212); hold on; 
    plot(bins, rad2deg(angle(reg)), 'b'); 
    plot(bins, rad2deg(angle(ap)), 'r');
    title('Phase spectrum (deg)');
    