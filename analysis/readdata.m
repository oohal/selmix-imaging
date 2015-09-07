tic;

% If the datafiles variable exists then we're using the new one file per
% channel format. Otherwise it'll be used the all in a single file format.
if exist('datafiles', 'var');
    df = fopen(datafiles{1}, 'rb');
    
    %fseek(df, max_samples * 4, 'bof');
    %fseek(df, 0, 'bof');
    
    data = fread(df, max_samples, 'single');
    fclose(df);
    
    ref_f = fopen(datafiles{2}, 'rb');
    ref = fread(ref_f, max_samples, 'single');
    fclose(ref_f);
elseif exist('datafile', 'var');
    % single file format
    %
    % the on disk data format is a bit screwed up, it'll be in layers of
    % 1st cap: <$samples from channel 0> | <$samples from channel 1>
    % 2nd cap: <$samples from channel 0> | <$samples from channel 1>
    % 3rd cap: <$samples from channel 0> | <$samples from channel 1>
    %
    % so we need to 1. read it into arrays of length 50k and seperate it into
    % data and reference channels from there.
    
    samples = mode(data); % samples per capture
    rows = length(data);

    %setup to skip the reference channel
    format = sprintf('%d*single', samples);
    
    df = fopen(datafile, 'rb');
    data = fread(df, rows * samples, format, samples * 4);
    fclose(df);
    
    
    fseek(df, samples * 4, 'bof');
    ref = fread(df, rows * samples, format, samples * 4);
else
    % all in one file, unpack the cell array(s)
    samples_per = max(size(data{1}));
    data2 = zeros(samples_per * length(data), 2);
    
    for i = 1:length(data)
        first = 1 + (i - 1) * samples_per;
        last  = i * samples_per;
        
        data2(first:last,:) = data{i};
    end
    
    data = data2(:,1);
    ref = data2(:,2);
    clear data2;
    
    if ~exist('bl_data', 'var')
        bl_data = data;
    elseif iscell('bl_data')
        bl_data = bl_data{1}; 
    end
end

% filtering at a global level screws with the rising edge transitions a bit
% here we filter at the waveform level since we throw away the first/last
% bits of it anyway.

b = fir1(41, 80e3 / (sample_rate/2));
group_delay = length(b) / 2;

data    = filter(b, 1, data); % filter entire signal
bl_data = filter(b, 1, bl_data(:,1));

fprintf('Read took: %.2f\n', toc());
