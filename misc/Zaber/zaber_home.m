if ~exist('zaber', 'var')
    zaber_clean;
    config;
    
    [s, zaber, count] = configureZabers(com_port, 2);
end

ZaberHome(zaber, 1, true);
ZaberHome(zaber, 2, true);
