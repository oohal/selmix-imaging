function bytes = save_trace(basedir, data, x, y)
%save_trace - saves the given data into the file "basedir/yNN/xMM.dat"
%             where MM and NN are the x and y pixel coordinates respectively

    if ~exist('basedir', 'var')
        basedir = './';
    end
    
    if exist('y', 'var')
        savedir = sprintf('%s/y%d', basedir, y);
        savefile = sprintf('%s/y%d/x%d', basedir, y, x);
        
            % if there's no dir for this y-axis then make one
        if ~exist(savedir, 'dir')
            mkdir(basedir, sprintf('y%d', y));
        end
    else
        savefile = sprintf('%s/p%d', basedir, x);
    end
        
    sf = fopen(savefile, 'ab');
    bytes = fwrite(sf, data, 'single');
    fclose(sf);
    
    % dlmwrite(filename, data, 'delimiter', '\t', 'newline', 'pc', '-append')
end
