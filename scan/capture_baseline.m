function [ bl_data ] = capture_baseline(sample_rate, inchannels, outchannel)
    si = configureDAQ(sample_rate, sample_rate, inchannels, 'Dev2');
    
    si.addAnalogOutputChannel('Dev2', outchannel, 'Voltage');
    
    data = sin((2*pi*4 / sample_rate) .* [0:(sample_rate-1)])';
    si.queueOutputData(data);
    
    k = 1; data = {};
    
    in_func  = @(src, event) stash_data(src, event, k, data);
    out_func = @(src, event) src.queueOutputData(data);
        
    addlistener(si, 'DataRequired', out_func);
    addlistener(si, 'DataAvailable', in_func);
    
    si.IsContinuous = true;
    
    si.startBackground();
    pause(2);
    si.stop();
    
    si.release();
    
    bl_data = flatten_cell(data);
end

function [] = stash_data(src, event, d, k)
    d{k} = event.Data;
    k = k + 1;
end
