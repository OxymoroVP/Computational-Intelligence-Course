function [dh, dv] = getSensorData(pos)
    % Update horizontal data
    x = pos(1);
    y = pos(2);

    if y <= 1
        dh = max(0, min(1, 5 - x));
    elseif y <= 2
        dh = max(0, min(1, 6 - x));
    elseif y <= 3
        dh = max(0, min(1, 7 - x));
    else
        dh = 1;
    end

    % Update vertical data
    if x <= 5
        dv = y;
    elseif x <= 6
        dv = max(0, min(1, y - 1));
    elseif x <= 7
        dv = max(0, min(1, y - 2));
    else
        dv = max(0, min(1, y - 3));
    end
end
