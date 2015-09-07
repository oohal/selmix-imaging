function [ phase_spec ] = phase_clamp( in, tol)
    phase_spec = zeros(size(in));
    
    if(nargin < 2)
        tol = 1e-2;
    end
        
    for i = 1:length(in)
        if(abs(in(i)) > tol)
            phase_spec(i) = rad2deg(angle(in(i)));
        end
    end
end