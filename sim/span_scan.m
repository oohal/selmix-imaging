start_point = start;
total_span  = 2e-3;
velocity    = 100e-6;

spans = total_span / velocity * 2;

%  try cal things so we know what velocity will cover a span within a
%  capture interval. Ideally the capture will be done just before the
%  movement has finished.

status = 1;
speed = 1e-3;

while status == 0
    ZaberMoveAbsolute(zaber, start, true); % move to start point
    ZaberMoveAbsolute(zaber, next, false); % begin movement

    fprintf(RTO, 'RUNSingle; *OPC?');
    [~] = fread(RTO, 1, 'char');
    
    status = ZaberReturnStatus(zaber);
    
    if status == 0
        zaber_setspeed(zaber, 1, speed);
        speed = speed * 0.9;
    end
end



% for i = 1:spans
%     ZaberMoveAbsolute(zaber, start, true); % move to start point
%     ZaberMoveAbsolute(zaber, next, false); % begin movement
%     
%     fprintf(RTO, 'RUNSingle; *OPC');
%     [~] = fread(RTO, 1, 'char');
%     
%     Zaber
%     
% end