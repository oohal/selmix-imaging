function [ mag_pic, ang_pic ] = img_preview( amp, ang, path, limit )
    x = max(path(:,1));
    y = max(path(:,2));
    
    mag_pic = zeros(x, y);
    ang_pic = zeros(x, y);

    mag_min  = min(amp(1:limit));
    mag_peak = max(amp(1:limit)) - mag_min;    
    
    for i = 1:min(length(path), limit);
        x = path(i, 1) + 1;
        y = path(i, 2) + 1;

        % shift the range of the
        mag_pic(x, y) = (amp(i) - mag_min) ./ mag_peak;
        
        % shift the phase to be in the range 0..1 instead of -pi..pi
        ang_pic(x, y) = (ang(i) + pi) / 2 / pi;
    end
    
    figure(2);
    subplot(211); imshow(mag_pic); title('amplitude like');
    subplot(212); imshow(ang_pic); title('phaselike');
end
