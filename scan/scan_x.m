% TODO
% Fast mode for preview scans
% bottleneck is the zaber driver, every command requires a bit of waiting
%       wait time is also needed for mechanical settling, experimentally
%       i should observe how much though.
% see how the wait-for-trigger effects the capture rate


%% notes - these don't do anything to the scan itself, but having details
%about the setup itself readily available is a good idea.

lambda0     = 852e-9;
f_mod       = 1e3; % laser modulation frequency

ext_atten   = 20; % in db;
opt_atten   = 5; % in db

target      = 'flow channel';
Ibias       = 70e-3;

%% scan program behaviour
preview = true;

wait_time = 500e-3; % wait time after moving the zabers
avgs = 64;

% the scan results will be saved in: <save_dir>/<save_prefix>/ in the usual
% yNNN/xMMM format.
save_prefix = 'stripes - rates';
save_dir    = 'c:\junk\';

should_center_bl = false;

scan_center = [0.0218,   0.0329]; % absolute position offsets of the 'center'
scan_area   = [300e-6,  0.25e-3]; % area over which to scan
scan_points = [300,          10]; % number of points to scan in the area

deltas = scan_area ./ scan_points;

x_points = scan_center(1):deltas(1):(scan_center(1) + scan_area(1));
y_points = scan_center(2):deltas(2):(scan_center(2) + scan_area(2));

%% hardware config
% zabers
com_port        = 'COM1';
zaber_axes      = [1, 2];

% DAQ
sample_rate     = 500e3;
samples         = (avgs * 2) * sample_rate / f_mod;   % samples per waveform
channels        = [0];
channel_names   = {'laser voltage'};

scan_type = 'x';

%% setup scan
% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
output_datafile = strcat(output_dir, '/pixels.dat');
mkdir(output_dir);

output_mfile = sprintf('%s/scan.mat', output_dir);
save(output_mfile, '-v7.3');

% create hardware resources
zaber_clean
[s, zaber, count] = configureZabers(com_port, 2);
si = configureDAQ(sample_rate, samples, channels);

%% get the baseline waveform
disp('Moving to bl_point');
if should_center_bl
    bl_point = scan_center + (scan_area ./ 2);
else
    bl_point = scan_center;
end

% move to the first scan point, aquire baseline and then scan
for j = 1:length(zaber_axes)
    ZaberMoveAbsolute(zaber, zaber_axes(j), bl_point(j), false);
end

disp('Aquiring Baseline in 1s'); pause(1);

si.NumberOfScans = 1e6;
bl_data = si.startForeground();
si.NumberOfScans = samples;
[baseline, period, threshold] = calc_baseline(bl_data);

disp('Baseline Aquired. Moving to inital position');

%% book keeping
pixel_times = zeros(scan_points(1) * scan_points(2), 1); 
update_interval = floor(length(pixel_times) / 100);

% preview values
ang = zeros(length(path) - 1, 1);
amp = zeros(length(path) - 1, 1);

pixel_index = 1;

% move to the scan start point
for j = 1:length(zaber_axes)
    ZaberMoveAbsolute(zaber, zaber_axes(j), scan_center(j), false);
end

disp('Ready to start. Press a key to begin.'); pause();

start_time = now();
fprintf('Scan started: %s\n', datestr(start_time));
figure(10); clf;

% run the actual scan
for i = 1:scan_points(2)
   for j = 1:scan_points(1);
        start = tic();
           
       ZaberMoveAbsolute(zaber, 1, x_points(j), true);
       pause(wait_time);
       
       [data, si] = aquire_pixel(si);
       save_singlefile(output_datafile, data);
       
       [phase, ~, rms_amp] = analyze(data, baseline, period, threshold, 64);
       
       % calculate preview image
       amp(pixel_index) = mean(rms_amp);
       ang(pixel_index) = circ_mean(phase);
       
       img_preview2(amp, ang, scan_points(1), scan_points(2), pixel_index);
       
        % progress indicator
        pixel_times(i) = toc(start);

        if mod(i, update_interval) == 0
            per_pixel = sum(pixel_times(1:i)) / i;
            percent = floor(100 * i / scan_points(2));

            fprintf('%%%d done - (avg time per row %.2fs)\n', percent, per_pixel);
        end
        
        pixel_index = pixel_index + 1;
   end
   
   %ZaberMoveAbsolute(zaber, 2, y_points(i), true);
   ZaberMoveAbsolute(zaber, 1, x_points(1), true);
   pause(wait_time);
   
%   disp('Waiting to start next row.'); pause();
end

end_time = now();

% clean up
si.release();
ZaberClose(zaber);
fclose(s);
clear data si zaber s;
clear per_pixel percent counter data;

save(output_mfile, '-append');
