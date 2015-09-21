if ~exist('zaber', 'var')
    zaber_clean;
    config;
    
    [s, zaber, count] = configureZabers(com_port, 2);
end

zaber_setspeed(zaber, [1 2], 5e-3);

while true
    ZaberMoveAbsolute(zaber, 1, scan_center(1),                true);
    ZaberMoveAbsolute(zaber, 1, scan_center(1) + scan_area(1), true);
end