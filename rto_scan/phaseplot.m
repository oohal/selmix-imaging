pixels_read = i;
[mag_pic, ang_pic] = show_img(amplitude, phase, scan_points(1), scan_points(2), pixels_read);

figure;
waveforms = 34;

averaged = zeros(1,2000);
for i = 1:waveforms
    averaged = averaged + unwrap(ang_pic(i,:));
end

averaged = averaged / i;

% plot for comparison
for i = 1:waveforms
    clf; hold on; title(sprintf('%d', i));
    
    plot(unwrap(ang_pic(i,:)));
    plot(averaged, 'r');
    
    pause;
end
