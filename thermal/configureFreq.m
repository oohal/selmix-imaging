function [com_port] = configureFreq(com_port, freq)
    
    if ischar(com_port)
        com_port = serial(com_port, 'BaudRate', 9600, 'StopBits', 2);
        fopen(com_port);
    end

    fprintf(com_port, 'OUTP:LOAD INF;');
    fprintf(com_port, 'APPL:RAMP %.2e, 3;', freq);
end