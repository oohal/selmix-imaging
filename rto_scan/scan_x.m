%% notes - these don't do anything to the scan itself, but having details
%about the setup itself readily available is a good idea.

lambda0     = 852e-9;
f_mod       = 50e3; % laser modulation frequency

ext_atten   = 20; % in db;
opt_atten   = 5; % in db

target      = 'flow channel + mirror';
Ibias       = 63.7e-3;
mod_vpp     = 6;

notes = '';

%% scan program behaviour
preview = true;

wait_time = 100e-3; % wait time after moving the zabers
avgs = 64;

% the scan results will be saved in: <save_dir>/<save_prefix>/ in the usual
% yNNN/xMMM format.
save_prefix = 'baselinescan';
save_dir    = 'c:\junk\';

should_center_bl = false;

scan_center = [0.0215,    0.0460]; % absolute position offsets of the 'center'
scan_area   = [2000e-6,  0.25e-3]; % area over which to scan
scan_points = [2000,          100]; % number of points to scan in the area

deltas = scan_area ./ scan_points;

x_points = scan_center(1):deltas(1):(scan_center(1) + scan_area(1));
y_points = scan_center(2):deltas(2):(scan_center(2) + scan_area(2));

%% hardware config
% zabers
com_port        = 'COM6';
zaber_axes      = [1, 2];

scan_type = 'x';

%% setup scan
% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
output_file = strcat(output_dir, '/pixels.dat');
mkdir(output_dir);

savefile = sprintf('%s/scan.mat', output_dir);
save(savefile, '-v7.3');

% create hardware resources
zaber_clean
[s, zaber, count] = configureZabers(com_port, 2);
configureRTO;

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

disp('Aquiring Baseline');

baseline = update_baseline(RTO, zaber, x_points(length(x_points)));
baseline = update_baseline(RTO, zaber, x_points(1));

disp('Baseline Aquired. Moving to inital position');

%% book keeping
total_pixels = scan_points(1) * scan_points(2);
pixel_times = zeros(total_pixels, 1); 
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

pixel_count     = scan_points(1) * scan_points(2);
update_interval = floor(pixel_count / 100);
pixel_times     = zeros(total_pixels, 1);

window = hann(3000);

peaks = zeros(total_pixels, 1);

% run the actual scan
for i = 1:scan_points(2)
   for j = 1:scan_points(1);
        start = tic();
        
        ZaberMoveAbsolute(zaber, 1, x_points(j), true);
        pause(wait_time);
       
        data = aquire_pixel(RTO, avgs);
        save_singlefile(output_file, data);

        figure(2); plot(data); title(sprintf('(%d, %d)', j, i));
        
        fringseg = data(2001:5000);
        
        spec = fft(window .* fringseg);
        [p, index] = max(abs(spec));
        peaks(pixel_index) = index;
        
        in = mode(peaks(1:pixel_index));

        % calculate preview image
        amp(pixel_index) = p;
        ang(pixel_index) = phase(spec(in));
        
        img_preview2(amp, ang, scan_points(1), scan_points(2), pixel_index);
        
        % progress indicator
        pixel_times(pixel_index) = toc(start);

        if mod(pixel_index, update_interval) == 0
            per_pixel = sum(pixel_times(1:pixel_index)) / pixel_index;
            percent = floor(100 * pixel_index / pixel_count);

            fprintf('%%%d done - %d / %d (avg time per pixel %.2fs)\n', percent, pixel_index, pixel_count, per_pixel);
        end
        
        pixel_index = pixel_index + 1;
   end
   
   % scan back to the start point and update the baseline along the way
   update_baseline(RTO, zaber, x_points(1));
   
%   disp('Waiting to start next row.'); pause();
end

end_time = now();

% clean up
fclose(RTO);
ZaberClose(zaber);
fclose(s);
clear data zaber s RTO;
clear per_pixel percent counter data;

save(savefile, '-append');
