function [ data ] = aquire_pixel(RTO, avgs)
    fprintf(RTO, 'ACQuire:ARESet:IMMediate'); % reset the averaging
    fprintf(RTO, 'ACQuire:COUNt %d', avgs);
    fprintf(RTO, 'RUNSingle');
    
    data = get_wfmvalues(RTO, 'CALCulate:MATH2:DATA:VALues?');
end