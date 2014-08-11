function score = computeBoxAffordanceScore(box, K, R, sittingHeat, standingHeat)
    global camera_ht;
    
    imageSize = size(sittingHeat);
    
    sittingHeat = binarizeHeatmap(sittingHeat, 0.95, 0.75);
    standingHeat = binarizeHeatmap(standingHeat, 0.95, 0.75);
    
    
    %figure out sitting affordance score
    topMask = getTopSurface(box, K, R, imageSize);
    bottomMask = getBottomSurface(box, K, R, imageSize);

    
    %compute the score
    sumSittingHeat = sum(sittingHeat(:));
    sumStandingHeat = sum(standingHeat(:));
   
    boxImageProject = sum(sum(bottomMask));
    sitIsect = sum(sum(sittingHeat & topMask));
    standIsect = sum(sum(standingHeat & bottomMask));
    
    if(0)
        sumTopSittingHeat = sum(sum(sittingHeat .* topMask));
        score = 0;
        if(sumSittingHeat > 0)
            score = sumTopSittingHeat / sumSittingHeat;
        end

        sumBottomStandingHeat = sum(sum(standingHeat .* bottomMask));
        if(sumStandingHeat > 0)
            heatBottomFrac = sumBottomStandingHeat / sumStandingHeat;
            score = score - min(1.0, heatBottomFrac / 0.1);
        end
    end
    score = 0;
    if(sum(sum(bottomMask)) > 0)
        score = (sitIsect - standIsect) / boxImageProject;
        %score = -standIsect /sum(sum(bottomMask));
    end
    
end


function mask = getTopSurface(box, K, R, imageSize)
    %(Copied from computeMask.m); this is the top surface (note the maximum
    %in Y)
    topSurface = [box.mX box.MX box.MX box.mX;box.MY box.MY box.MY box.MY;box.mZ box.mZ box.MZ box.MZ];
    mask = getSurfaceMask(topSurface, K, R, imageSize);
end


function mask = getBottomSurface(box, K, R, imageSize)
    global camera_ht;
    bottomSurface = [box.mX box.MX box.MX box.mX;box.mY box.mY box.mY box.mY;box.mZ box.mZ box.MZ box.MZ];
    mask = getSurfaceMask(bottomSurface, K, R, imageSize);
end
