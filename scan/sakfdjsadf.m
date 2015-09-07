figure; hold on;

for i = 1:200
    for j = 1:200
        if phase_pic(i,j) > 0.5
            phase_pic2(i,j) = phase_pic(i,j) - 1;
        else
            phase_pic2(i,j) = phase_pic(i,j);
        end
        
        plot(mag_pic(i,j), phase_pic2(i,j), '*')
    end
end

figure; imshow(phase_pic2)