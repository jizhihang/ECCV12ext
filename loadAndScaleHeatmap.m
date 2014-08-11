function heatmap = loadAndScaleHeatmap(filename, mDims)
    origHData = load(filename);
    origH = origHData.heatmap;
%    origH = dlmread(filename);
    heatmap = zeros(mDims);
    yScale = size(origH,1) / mDims(1); xScale = size(origH,2) / mDims(2);
    origX = 1:mDims(2); origY = 1:mDims(1);
    [X,Y] = meshgrid(1 + ((origX - 1) .* xScale), 1 + ((origY - 1) .* yScale));
    heatmap = interp2(origH, X, Y, 'linear',0.0);
end
