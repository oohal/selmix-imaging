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
