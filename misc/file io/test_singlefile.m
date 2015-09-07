% tests read_singlefile and save_singlefile
data = sin(2*pi*10/1e3 * [0:1e3-1])';

coeffs = [0 1 2 3 4 5];

for i = 1:length(coeffs)
    save_singlefile('testfile.dat', coeffs(i) * data);
end

figure(1);
for i = length(coeffs)
    chewed = read_singlefile('testfile.dat', length(data), i, 1);
    error = data  * coeffs(i) - chewed;
    
    clf; 
    subplot(131); plot(data * coeffs(i)); 
    subplot(132); plot(chewed);
    subplot(133); plot(error);
    
    assert(max(abs(error)) < 1e-6);
end

% readback and compare, there will be a bit of error due to the
% double->single conversion, but it should be fairly small.
delete('testfile.dat');

disp('Tests passed!');
