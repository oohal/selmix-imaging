distance = 5e-3;
config;

if ~exist('zaber', 'var') 
    zaber_clean
    [s, zaber, count] = configureZabers(com_port, 2);
end

if ~exist('RTO', 'var')
    RTO = configureRTO();
end

zaber_setspeed(zaber, 1, 1e-3);
ZaberMoveAbsolute(zaber, 1, scan_center(1), true);

raws = zeros(5e3, 16);
index = 1;

while true   
    wfm1 = update_baseline(RTO, zaber, scan_center(1) + distance);
    raws(:, index) = wfm1;
    index = mod(index + 1, 16) + 1;
    
    wfm2 = update_baseline(RTO, zaber, scan_center(1));
    raws(:, index) = wfm1;
    index = mod(index + 1, 16) + 1;
    
    averaged = sum(raws, 2) / 16;
    
    figure(2); clf; 
    subplot(211); hold on;
    plot(averaged, 'r');
    plot(wfm1, 'b');
    plot(wfm2, 'g');
    
    subplot(212); hold on;
    plot(wfm1 - averaged, 'b');
    plot(wfm2 - averaged, 'g');
    
    pause(0.5);
end
