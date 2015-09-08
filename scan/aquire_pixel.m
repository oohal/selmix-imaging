function [data, si] = aquire_pixel(si, retry)
    if ~exist('retry', 'var');
        retry = 100;
    end
    
    captured = false;

    while ~captured && retry > 0
        try
            si.prepare();
            data = si.startForeground();
            captured = true;
        catch ex
            % sometimes the DAQ just needs to take a breather
            % so release, reinitialise and retry.
            si.release();
            si = configureDAQ(sample_rate, samples, channels);
            
            retry = retry - 1;
            if retry == 0
                error('Failed to aquire pixel even with retries');
            end
        end
    end
end