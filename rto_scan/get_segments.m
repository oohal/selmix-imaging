function [ segments ] = get_segments(RTO, name)
    % get the number of points per waveform
    fprintf(RTO, 'CHAN:WAV1:DATA:HEAD?');
    header = fgets(RTO);
    header = textscan(header, '%f,');
    header = header{1};
    points = header(3);

    % query the number of available waveforms
    fprintf(RTO, 'ACQuire:COUNt?');
    waveform_count = str2double(fgets(RTO));

    % preallocate and fetch each waveform
    segments = zeros(points, waveform_count);
    
    fprintf(RTO, 'CHAN1:WAV1:HIST:STATe ON');
    
    for i = 1:waveform_count
        fprintf(RTO, 'CHAN1:WAV1:HIST:CURR %d', -waveform_count + i);
        %fprintf(RTO, 'CHAN1:WAV1:HIST:CURR %d', i);
        waveform = get_wfmvalues(RTO, name);
        segments(:,i) = waveform(:);
    end
    
    fprintf(RTO, 'CHAN1:WAV1:HIST:STATe OFF');
end