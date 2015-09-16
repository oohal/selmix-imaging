data_dir = 'c:/junk/';

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

for i = 1:length(r_path)
    data = read_floatdata(data_dir, i - 1);
    
    fringseg = data(2501:5000);
        
    spec = fft(window .* fringseg);
    [p, index] = max(abs(spec));
    peaks(pixel_index) = index;
        
    in = mode(peaks(1:pixel_index));
        
    img_preview2(amp, ang, scan_points(1), scan_points(2), pixel_index);
        
    %put the pixel in the right spot
    amplitude(i) = p;
    phase(i)     = phase(spec(in));
    
    
    if mod(i, ticker) == 0
        img_preview(amplitude, phase, r_path, i);
    end
end

pixels_read = i;

img_preview(amplitude, phase, r_path, pixels_read);