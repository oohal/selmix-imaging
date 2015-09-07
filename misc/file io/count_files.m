function [count] = count_files(format, type, start)
% count_files, counts the number of files that exist
    if ~exist('start', 'var')
        start = 0;
    end

    count = start;
    exists = true;
    while exists
        name   = sprintf(format, count);
        exists = exist(name, type);
        
        count = count + 1;
    end
    
    count = count - 1 - start;
end