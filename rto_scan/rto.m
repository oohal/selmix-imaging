% name of the RTO to access remotely via network
sRTO_hostname = '10.1.1.2';
sIPAddress = resolvehost(sRTO_hostname, 'address');

% Create a VISA connection to the specified IP address
RTO = visa('ni', ['TCPIP::' sIPAddress ]);
RTO.InputBufferSize = 10e6;

fopen(RTO); % Open the instrument connection

%% configure the scope
fprintf(RTO,'SYST:DISP:UPD ON'); %Activate View-Mode in Remote Mode
fprintf(RTO, 'FORMat REAL,32');

%ref_wfm = get_wfmvalues(RTO, 'CHAN1:WAV1:DATA:Values?');


%% aquire the reference waveform
% when aquiring the reference signal average over a large number of 
% periods with the zabers moving to generate shifting fringes
% setup the reference curve 
fprintf(RTO, 'REFCurve1:SOURce C1W1');
fprintf(RTO, 'REFCurve1:STATe ON');
fprintf(RTO, 'CHANnel1:WAVeform1:ARIThmetics AVERage');
fprintf(RTO, 'ACQuire:COUNt 9999');

% start zaber move
fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging
fprintf(RTO, 'RUN'); % reset the averaging
    pause(2);
fprintf(RTO, 'STOP; *OPC'); % reset the averaging
%[~] = fscanf(RTO);

fprintf(RTO, 'REFCurve1:UPDate');
ref_wfm = get_wfmvalues(RTO, 'REFCurve1:DATA:VALues?');
figure; plot(ref_wfm); title('reference waveform');

%% put the scope into normal aquisition mode

avgs = 16;
fprintf(RTO, 'ACQuire:COUNt %d', avgs);
fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging

fprintf(RTO, 'RUN');

math_wfm = get_wfmvalues(RTO, 'CALCulate:MATH2:DATA:VALues?');

%fclose(RTO);
