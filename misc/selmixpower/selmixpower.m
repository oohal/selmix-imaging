% Functions for solving self—mixing equations—Kliese et al., 2014
function power = selmixpower (C, phi0, alpha) % Power level at a sample in time
    if (C <= 1.0)
        [phimin, phimax] = boundsweak (C, phi0);
    else
        [phimin, phimax] = boundsstrong (C, phi0, alpha);
    end
    
    excessphase = @(x)x - phi0 + C*sin(x + atan(alpha));
    
    % If the value at the left bound positive, then it will be very close to the solution.
    % If the value at the upper bound is negative, it will be very close to the solution.
    
    if (excessphase (phimin) > 0)
        excessphase (phimin);
        phi = phimin;
    elseif (excessphase (phimax) < 0)
        excessphase (phimax);
        phi = phimax;
    else
        phi = fzero (excessphase, [phimin, phimax]);
    end
    
    power = cos (phi);
end

function [phimin, phimax] = boundsweak (C, phi0) % Find search region when C < = 1
    phimin = phi0 - C;
    phimax = phi0 + C;
end

function [phimin, phimax] = boundsstrong (C, phi0, alpha) % Find search region when C > = 1
    persistent m; % Solution region number
    
    if isempty (m); m = 0; end
    
    % Calculate upper & lower values of m where solutions exist then ensure m is between them
    mlower = ceil ((phi0 + atan (alpha) + acos (1/C) - sqrt (C*C - 1))/(2*pi) - 1.5);
    mupper = floor ((phi0 + atan (alpha) - acos (1/C) + sqrt (C*C - 1))/(2*pi) - 0.5);
    
    if (m < mlower); m = mlower; end
    if (m > mupper); m = mupper; end
    
    phimin = (2*m+1)*pi + acos (1/C) - atan (alpha); % Trough
    phimax = (2*m+3)* pi - acos (1/C) - atan (alpha); % Peak
end