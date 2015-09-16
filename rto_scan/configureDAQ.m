function [ si ] = configureDAQ(sample_rate, samples, channels, device)
    
    % FIXME: this can probably automagiclly work based on daq.getDevices()
    if ~exist('device', 'var')
        device = 'Dev1';
    end

    si = daq.createSession('ni');

    si.Rate = sample_rate;
    si.NumberOfScans = samples;

    % add each channel
    for i = 1:length(channels)
        si.addAnalogInputChannel(device, channels(i), 'Voltage');
    end
    
    % Check the sample rate. If the sample rate is reduced due to the
    % channel config the DAQ toolbox will emit a warning, but I like it to
    % fail more explicitly.
    if si.Rate ~= sample_rate
        error('Cannot support the specified sample rate and channel combo');
    end
   
    si.ExternalTriggerTimeout = 40;
	si.TriggersPerRun = 1;

	addTriggerConnection(si,'External',strcat(device, '/PFI1'), 'StartTrigger');
end
