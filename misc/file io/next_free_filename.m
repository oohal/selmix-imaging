function [ name, n ] = next_free_filename( prefix, directory, want_dir )
% next_data_filename - looks in dir for files matching the pattern
% prefix-xxx where xxx is a number. The function will return the lowest
% postfix number that is unused.

    if exist('directory', 'var')
        if ~exist(directory, 'dir')
            error('%s does not exist');
        end
        
        prefix = fullfile(directory, prefix); % bake dir into the prefix
    else
        warning('no search directory defined, assuming ''.''');
        prefix = './';
    end

    % are looking for a directory or file?
    if exist('want_dir', 'var') && want_dir;
        type    = 'dir';
        suffix  = '';
    else 
        type    = 'file';
        suffix  = '.dat';
    end

    
    % find the next free file
    n = 1;

    while true
        name = sprintf('%s-%.3d%s', prefix, n, suffix);
        
        if ~exist(name, type)
            break;
        end
        
        n = n + 1;
    end
end

