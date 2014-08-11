function v0 = getHorizonLine(vpdata)
    Y = vpdata.vp(:,2);
    [~, bottomVPIndex] = max(Y);
    v0 = (sum(Y) - Y(bottomVPIndex)) / 2;
end