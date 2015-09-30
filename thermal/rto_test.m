if ~exist('RTO', 'var')
    config;
    RTO = configureRTO();
end

oldraw = 0;
oldwfm = 0;
oldmany = 0;

while true
    [wfm, raw, many] = aquire_pixel(RTO, 64);
    %segs = get_segments(RTO, 'CALCulate:MATH2:DATA:VALues?');
    
%     figure(1); clf; hold all;
%     for i = 1:min(size(segs))
%         plot(segs(:,i));
%     end

    figure(2);
    subplot(311); hold on; plot(wfm);  plot(oldwfm,  'r');
    subplot(312); hold on; plot(raw);  plot(oldraw,  'r');
    subplot(313); hold on; plot(many); plot(oldmany, 'r');
    
    oldraw  = raw;
    oldwfm  = wfm;
    oldmany = many;
    
    pause(0.01);
    
    
end
