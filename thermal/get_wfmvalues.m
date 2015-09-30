function [ data ] = get_wfmvalues( RTO, name )
% get_wfmvalues - gets waveform data from a RTO
% name is the VISA command that needs to be issued to get the data
% e.g if name is 'CALCulate:MATH1:DATA:VALues?' the function retrieves
%     the values from math waveform 1

    fprintf(RTO, name);
    
    % data comes in the form: #NLLLLFFFF...
    % #    - the beginning of response marker
    % N    -  N length indicator
    % LLLL - number of samples
    % FFFF - IEEE 754 floating point values
    
    % check the return beginning with a hash '#'
    sStartIndicator = fread(RTO, 1, 'char');

    if sStartIndicator ~= '#' 
        error('get_wfmsvalues failed - initial response value is not #');
    end;

    % check the length of the length field in units
    nLengthOfLengthfield = fread(RTO,1,'char');
    nLengthOfLengthfield = str2double(char(nLengthOfLengthfield));

    % check the length of the data record
    nBlockLength = fread(RTO, nLengthOfLengthfield ,'char');
    nBlockLength = str2double(char(nBlockLength)) / 4;

    % to make this work, the endianess endian must be considered!
    % the RTO supports litte endian byte order
    data = fread(RTO, nBlockLength, 'float');
end
