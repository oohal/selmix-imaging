function setSpeed(zaber, devices, speed, accel)

    if ~exist('accel', 'var')
        accel = speed * 100; % device accelerates in 100th of a second
    end

    for i = 1:length(devices)
        ZaberSetTargetSpeed(zaber, devices(i), speed);
        ZaberSetAcceleration(zaber, devices(i), accel);
    end
end