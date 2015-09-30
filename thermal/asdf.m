sigs   = figure; hold all;
fringe = figure;

for i = 1:30
    scaled = diff(data{i});
    scaled = detrend(scaled);
    
    scaled = scaled - mean(scaled);
    scaled = scaled ./ (max(scaled)) * 0.5;    
    
    figure(fringe); clf;
    [fringes(i), x, y] = count_fringes(scaled);
    
    % chop things up a bit so we get more or 
    final = max(x);
    start = final - 4096 + 1;    
    partial = scaled(start:final);
    
    figure(sigs); plot(partial + i);
    
    figure(sigs);
    plot(scaled + i); plot(x, y + i, 'r.');
end
