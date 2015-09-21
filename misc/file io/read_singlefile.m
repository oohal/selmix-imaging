function [ data, blocks ] = read_singlefile( name, points, index, len )
% read_singlefile - assumes each waveform is stored in the file ``name"
% as a fixed length record containing ``points".
%           
% optional args:
% index - The index of the first record to be read. (Defaults to 1)
% len   - The number of records to be read (Defaults to whole file)
%
    fd = fopen(name, 'rb', 'ieee-le');

    if ~exist('len', 'var')
        len = inf;
    end
    
    if ~exist('index', 'var')
        index = 1;
    end
    
    fseek(fd, (index - 1) * points * 4, 'bof');
    [data, count] = fread(fd, points * len, 'single');
    blocks = floor(count / points);
    
    fclose(fd);
end