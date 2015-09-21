com_port      = 'COM1';     % serial port the zabers are on
sRTO_hostname = '10.1.1.3'; % IP or network name of the scope

save_prefix = 'water';
save_dir    = 'c:/imaging/scans/';

scan_center = [0.0213,    0.0460]; % absolute position offsets of the 'center'
scan_area   = [2000e-6,  0.25e-3]; % area over which to scan
scan_points = [2000,       40]; % number of points to scan in the area

should_center_bl = false;


wait_time = 100e-3; % wait time after moving the zabers
avgs = 64;

% misc experiment setup details
target = 'flow channel + mirror';

laser_type = 'dfb';
lambda0    = 852e-9; % nominal wavelength

opt_atten   = 5;      % in db

laser_driver = 'thorlabs';
Ibias        = 63.7e-3; % bias current setpoint
f_mod        = 50e3;    % laser modulation frequency
mod_vpp      = 6;
mod_atten    = 20;      % electrical attenuation used with the modulation signal (dB)
