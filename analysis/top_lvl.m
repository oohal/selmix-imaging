data_dir = 'C:/Users/Oliver/Desktop/scans/strip spot - 10x160-woogradient';

load(strcat(data_dir, '/', 'scan.mat'));

% convert path into a picture
if exist('step_x', 'var')
    r_path = rect_snake_path(scan_points(1), scan_points(2), 'x');
else
    r_path = rect_snake_path(scan_points(1), scan_points(2));
end

path_length = length(r_path);

amplitude = zeros(path_length, 1);
phase     = zeros(path_length, 1);

ticker = floor(path_length);

[baseline, period, threshold] = calc_baseline(bl_data);

for i = 1:length(r_path)
    data = read_floatdata(data_dir, i - 1);
    
    [phases, ~, rms_amps] = analyze(data, baseline, period, threshold, 16);
    
    %put the pixel in the right spot
    amplitude(i) = mean(rms_amps);
    phase(i)     = circ_mean(phases);
    
    if mod(i, ticker) == 0
        img_preview(amplitude, phase, r_path, i);
    end
end

pixels_read = i;

img_preview(amplitude, phase, r_path, pixels_read);