function [pixels] = read_floatdata(data_dir, number)
% find the number of x,y points
    if ~exist('max_samples', 'var')
        max_samples = Inf;
    end
    
    filestr = sprintf('%s/p%d', data_dir, number);

    if ~exist(filestr, 'file')
        error('%s does not exist', filestr);
    end
    
    data_file = fopen(sprintf(filestr, number), 'rb');
    pixels = fread(data_file, max_samples, 'single');      
    fclose(data_file);
end