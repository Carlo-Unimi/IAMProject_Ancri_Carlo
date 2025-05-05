function y_mono = stereoToMono(y)
    if size(y, 2) == 2
        y_mono = mean(y, 2);
    else
        y_mono = y;
    end
end