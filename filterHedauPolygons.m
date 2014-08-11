function [rerankFactor, areas]  = filterHedauPolygons(polygons, standHeatmap, ii, gridArea)
    %Continuous -> binary stand heatmap
    %figure out thresholds
    standVals = standHeatmap(:);
    standVals = standVals(standVals > 0);
    heatQuantiles = [0.95, 0.25];
    threshAt = quantile(standVals, heatQuantiles);

    standHeatmap = max(standHeatmap - threshAt(2),0); 
    standHeatmap = standHeatmap ./ (threshAt(1) - threshAt(2));

    h = size(standHeatmap,1); w = size(standHeatmap, 2);
    rerankFactor = zeros(size(polygons,1),1);
    areas = zeros(size(polygons,1), 1);
    standHeatSum = sum(sum(standHeatmap));
    dilationFactor = max(w,h) * 0.1;
    
    parfor i=1:size(polygons,1)
        if(numel(polygons{i,1}) == 0)
            %reject those with no floor.
            rerankFactor(i) = 10;
            continue;          
        end
        
        floorPoly = poly2mask(polygons{i,1}(:,1), polygons{i,1}(:,2), h, w);
        D = bwdist(floorPoly);
        floorPoly = exp(-(D ./ dilationFactor));
        
        score = 1.0;
        if(standHeatSum > 0)
            floorHeatSum = sum(sum(floorPoly .* standHeatmap));
            offFloorFrac = 1.0 - (floorHeatSum / standHeatSum);
            
            standingScoreInverse = min(max(0.0, offFloorFrac*2), 1.0);
            score = score * (1.0 - standingScoreInverse);
        end
        
        area = sum(sum(floorPoly .* gridArea));
        areas(i) = area;
        rerankFactor(i) = (1.0 - score);
    end
    
end
