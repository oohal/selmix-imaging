function [ RTO ] = configureRTO(reinit)
    config; % get the RTO config data
    
    % name of the RTO to access remotely via network
    sIPAddress = resolvehost(sRTO_hostname, 'address');

    % Create a VISA connection to the specified IP address
    RTO = visa('ni', ['TCPIP::' sIPAddress ]);
    RTO.InputBufferSize = 10e6;

    fopen(RTO); % Open the instrument connection
    
    %% configure the scope    
    % reset and configure the instrument
    % make the scope send floats when getting waveform value
    
    fprintf(RTO, 'FORMat REAL,32');
    fprintf(RTO,'SYST:DISP:UPD ON'); % Activate View-Mode in Remote Mode
    
    %% configure scope for experiment
    if exist('reinit', 'var') && reinit
        fprintf(RTO, '*RST'); % reset scope
        
        % configure the horizontal
        fprintf(RTO, 'TIMebase:RANGe %e', 15e-6); % setup time base
        fprintf(RTO, 'TIMebase:POS %e',   -8e-6);

        fprintf(RTO, 'TRIG1:SOURce CHAN2');  
        % configure differential input
        fprintf(RTO, 'CHAN1:COUPling AC');
        fprintf(RTO, 'CHAN1:RANGe 3.3');
        fprintf(RTO, 'CHAN1:POSition 4');
        fprintf(RTO, 'CHAN1:STATe ON');

        % set a dummy reference curve
        fprintf(RTO, 'REFCurve1:SOURce C1W1');
        fprintf(RTO, 'REFCurve1:STATe ON');
        fprintf(RTO, 'RUNSingle');
        fprintf(RTO, 'REFCurve1:UPDate');

        fprintf(RTO, 'CALC:MATH2 ''Ch1Wfm1 - Ref1'' ');
        fprintf(RTO, 'CALC:MATH2:STATe ON');
    end
end