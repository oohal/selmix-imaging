%% setup scan
config;

%% configure 
if ~exist('RTO', 'var')
    RTO = configureRTO();
end

if ~exist('zaber', 'var');
    [s, zaber] = configureZabers(com_port, 1);
end

if ~exist('fgen', 'var')
    fgen = configureFreq(fgen_port, 1e3, voltage);
end

% create scan directory
output_dir = next_free_filename(save_prefix, save_dir, true);
mkdir(output_dir);

savefile  = sprintf('%s/scan.mat',     output_dir);
datfile   = sprintf('%s/data.dat',     output_dir);
rawfile   = sprintf('%s/raw_data.dat', output_dir);
basefile  = sprintf('%s/baseline.dat', output_dir);
trigfile  = sprintf('%s/baseline.dat', output_dir);

% frequencies is defined in config
data        = cell(length(frequencies), 1);
raw_data    = cell(length(frequencies), 1);
baselines   = cell(length(frequencies), 1);
triggers    = cell(length(frequencies), 1);

save(savefile, '-v7.3');

%% run the actual scan
for index = 1:length(frequencies)
    fprintf(fgen, 'FREQ %e\n', frequencies(index)); % update fgen frequency
    
    baseline = update_baseline(RTO, zaber, frequencies(index), 0, scan_center(1));
    
    % aquire and store the waveform data
    [processed, raw, trigger] = aquire_pixel(RTO, avgs);
    
    data{index}      = processed;
    raw_data{index}  = raw;
    baselines{index} = baseline;
    triggers{index}  = trigger;
    
    save_singlefile(basefile, baselines{index});
    save_singlefile(datfile,  data{index});
    save_singlefile(rawfile,  raw_data{index});
    
    save(savefile, 'index', 'data', 'raw', 'frequencies', 'triggers', '-append');
    
    figure(1); clf;
        subplot(411); plot(raw); title('raw waveform');
        subplot(412); plot(processed); title('negatised');
        subplot(413); plot(baseline);  title('baseline');
        subplot(414); plot(trigger);  title('baseline');
        
    pause(0.1);
    
    % progress
    tick = floor(length(frequencies)/100);
    if mod(index, tick) == 0
       fprintf('%%%d done - current: %.2e Hz\n', floor(100 * index / length(frequencies)), frequencies(index));
    end
end

% clean up
fclose(RTO);
fclose(s);
clear RTO s;

save(savefile, '-append');
