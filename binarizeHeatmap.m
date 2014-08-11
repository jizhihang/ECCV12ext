function binaryHeatmap = binarizeHeatmap(heatmap, threshHigh, threshLow)
    vals = heatmap(:);
    vals = vals(vals > 0);
    heatQuantiles = [threshHigh, threshLow];
    threshAt = quantile(vals, heatQuantiles);
    binaryHeatmap = double(hysthresh(heatmap, threshAt(1), threshAt(2)));
end