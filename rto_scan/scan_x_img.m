data_dir = 'C:/junk/baselinescan-001/';

matfile = strcat(data_dir, '/', 'scan.mat');
datfile = strcat(data_dir, '/', 'pixels.dat');

load(matfile);

% convert path into a picture
total_pixels = scan_points(1) * scan_points(2);

amplitude = zeros(total_pixels, 1);
phase     = zeros(total_pixels, 1);
peaks     = ones(total_pixels, 1);

window = hann(5000);
ticker = floor(total_pixels / 100);

pixel_index = 1;

for i = 1:total_pixels-1
    data = read_singlefile(datfile, 5000, i+1, 1);

    fringeseg = data(1:5000);
    fringeseg = fringeseg - mean(fringeseg);

    spec = fft(window .* fringeseg);
    [p, index] = max(abs(spec));
    peaks(i) = index;

    in = mode(peaks(1:i));

    %put the pixel in the right spot
    amplitude(i) = p;
    phase(i)     = angle(spec(in));

%     figure(1); plot(data);
%     figure(2); 
%     subplot(211); plot(abs(spec)); title(sprintf('index %d phase %.3f', in, phase(i)));
%     subplot(212); plot(angle(spec));

    if mod(i, ticker) == 0
        img_preview2(amplitude, phase, scan_points(1), scan_points(2), i);
    end
end

pixels_read = i;
img_preview2(amplitude, phase, scan_points(1), scan_points(2));