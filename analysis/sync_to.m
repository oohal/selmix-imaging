function [ start, found ] = sync_to(capture, period, threshold)
    ds = diff(capture);
    if threshold < 0
        possible = find(ds < threshold);
    else
        possible = find(ds > threshold);
    end
    
    found = true;
    
    if isempty(possible)
        fprintf('No starts detected?\n');
        figure;
        plot(capture);
        start = 0;
        found = false;
    else
        start = possible(1);
%         figure(1);  clf;
%             subplot(211); plot(capture);
%             subplot(212); hold on;
%             plot(ds);
%             plot(possible, ds(possible), 'r*');
%         pause(0.01);
    end
end