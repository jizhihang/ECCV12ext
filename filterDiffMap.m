function filteredImage = filterDiffMap(diffMap, minSquares)
    CC = bwconncomp(diffMap);
    ccFiltered = zeros(size(diffMap));

    for i=1:numel(CC.PixelIdxList)
        fprintf('Considering %d; has %d squares\n', i, numel(CC.PixelIdxList{i}));
        if(numel(CC.PixelIdxList{i}) >= minSquares)
            fprintf('Accepting!\n');            
            ccFiltered(CC.PixelIdxList{i}) = 1;
        else
            fprintf('Rejecting!\n');
        end        
    end
    
    filteredImage = ccFiltered;
end
