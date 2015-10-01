% Scan configuration file.
% 
% Data specific to a single scan should go in here. No code should be 
% within the file as it is included at places (and within a few functions)
% throughout the code base.
%

com_port      = 'COM1'; % serial port the zabers are on
fgen_port     = 'COM5'; % serial port of the function gen

sRTO_hostname = '10.1.1.3'; % IP or network name of the scope

save_prefix = 'thermal-ramp-2v';
save_dir    = 'c:/imaging/scans/';

scan_center = [0.0292, 0.0335]; % absolute position offsets of the 'center'
speed = 1e-3; % zaber movement speed

avgs = 128;
frequencies = floor(logspace(2, log10(150e3), 200)); % frequency sweep range
voltage = 1;


% misc experiment setup details
target = 'flow channel + mirror + cracks + iris';

laser_type = 'dfb';
lambda0    = 852e-9; % nominal wavelength

opt_atten   = 5;      % in db

laser_driver = 'thorlabs';
Ibias        = 63.7e-3; % bias current setpoint
f_mod        = 1e3;    % laser modulation frequency
mod_vpp      = 6;
mod_atten    = 20;      % electrical attenuation used with the modulation signal (dB)
