function [ subtracted, raw, many ] = aquire_pixel(RTO, avgs)
    fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging
    fprintf(RTO, 'ACQuire:COUNt %d', avgs);
    
    fprintf(RTO, 'RUNSingle; *OPC?');
    [~] = fread(RTO, 1, 'char');
    
    subtracted = get_wfmvalues(RTO, 'CALCulate:MATH2:DATA:VALues?');
    raw        = get_wfmvalues(RTO, 'CHAN1:DATA:VALues?');
end