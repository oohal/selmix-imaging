F_s   = 130; T_s   = 1/F_s;
F_sig = 13;  T_sig = 1/F_sig;

points = 40;

sig  = sin(2*pi*F_sig * [0:1/F_s:15/F_sig-1/F_s]);
sig2 = sin(2*pi*F_sig * [0:1/F_s:15/F_sig-1/F_s] + pi/4);

win = triang(points)';

fft_spec = fft(sig(1:points) .* win);
ap_spec  = apfft(sig2(1:(2*points-1)));

figure(1); subplot(211); plot(abs(fft_spec)); subplot(212); plot(angle(fft_spec)/pi); title('fft');
figure(2); subplot(211); plot(abs(ap_spec));  subplot(212); plot(angle(ap_spec)/pi);  title('apfft');
figure(3); plot(sig); title('time domain');

