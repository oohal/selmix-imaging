if ~exist('zaber', 'var')
    zaber_clean;
    config;
    [s, zaber, count] = configureZabers(com_port, 2);
end

pos = ZaberReturnCurrentPosition(zaber, 0);
position = pos(:,2)'
