function [count, bits_x, bits_y] = fringe_count(signal)    
    threshold = (max(signal) + mean(signal)) / 2;
    
    edges = find(signal > threshold);
    
    count = length(find(diff(edges) > 100));
    
    bits_x = edges;
    bits_y = signal(edges);
    
    clf; hold on;
        plot(signal); 
        plot(edges, signal(edges), 'r*');
end