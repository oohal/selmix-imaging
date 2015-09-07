function [s, zaber, devices] = configureZabers(comport, req_devices, speed)
    % open device, build list of devices & start testing functions
    
    s = serial(comport);
    zaber = ZaberOpen(s);

    % renumber and find the number of zabers in the chain
    devices = ZaberRenumber(zaber, 0, 0);
    devices = max(devices(:,1));
    
    if devices < req_devices
        error('Detected %d zabers in the chain, %d required\n', devices, req_devices);
    else
        fprintf('Detected %d zabers in the chain, %d required\n', devices, req_devices);
    end
   
    % home and re-configure each device
    %
    % FIXME: Not sure if these settings are specific to the LMS50 i used to
    % configure the zaber in the first place or wether they apply to every
    % zaber device.
    %
    % device mode settings
    % 2048 - circular microsteps
    % 4    - anti-backlash
    % 2    - anti-stick
    
    if ~exist('speed', 'var')
        speed = 5e-3;
    end
    
    for zaber_id = 1:req_devices
        ZaberSetDeviceMode(zaber, zaber_id, 2054);
        setSpeed(zaber, zaber_id, speed);
        %ZaberHome(zaber, zaber_id);
    end   
end