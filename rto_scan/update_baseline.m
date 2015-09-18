function [ ref_wfm ] = update_baseline(RTO, zaber, x)
    % aquire the reference waveform
    % when aquiring the reference signal average over a large number of 
    % periods with the zabers moving to generate shifting fringes
    % setup the reference curve 
    
    fprintf(RTO, 'STOP');
    
    fprintf(RTO, 'REFCurve1:SOURce C1W1');
    fprintf(RTO, 'REFCurve1:STATe ON');
    fprintf(RTO, 'CHANnel1:WAVeform1:ARIThmetics AVERage');
    fprintf(RTO, 'ACQuire:COUNt 9000');
    
    % start zaber move
    fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging
    
    fprintf(RTO, 'ACQuire:SEGMented:STATe ON');
    fprintf(RTO, 'ACQuire:SEGMented:MAX ON');
    fprintf(RTO, 'ACQuire:SEGMented:AUToreplay ON');
    
    % TODO: this might not be the best way to do this. Look at how blind
    % time, etc effects the quality of the reference.
    fprintf(RTO, 'REFCurve1:CLEar');
    ZaberMoveAbsolute(zaber, 1, x, false);
    fprintf(RTO, 'RUNSingle');

    pause(15);
    fprintf(RTO, 'REFCurve1:UPDate');
    
    ref_wfm = get_wfmvalues(RTO, 'REFCurve1:DATA:VALues?');
    figure; plot(ref_wfm); title('reference waveform');
end