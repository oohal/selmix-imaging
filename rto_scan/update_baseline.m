function [ ref_wfm ] = update_baseline(RTO, zaber, x)
    % aquire the reference waveform
    % when aquiring the reference signal average over a large number of 
    % periods with the zabers moving to generate shifting fringes
    % setup the reference curve 
    
    fprintf(RTO, 'STOP');
    
    fprintf(RTO, 'REFCurve1:SOURce C1W1');
    fprintf(RTO, 'REFCurve1:STATe ON');
    fprintf(RTO, 'CHANnel1:WAVeform1:ARIThmetics AVERage');
    fprintf(RTO, 'ACQuire:COUNt 9999');
    
    % start zaber move
    fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging
       
    fprintf(RTO, 'REFCurve1:CLEar');
    
    % TODO: using segmentation seems to cause issues since the
    % capture window is too short. The blind time in the normal aquisition 
    % mode helps with this since the reference is captured over a longer
    % time period, so there is more fringe variation and you get a higher
    % quality reference as a result.
    
    %    fprintf(RTO, 'ACQuire:SEGMented:STATe ON');
    %    fprintf(RTO, 'ACQuire:SEGMented:MAX ON');
    %    fprintf(RTO, 'ACQuire:SEGMented:AUToreplay ON');
    
    config;
    
    zaber_setspeed(zaber, 1, speed / 10, speed);
    ZaberMoveAbsolute(zaber, 1, x, false);
    zaber_setspeed(zaber, 1, speed);
    
    pause(0.1);
    fprintf(RTO, 'RUNSingle');

    % TODO: this can probably be shorter since we don't have to wait for on 
    % the replay to make averaging work (unlike in segmented mode).
    pause(6);
    
    fprintf(RTO, 'REFCurve1:UPDate');
    
    ref_wfm = get_wfmvalues(RTO, 'REFCurve1:DATA:VALues?');
    figure; plot(ref_wfm); title('reference waveform');
end