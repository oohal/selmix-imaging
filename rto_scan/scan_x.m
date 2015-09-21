config;

deltas = scan_area ./ scan_points;

x_points = scan_center(1):deltas(1):(scan_center(1) + scan_area(1));
y_points = scan_center(2):deltas(2):(scan_center(2) + scan_area(2));

%% hardware config
% zabers
zaber_axes = [1, 2];
scan_type  = 'x';

%% setup scan
% create hardware resources
zaber_clean
[s, zaber, count] = configureZabers(com_port, 2);
RTO = configureRTO();

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

% preview values
ang = zeros(length(path) - 1, 1);
amp = zeros(length(path) - 1, 1);

pixel_index = 1;

% move to the scan start point
for j = 1:length(zaber_axes)
    ZaberMoveAbsolute(zaber, zaber_axes(j), scan_center(j), false);
end

disp('Ready to start. Press a key to begin.'); pause();

% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
math_output_file = strcat(output_dir, '/pixels.dat');
raw_output_file  = strcat(output_dir, '/pixels_raw.dat');
mkdir(output_dir);

savefile = sprintf('%s/scan.mat', output_dir);
save(savefile, '-v7.3');

% and start
start_time = now();
fprintf('Scan started: %s\n', datestr(start_time));

pixel_count     = scan_points(1) * scan_points(2);
update_interval = floor(pixel_count / 100);
pixel_times     = zeros(total_pixels, 1);

window = hann(3000);

peaks = zeros(total_pixels, 1);
baselines = cell(scan_points(1)); % one baseline waveform for each row

% run the actual scan
for i = 1:scan_points(2)
   for j = 1:scan_points(1);
       %%
        start = tic();
        
        ZaberMoveAbsolute(zaber, 1, x_points(j), true);
        pause(wait_time);
       
        % aquire and store the waveform data
        [data, raw] = aquire_pixel(RTO, avgs);
        save_singlefile(math_output_file, data);
        save_singlefile(raw_output_file, raw);

        % process pixel data to get amplitude and phase data for each
        fringseg = data(2001:5000);
        
        spec = fft(window .* fringseg);
        [p, index] = max(abs(spec));
        peaks(pixel_index) = index;
        
        if pixel_index < 5000
            in = mode(peaks(1:pixel_index));
        end

        amp(pixel_index) = p;
        ang(pixel_index) = angle(spec(in));

         % calculate preview image
        figure(2);
        show_img(amp, ang, scan_points(1), scan_points(2), pixel_index, data);
        
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
   baselines{i} = update_baseline(RTO, zaber, x_points(1));
end

end_time = now();

% clean up
fclose(RTO);
ZaberClose(zaber);
fclose(s);
clear data zaber s RTO;
clear per_pixel percent counter data;

save(savefile, '-append');
