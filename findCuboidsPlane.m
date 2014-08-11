function filledMap = findCuboidsPlane(occupancyMap, threshes)
    xDim = size(occupancyMap,1); zDim = size(occupancyMap,2);
    cuboidMap = zeros(xDim,zDim);
    sizes = [3*4, 6*4; 6*4, 3*4; 3*4, 4*4; 4*4, 3*4; 2*4, 2*4];
    for sizeI=1:size(sizes,1)
        for i=1:numel(threshes)
            thresh = threshes(i);
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, sizes(sizeI,1), sizes(sizeI,2), thresh);
            cuboidMap = cuboidMap | addedMap;
        end
    end
    filledMap = cuboidMap;
        
    if(0)
        for i=1:numel(threshes)
            thresh = threshes(i);
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, 3*4, 6*4, thresh);
            cuboidMap = cuboidMap | addedMap;  
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, 6*4, 3*4, thresh);
            cuboidMap = cuboidMap | addedMap; 
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, 3*4, 4*4, thresh);
            cuboidMap = cuboidMap | addedMap;      
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, 4*4, 3*4, thresh);
            cuboidMap = cuboidMap | addedMap;          
            [addedMap, occupancyMap] = fitCuboids(occupancyMap, 2*4, 2*4, thresh);
            filledMap = cuboidMap | addedMap;       
        end
    end
end

function [addedMap, sourceMapUpdated] = fitCuboids(occupancyMap, xSize, zSize, minCoverage)
    %fprintf('Attempting to fit %d x %d\n', xSize, zSize);
    %fprintf('%d available chunks\n', sum(occupancyMap(:)));
    xDim = size(occupancyMap,1); zDim = size(occupancyMap,2);
    %fprintf('into a %d x %d room\n', xDim, zDim);
    flag = 1;
    addedMap = zeros(xDim, zDim);
    sourceMap = occupancyMap;
    while flag
        fprintf('Doing a round!\n');
        [iterAddedMap, sourceMap] = fitCuboid(sourceMap, xSize, zSize, minCoverage);
        flag = sum(iterAddedMap(:)) > 0;       
        if(flag)
            fprintf('Success!\n');
        end
        sum(sourceMap(:))
        addedMap = addedMap | iterAddedMap;
    end
    fprintf('quitting\n');
    fprintf('added map sum = %d\n', sum(addedMap(:)));
    sourceMapUpdated = sourceMap;
end


function [addedMap, sourceMapUpdated] = fitCuboid(sourceMap,xSize,zSize, minCoverage)
    %fprintf('Attempting to fit %d x %d; avail %d\n', xSize, zSize, sum(sourceMap(:)));
    xDim = size(sourceMap,1); zDim = size(sourceMap,2);
    %fprintf('into a %d x %d room\n', xDim, zDim);
    addedMap = zeros(xDim,zDim);
    bestStartX = -1; bestStartZ = -1; bestCoverage = -1;
    for x=1:xDim-xSize
       for z=1:zDim-zSize
           rect = sourceMap(x:x+xSize-1,z:z+zSize-1);
           occupied = sum(rect(:)); area = xSize*zSize;
           if(occupied / area > minCoverage)
               if(occupied / area > bestCoverage)
                   bestCoverage = occupied / area;
                   bestStartX = x; bestStartZ = z;
               end
           end
       end     
    end
    sourceMapUpdated = sourceMap;
    addedMap = zeros(xDim,zDim);
    if(bestCoverage > 0)
       fprintf('Placing a %d x %d block at %d x %d\n', xSize, zSize, bestStartX, bestStartZ);
       %blankMinX = max(bestStartX - 2,0); blankMinZ = max(bestStartZ -2,0);
       %blankMaxX = min(bestStartX + xSize -1 + 2,xSize); blankMaxZ = min(bestStartZ + zSize -1 + 2,zSize);
       sourceMapUpdated(bestStartX:bestStartX+xSize-1,bestStartZ:bestStartZ+zSize-1) = 0;
       addedMap(bestStartX:bestStartX+xSize-1,bestStartZ:bestStartZ+zSize-1) = 1;        
       fprintf('Added map count: %d\n', sum(addedMap(:)));
    end    
end