function [ path ] = rect_snake_path(x, y, varargin)
% crates a snaking path that steps along the y axis
% takes two optional string arguments
%
% 'x'      - makes the path step along the x axis rather than y
% 'center' - shifts the path so the left corner is at (-x/2, -y/2) rather
%            than (0,0)
%

    reverse = false;
    path = zeros(x * y, 2);   
    k = 1;

    for i = 1:x
        for j = 1:y
            if reverse == true
                path(k,:) = [i - 1, y - j];
            else
                path(k,:) = [i - 1, j - 1];
            end
            
            k = k + 1;
        end
        
        reverse = ~reverse; % change direction
    end
    
    % check optional arguments
    for i = 1:length(varargin)
       if strcmp(varargin{i}, 'center')
            path(:,1) = path(:,1) - (x - 1) / 2;
            path(:,2) = path(:,2) - (y - 1) / 2;
            
       elseif strcmp(varargin{i}, 'x')
           % we make it step along the x by exchanging the x and y values
           path = fliplr(path);
       else
           warning('Unknown option for rect_snake_path: %s', varargin{i});
       end
    end
    
    
    figure; plot(path(:,1), path(:,2));
end
