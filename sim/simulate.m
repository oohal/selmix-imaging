%% does a simulated experiment from the given using the experimental paramaters
% experiment parameters

save_dir = 'h:/imaging/scans/';

f_mod       =  50e3; % frequency modulation period
sample_rate = 250e6; % sample rate

L0   = 10e-2; % measured with a tape measure
beta = 1e-3;
C    = 2;

samples = sample_rate / f_mod;
lambda0 = 852e-9;

f0 = 3e8 / lambda0;                  % laser center frequency
freq_range = -20e9;                   % laser frequency sweep range (Hz)

fstep = freq_range / samples;
sweep = 3e8 ./ [f0:fstep:f0+freq_range-fstep];

% power modulation waveform
%mod = sawtooth(2 * pi * f_mod / f_s * [0:samples_per_period - 1]);
%mod = (mod(:) + 1) / 2;


%% generate a surface that is random on large scales, but smooth on smaller scales
rng('default');
rng(7);

low_points = 20;
high_points = 1e4;

span = 1e-3; % size of the span

low_y  = randn(low_points,1);
low_x  = linspace(0, span, low_points);
high_x = linspace(0, span, high_points);
surface = spline(low_x, low_y, high_x);

% add tilt to the surface by adding a gradient
surface = surface - linspace(0, 10, length(surface)); % linear surface

surface = surface * 1e-6; % put the surface roughness in microns

figure(1); plot(surface);

%% generate self-mixing signals at each point on the surface and save to a file
cores = 4;
data = cell(cores,1);

output_dir = next_free_filename('sim', save_dir, true);
output_file = strcat(output_dir, '/pixels.dat');
savefile    = strcat(output_dir, '/scan.mat');
mkdir(output_dir);

scan_points = [length(surface), 1];

for k = 1:floor(length(surface) / cores);
    parfor j = 1:cores
        data{j} = beta * sweep_sim(L0 + surface(cores * (k - 1) + j), sweep, C);
    end
    
    figure(1); clf; 
    for j = 1:cores
        subplot(4,1,j); plot(data{j});
        
        save_singlefile(output_file, data{j});
    end
          
    figure(2); clf; hold on;
    plot(surface); 

    start = k * cores + 1;
    finish = min((k+1) * cores, length(surface));
    seg = start:finish;
    
    plot(seg, surface(seg), 'r*');
    title(sprintf('%d / %d', k, floor(length(surface) /cores)));
    
    pause(0.01);
end

clear mod;

save(savefile, '-v7.3');