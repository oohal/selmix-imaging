%% setup scan
config;

if ~exist('RTO', 'var')
    RTO = configureRTO();
end

if ~exist('zaber', 'var');
    [s, zaber] = configureZabers(com_port, 1);
end


if ~exist('fgen', 'var')
    fgen = configureFreq(fgen_port, 1e3);
end


% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
mkdir(output_dir);

savefile  = sprintf('%s/scan.mat',     output_dir);
datfile   = sprintf('%s/data.dat',     output_dir);
rawfile   = sprintf('%s/raw_data.dat', output_dir);
basefile  = sprintf('%s/baseline.dat', output_dir);

names       = {};
frequencies = [];

data        = {}; %
raw_data    = {}; % 
baselines   = {};

index       = 1;

save(savefile, '-v7.3');

%% run the actual scan

frequencies = 100:100:100e3;


while true
    name = input('Frequency: ', 's');
    
    if strcmp(name, 'end') == 1
        break;
    end
    
    % if the name is r (for repeat), reuse the last frequency
    if strcmp(name, 'r') ~= 1
        frequency = str2double(name);
    else
        index = max(index - 1, 1);
    end
    
    if isnan(frequency)       
        disp('Invalid frequency? No value recorded');
        continue; 
    end
    
    baselines{index} = update_baseline(RTO, zaber, frequency, 0, scan_center(1));
    
    % aquire and store the waveform data
    [processed, raw] = aquire_pixel(RTO, avgs);
    
    figure(1); 
        subplot(311); plot(raw);
        subplot(312); plot(processed);
        subplot(313); plot(baselines{index});
    
    % raw waveforms
    frequencies(index) = frequency;
    
    data{index}     = processed;
    raw_data{index} = raw;
    
    index = index + 1;
    
    save(savefile, 'index', 'data', 'raw', 'frequencies', '-append');
end

% save datfiles since they fit nicely into my existing processing stuff
for i = 1:index
    save_singlefile(basefile, baselines{index});
    save_singlefile(datfile,  data{index});
    save_singlefile(rawfile,  raw_data{index});
end

% clean up
fclose(RTO);
fclose(s);
clear RTO s;

save(savefile, '-append');
