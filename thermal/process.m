function [ amplitude, phase, pixel_count, peaks ] = process( datfile, block_size, x, y )
    % when processing the data the script will read multiple blocks to 
    % at a time to speed things up a bit, this sets the number of blocks to
    % read in one go. Higher is better, but careful of running out of memory
    blocks_to_read = 1000;

    % convert path into a picture
    total_pixels = x * y;

    amplitude = zeros(total_pixels, 1);
    phase     = zeros(total_pixels, 1);
    peaks     = ones(total_pixels, 1);

    window = hann(4096); % regular FFT window
    %window = conv(hann(2048), hann(2048)); % apfft window

    ticker = floor(total_pixels / 100);

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

            % mode() is really slow. 5k points should be enough to find the
            % actual peak index.
            if i < 5e3
                in = mode(peaks(1:i));
            end

            % put the pixel in the right spot
            amplitude(i) = p;
            phase(i)     = angle(spec(in));

            if mod(i, ticker) == 0
                show_img(amplitude, phase, x, y, i);
            end

            i = i + 1;
        end
    end

    pixel_count = i;
    [mag_pic, ang_pic] = show_img(amplitude, phase, x, y, pixel_count);
end