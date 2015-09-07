%% apFFT notes:
%
% I think it works like this: 
%
% If no window is used, abs(ap_spec) == abs(fft_spec) .^ 2
%
% In the apFFT the phase reference is the center point of the time domain
% signal (i.e for samples x(1:2N-1) it'll be x(N)). If the phase of your 
% signal seems to increase/decrease monotonicly compared to what you expect
% make sure x(N) is where t = 0.
%
% most of the deviations are for a single frequency sinusiod input. Things
% get a bit handwavy with more complex inputs, but supposedly so long as
% the tones are well seperated in the frequecy domain (i.e not leaking into
% each other) the computed phase should be accurate.
%
% The signal flow diagram has the coefficents that you get from summing the
% different sequences baked into the window coefficents.
%

%% signals from Sun2012
% http://link.springer.com/chapter/10.1007%2F978-3-642-31516-9_74
% NB: no window was specified, so i've assumed it's rectangular.
% 
% Fs      = 768;
% N       = 512;
% logplot = true;
% 
% fftwindow = ones(1, N);
% apwindow  = ones(1, 2*N-1);
% 
% amplitude = [3.34    0.67     0.044    0.0045   0.00022  0.0000037];
% freq      = [51.3    101.1    154.7    203.3    556.2    1080.7];
% phase     = [32.367  102.457  192.765  232.387  122.059  82.743];
% 


%% xiangdong2008
% http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=4697084
%  
% Fs      = 256;
% N       = 256;
% logplot = false;
%
% fftwindow = hanning(N)';
% apwindow  = conv(fftwindow, fftwindow);
%
% freq      = [50.3 85.33 121.72];
% amplitude = [2 2 2];
% phase     = [10 20 30];

%% Xiaohong2007
% http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=4445879 

Fs      = 512;
N       = 2048*4;
logplot = false;

fftwindow = kaiser(N, 9.5)';
apwindow  = conv(fftwindow, fftwindow);

freq      = [9 19.1 29.2 39.3 49.4];
amplitude = [1  1  1  1  1];
phase     = [50 50 50 50 50]; % choose one
phase     = [10 30 50 70 90];


%% generate signal
n = -N+1:N-1;
signal = zeros(size(n));

for i = 1:length(freq);
    f = 2 * pi * freq(i) / Fs;
    p = phase(i) * pi / 180;
    
    signal = signal + amplitude(i) * cos(f * n + p);
end

signal = awgn(signal, 10);

%% calculate spectrum

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

figure(100); clf;
subplot(211); hold on; 

if logplot
    plot(bins, db(abs(reg)), 'b'); 
    plot(bins, db(abs(ap)), 'r');
    title('Magnitude spectrum (linear scale)');
else
    plot(bins, abs(reg), 'b'); 
    plot(bins, abs(ap), 'r');
    title('Magnitude spectrum (linear scale)');
end
    
subplot(212); hold on; 
    plot(bins, rad2deg(angle(reg)), 'b'); 
    plot(bins, rad2deg(angle(ap)), 'r');
    title('Phase spectrum (deg)');

%% compare estimated and actual phase of each tone

disp('frequency - actual phase / apfft phase / error');
for i = 1:length(freq)
    bin = round(freq(i) / Fs * N);
    
%     if bin > N/2 % aliasing correction
%         zone = bin / (N/2);
%         if( 
%         bin = N/2 - bin - 1;
%     end
    
    ap_phase = angle(ap(bin)) * 180/pi;
    if ap_phase < 0
        ap_phase = 360 + ap_phase;
    end
    
    fprintf('%f - %f / %f / %f\n', freq(i), phase(i), ap_phase, ap_phase - phase(i));
end
