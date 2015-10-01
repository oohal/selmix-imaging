function [com_port] = configureFreq(com_port, freq, voltage)

    if ~exist('voltage', 'var')
        voltage = 1;
    end

    if ischar(com_port)
        com_port = serial(com_port, 'BaudRate', 9600, 'StopBits', 2);
        fopen(com_port);
        
        fprintf(com_port, 'OUTP:LOAD INF;\n');
        fprintf(com_port, 'APPL:SIN %d, %d;\n', [freq, voltage]);
    else
        fprintf(fgen, 'FREQ %d\n', freq);
    end
end