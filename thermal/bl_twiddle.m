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

x1 = scan_center(1);
x2 = scan_center(1) + scan_area(1);

freq = 500;

while true   
    wfm1 = update_baseline(RTO, zaber, freq, x1, x2); pause(0.5);
    wfm2 = update_baseline(RTO, zaber, freq, x2, x1);
        
    figure(2); clf; 
        subplot(211); plot(wfm1); title('forward');
        subplot(212); plot(wfm2); title('backwards');
    
    pause(0.1);
end
