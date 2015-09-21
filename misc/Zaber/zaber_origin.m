if ~exist('zaber', 'var')
    zaber_clean;
    config;
    
    [s, zaber, count] = configureZabers(com_port, 2);
end

config;

for i = 1:length(scan_center)
    ZaberMoveAbsolute(zaber, i, scan_center(i), true);
end
