function [ ref_wfm ] = update_baseline(RTO, zaber, frequency, x1, x2)
    % aquire the reference waveform
    % when aquiring the reference signal average over a large number of 
    % periods with the zabers moving to generate shifting fringes
    % setup the reference curve 
    
    fprintf(RTO, 'STOP');
    
    % configure the timebase so we have a full period per screen
    fprintf(RTO, 'TIMebase:RANGe %e', 1/frequency * 0.90); % setup time base
    fprintf(RTO, 'TIMebase:POS %e', 0);
    %fprintf(RTO, 'TIMebase:REF %e', 0);
    
    fprintf(RTO, 'REFCurve1:SOURce C1W1');
    fprintf(RTO, 'REFCurve1:STATe ON');
    fprintf(RTO, 'CHANnel1:WAVeform1:ARIThmetics AVERage');
    
    waveforms = min(2 * frequency, get_maxwfms(RTO));
    
    fprintf(RTO, 'ACQuire:COUNt %d', waveforms);
    
    % start zaber move
    fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging   
    fprintf(RTO, 'REFCurve1:CLEar');
    
    % the zaber should already be in this position, but never hurts to be
    % sure
    
    % at low frequencies the scope will always capture every waveform in 
    % sequence, at higher frequency we need to use ultra segmentation mode
    % to achieve the same results.
    
    if 2 * frequency > waveforms
        fprintf(RTO, 'ACQuire:SEGMented:STATe ON');
        fprintf(RTO, 'ACQuire:SEGMented:AUToreplay ON');
        
        speed = 2e-3;
        ultra = true;
    else
        % to give it enough time to get a decent baseline we need to scan
        % slow enough, so change the speed so it'll take ~1s to complete.
        
        %speed = abs(x1 - x2) * 0.9;
        speed = 2e-3;
        zaber_setspeed(zaber, 1, speed, speed);
        ultra = false;
    end
    
    % move and aquire
    
    ZaberMoveAtConstantSpeed(zaber, 1, speed);
    pause(0.5);
    
    fprintf(RTO, 'RUNSingle; *OPC?');
    [~] = fread(RTO, 1, 'char'); % done?
    
    % stop the zaber moving at constant velocity and return 
    ZaberMoveAbsolute(zaber, 1, x2, false);
    
    if(ultra)
        fprintf(RTO, 'CHAN1:WAV1:HIST:PLAY; *OPC?');
        [~] = fread(RTO, 1, 'char'); % done?
        pause(0.1);
    end
    
    fprintf(RTO, 'REFCurve1:UPDate');
    
    ref_wfm = get_wfmvalues(RTO, 'REFCurve1:DATA:VALues?');
    figure; plot(ref_wfm); title(sprintf('reference waveform - %d avgs', frequency));
    
    config;
    zaber_setspeed(zaber, 1, speed);
    ZaberMoveAbsolute(zaber, 1, x2, true); % wait for the zaber to actually arrive
    fprintf(RTO, 'ACQuire:SEGMented:STATe OFF');
end