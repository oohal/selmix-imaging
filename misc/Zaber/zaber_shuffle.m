if ~exist('zaber', 'var')
    config;
    [s, zaber, count] = configureZabers(com_port, 2);
end

zaber_setspeed(zaber, [1 2], 1e-3);

while true
    ZaberMoveAbsolute(zaber, 1, scan_center(1),                true);
    ZaberMoveAbsolute(zaber, 1, scan_center(1) + scan_area(1), true);
end