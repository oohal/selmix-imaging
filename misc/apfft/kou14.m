% laser details
C = 0.001;
alpha = 4;
lambda_0 = 660e-9; % nominal wavelength
gamma = -0.1e-9; % wavelength modulation coefficent m/mA

% current waveform details
sweep_points = 1000; % number of points in one current waveform period
I_pp = 1; % modulation current peak-peak
I_step = I_pp / sweep_points;
ramp = 0:I_step:I_pp;

% measured displacement details
disp_points = 3;
A = 300e-9; % displacement amplitude
L0 = 2.5e-2;  % nominal ext  cavity length

% generate displacement samples
traces = zeros(disp_points, sweep_points);

for i = 1:disp_points
    d_step = 1/disp_points;    
    tau = 2 * (L0 + A * sin(2*pi*[0:d_step:1 - d_step])); % round trip length
    
    m = 0; % self-mixing hysteresis variable
    
    % get SMI signal for a current period
    for j = 1:length(ramp)
        wavelength = lambda_0 + gamma * ramp(j);
        phi = tau(i) * 2 * pi / wavelength;
        
        [sample, m] = selmixpower(C, phi, alpha, m);
        traces(i, j) = sample;
    end
end

% do phase estimates and compare


estimate_period(