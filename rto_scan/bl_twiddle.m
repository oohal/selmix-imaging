com_port = 'COM6';

if ~exist('zaber', 'var') 
%    zaber_clean
    [s, zaber, count] = configureZabers(com_port, 2);
    configureRTO;
end

ZaberMoveAbsolute(zaber, 1, 0.0215 + 10e-3, true);
pause(0.5);
update_baseline(RTO, zaber, 0.0215);

%fprintf(RTO, 'CHANnel1:HISTory:CURRent 0');
%figure(1); plot(get_wfmvalues(RTO, 'CALCulate:MATH2:DATA:VALues?'));
