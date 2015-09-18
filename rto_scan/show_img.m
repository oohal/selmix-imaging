function [ mag_pic, ang_pic ] = show_img( amp, ang, x, y, limit, trace)
    mag_pic = zeros(x, y);
    ang_pic = zeros(x, y);

    if exist('limit', 'var')
        limit = min(x * y, limit);
    else
        limit = x * y;
    end
    
    mag_min  = min(amp(1:limit));
    mag_peak = max(amp(1:limit)) + 1e-6;
    
    for i = 1:limit
        px = mod(i, x) + 1;
        py = floor(i / x) + 1;
        
        mag_pic(px, py) = amp(i);
        ang_pic(px, py) = ang(i);
        
        % shift the range of the
        %mag_pic(px, py) = (amp(i) - mag_min) ./ mag_peak;
        %
        % shift the phase to be in the range 0..1 instead of -pi..pi
        %ang_pic(px, py) = (ang(i) + pi) / 2 / pi;
    end
    
    mag_pic = mag_pic';
    ang_pic = ang_pic';
    
    figure(2);
    
    if exist('trace', 'var')
        subplot(311); imshow(mag_pic, [mag_min, mag_peak]); title('amplitude');
        subplot(312); imshow(ang_pic, [-pi pi]); title('phase');
        subplot(313); plot(trace); axis([1 length(trace) -0.5 0.5]);
    else
        subplot(211); imshow(mag_pic, [mag_min, mag_peak]); title('amplitude like');
        subplot(212); imshow(ang_pic, [-pi pi]); title('phaselike');
    end
end
