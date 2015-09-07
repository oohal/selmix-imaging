zaber_clean;

[s, zaber, count] = configureZabers('COM1', 2);

pos = ZaberReturnCurrentPosition(zaber, 0);
position = pos(:,2)'

ZaberClose(zaber);
fclose(s);
clear si zaber s;