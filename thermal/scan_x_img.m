data_dir = 'C:/imaging/scans/water-002';

load(strcat(data_dir, '/', 'scan.mat'));

datfile = strcat(data_dir, '/', 'pixels.dat');

% when processing the data the script will read multiple blocks to 
% at a time to speed things up a bit, this sets the number of blocks to
% read in one go. Higher is better, but careful of running out of memory
blocks_to_read = 1000;

% calculate how many points are in each waveform from the
% reference waveform (if it exists).
if exist('baselines', 'var')
    block_size = size(baselines{1});
else
    block_size = 5000;
end

% convert path into a picture
total_pixels = scan_points(1) * scan_points(2);

amplitude = zeros(total_pixels, 1);
phase     = zeros(total_pixels, 1);
peaks     = ones(total_pixels, 1);

window = hann(4096); % regular FFT window
%window = conv(hann(2048), hann(2048)); % apfft window

ticker = floor(total_pixels / 100);

pixel_index = 1;

i = 1;

while true
    [data, blocks] = read_singlefile(datfile, block_size, i + 1, blocks_to_read);
    
    if isempty(data)
        break;
    end
    
    for j = 1:blocks
        start  = block_size * (j - 1) + 1;
        finish = block_size * j;
        block = data(start:finish);
               
        fringeseg = block(1:4096);
        fringeseg = fringeseg - mean(fringeseg);

        spec = fft(window .* fringeseg, 2^13);
        %spec = apfft(fringeseg(1:4095), window);
        
        % Just look at the lower half spectrum without the DC bin
        % any offset on the signal will show up as power int he DC bin
        % so we need to ignore it.
        
        partial_spec = spec(2:floor(length(spec)/2));
        [p, index] = max(abs(partial_spec));
        peaks(i) = index + 1;
        
        if i < 5e3
            in = mode(peaks(1:i));
        end

        % put the pixel in the right spot
        amplitude(i) = p;
        phase(i)     = angle(spec(in));

        if mod(i, ticker) == 0
            show_img(amplitude, phase, scan_points(1), scan_points(2), i);
        end
        
%         if floor(i/scan_points(1)) == 17
%             start   = (i - 1) * scan_points(1) + 1;
%             finish =  i       * scan_points(1);
%             
%             figure(3); 
%             subplot(411);
%             plot(block(1:4096));
%             axis([0 4096 -0.2 0.2]);
%              
%             subplot(412); plot(phase(start:i));
%             
%             subplot(413); plot(  abs(spec(1:100)));
%             subplot(414); plot(angle(spec(1:100)));
%              
%             pause(0.1);
%         end
        
        i = i + 1;
    end
end

pixels_read = i;
[mag_pic, ang_pic] = show_img(amplitude, phase, scan_points(1), scan_points(2), pixels_read);


%%
figure;
waveforms = floor(pixels_read / scan_points(1));

averaged = zeros(1,2000);
for i = 1:waveforms
    averaged = averaged + unwrap(ang_pic(i,:));    
end

averaged = averaged / i;

% plot for comparison
for i = 1:waveforms
    clf;
    
    start   = (i - 1) * scan_points(1) + 1;
    finish =  i       * scan_points(1);
    
    subplot(311);
    plot(ang_pic(i,:));
    title(sprintf('wfm: %d %d-%d', i, start, finish));
    
    subplot(312); hold on; 
    plot(unwrap(ang_pic(i,:)));
    plot(averaged, 'r');
    
    % show where the FFT peaks are for each point
    subplot(313);
    plot(peaks(start:finish));
    
    pause;
end
