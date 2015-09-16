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

wait_time = 200e-3; % wait time after moving the zabers
avgs = 64;

% the scan results will be saved in: <save_dir>/<save_prefix>/ in the usual
% yNNN/xMMM format.
save_prefix = 'stripes - rates';
save_dir    = 'c:\junk\';

should_center_bl = false;

scan_center = [0.0174,   0.0356]; % absolute position offsets of the 'center'
scan_area   = [0.25e-3, 0.25e-3]; % area over which to scan
scan_points = [100,          10]; % number of points to scan in the area

%% hardware config
% zabers
com_port        = 'COM1';
zaber_axes      = [1, 2];

% DAQ
sample_rate     = 500e3;
samples         = (avgs + 2) * sample_rate / f_mod;   % samples per waveform
channels        = [0];
channel_names   = {'laser voltage'};

%% create zaber scan path
%
% The default is to just scan in a rectangular grid, but you can use more
% complex scan paths if you want.
%
% To define the scan area you set scan_area to the inital zaber positions.
% Use the zaber control panel to align the system and find good values for
% the center point.

%path = rect_snake_path(scan_points(1), scan_points(2), 'center');
path = rect_snake_path(scan_points(1), scan_points(2));

deltas = scan_area ./ scan_points;

for i = 1:length(scan_center)
    path(:,i) = path(:,i) * deltas(i) + scan_center(i);
end

%path(:,1) = scan_center(1); % just scan along the same x point repeatedly

%% setup scan
% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
mkdir(output_dir);

savefile = sprintf('%s/scan.mat', output_dir);
save(savefile, '-v7.3');

% create hardware resources
zaber_clean
[s, zaber, count] = configureZabers(com_port, 2);
si = configureDAQ(sample_rate, samples, channels);

%% run scan

if should_center_bl
    bl_point = scan_center + (scan_area ./ 2);
else
    bl_point = scan_center;
end

% move to the first scan point, aquire baseline and then scan
for j = 1:length(zaber_axes)
    ZaberMoveAbsolute(zaber, zaber_axes(j), bl_point(j), false);
end

pause(1);

% aquire baseline waveform
si.NumberOfScans = 1e6;
bl_data = si.startForeground();
si.NumberOfScans = samples;

% book keeping
pixel_times = zeros(length(path), 1); 
update_interval = floor(length(path) / 100);

disp('Baseline Aquired. Press any key to begin scan'); pause;

start_time = now();
fprintf('Scan started: %s\n', datestr(start_time));
figure(10); clf;

%% working value arrays
path = [path(1,:); path];

pixel_phase = cell(length(path) - 1, 1);
pixel_amp   = cell(length(path) - 1, 1);

phases = zeros(length(path) - 1, 1);
amp    = zeros(length(path) - 1, 1);
pixel_index = 1;

%% twiddle with this if you want add resume a scan
start_at = 2;

%% copy the first point so we don't have to special case around it

% move to the scan start point
for j = 1:length(zaber_axes)
    ZaberMoveAbsolute(zaber, zaber_axes(j), path(start_at,j), false);
end

for i = start_at:length(path)
    start = tic();
    
    % move each axis to the correct spot, if the axis would move
	% less than a nanometer then just ignore the move
    
    %figure(10); hold on; plot(path(i,1), path(i,2), '*');
    
    for j = 1:length(zaber_axes)
		desired = path(i - 1, j);
		curr 	= path(i,     j);

        if abs(curr - desired) > 1e-9
            ZaberMoveAbsolute(zaber, zaber_axes(j), path(i, j), true);
        end
    end
    
    pause(wait_time);
    
    % aquire data for this point
    si.prepare();
    data = si.startForeground();
    save_singlefile(output_file, samples, data, 1);
    save_trace(output_dir, data, i - 2);
    
    % generate the preview plot
    [p, ~, mag] = analyze(data, bl_data, 16);
    
    pixel_phase{pixel_index} = p;
    pixel_amp{pixel_index} = mag;
    
    phases(pixel_index)    = circ_mean(p);
    amp(pixel_index)       = mean(mag);
    
    mag_pic                = amp;
    mag_pic(1:pixel_index) = mag_pic(1:pixel_index) - min(mag_pic(1:pixel_index));

    mag_pic     = mag_pic ./ max(mag_pic(1:pixel_index));
    phase_pic   = (phases + pi) / 2 / pi;
    
    mag_pic   = reshape(mag_pic,   scan_points(2), scan_points(1))';
    phase_pic = reshape(phase_pic, scan_points(2), scan_points(1))';

%     for k = 1:2:scan_points(2)
%         mag_pic(k,:) = flipud(mag_pic(k,:));
%         phase_pic(k,:) = flipud(phase_pic(k,:));
%     end
       
    figure(3); clf;   
        subplot(121); imshow(mag_pic);   title('amplitude');
        subplot(122); imshow(phase_pic); title('phase');
    
    % progress indicator 
    pixel_index = pixel_index + 1;
    pixel_times(i) = toc(start);
    
    if mod(i, update_interval) == 0
        per_pixel = sum(pixel_times(1:i)) / i;
        percent = floor(100 * i / length(path));
        
        fprintf('%%%d done - (avg time per pixel %.2fs)\n', percent, per_pixel);
    end
end

end_time = now();

% clean up
si.release();
ZaberClose(zaber);
fclose(s);
clear data si zaber s;
clear per_pixel percent counter data;

save(savefile, '-append');
