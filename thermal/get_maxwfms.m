function [ max_wfms ] = get_maxwfms(RTO)
    fprintf(RTO, 'STOP');
    
    % check the current ultrasegmentaiton status
    fprintf(RTO, 'ACQuire:SEGMented:STATe?');
    ultra = str2double(fgetl(RTO));
    
    fprintf(RTO, 'ACQuire:SEGMented:STATe ON');
    fprintf(RTO, 'ACQuire:SEGMented:MAX ON');
    
    fprintf(RTO, 'ACQuire:COUNt?');
    max_wfms = str2double(fgetl(RTO));
    
    if ultra == 0
        fprintf(RTO, 'ACQuire:SEGMented:STATe OFF');
    end
end