function [pixels, x, y] = read_labviewdata(data_dir, max_samples)   
    % find the number of x,y points
    
    dirstr  = strcat(data_dir, '/',    'x%d');
    filestr = strcat(data_dir, '/x0/', 'y%d');
    
    x = count_files(dirstr,  'dir');
    y = count_files(filestr, 'file');
        
    pixels = cell(x, y);

    for i = 1:x
        row_dir = sprintf('%s/x%d', data_dir, i - 1);

        for j = 1:y
            
            data_file = sprintf('%s/y%d', row_dir, j - 1);
            
            if exist('max_samples', 'var')
                data = read_lines(data_file, max_samples);
            else
                data = importdata(data_file);
            end
            
            pixels{i,j} = data(:,2);
        end 
    end
end


function [data] = read_lines(filename, lines)
    df = fopen(filename, 'r');
    
    data = fscanf(df, '%f', lines * 2);
    data = reshape(data, 2, lines)';
    
    fclose(df);
end