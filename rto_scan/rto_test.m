if ~exist('RTO', 'var')
    config;
    RTO = configureRTO();
end

while true
    [wfm, raw] = aquire_pixel(RTO, 64);
    %segs = get_segments(RTO, 'CALCulate:MATH2:DATA:VALues?');
    
%     figure(1); clf; hold all;
%     for i = 1:min(size(segs))
%         plot(segs(:,i));
%     end

    figure(2); 
    subplot(211); plot(wfm);
    subplot(212); plot(raw);
    pause(0.01);
end
