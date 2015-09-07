function [ ] = save_singlefile( name, data )
    fd = fopen(name, 'ab');
    
    fwrite(fd, data, 'float');
    
    fclose(fd);
end
