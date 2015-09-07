zaber_clean;

scan_center = [0.0123, 0.0247]; % absolute position offsets of the 'center'
scan_area   = [3.5e-3, 3.5e-3]; % area over which to scan

[s, zaber, count] = configureZabers('COM1', 2);

ZaberHome(zaber, 1, true);
ZaberHome(zaber, 2, true);

% pos = [0.0151, 0.024]; % absolute position offsets of the 'center'

%ZaberMoveAbsolute(zaber, 1, scan_center(1), true);
%ZaberMoveAbsolute(zaber, 2, scan_center(2), true);

%ZaberMoveAbsolute(zaber, 1, pos(1), true);
%ZaberMoveAbsolute(zaber, 2, pos(2), true);

ZaberClose(zaber);
fclose(s);
clear si zaber s;