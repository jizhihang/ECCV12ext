function floorMaps = floorVoxelConvert(room3D,K,R,img,heatmaps, y)
    % 
    % y  -- is the height of the floor
    %
    %
    %convert the heatmaps into floormaps
        
    minX = room3D.minX;
    maxX = room3D.maxX;
    minZ = room3D.minZ;
    maxZ = room3D.maxZ;
    blockSize = room3D.block_size;
    discrete_blocks = room3D.discreteBlocks;
    xDim =size(discrete_blocks,1); zDim = size(discrete_blocks,3);
    
    floorMaps = {};
    for i=1:numel(heatmaps)
       floorMaps{i} = zeros(xDim,zDim); 
    end
    
    
    for x=room3D.minX:blockSize:room3D.maxX-blockSize
       for z=room3D.minZ:blockSize:room3D.maxZ-blockSize
            mX = x; MX = x+blockSize;
            mZ = z; MZ = z+blockSize;
            mY = y;
           
            xi = max(min(round((mX-minX)/blockSize)+1,size(discrete_blocks,1)),1);
            zi = max(min(round((mZ-minZ)/blockSize)+1,size(discrete_blocks,3)),1);
            
            floorPanel =  [mX MX MX mX;y y y y;mZ mZ MZ MZ];
            panelMask = getSurfaceMask(floorPanel, K, R, size(img));
            
            %imwrite(panelMask, ['mask_dump/' num2str(y,'%f') '_' num2str(xi,'%03d') '_' num2str(zi,'%03d') '_mask.png']);
            
            for i=1:numel(heatmaps)
                vals = panelMask .* heatmaps{i};
                normFactor = sum(panelMask(:));

                
                if(normFactor > 0)
                    floorMaps{i}(xi,zi) = sum(vals(:)) / normFactor;
                else
                    floorMaps{i}(xi,zi) = 0;
                end
                if((mod(zi,10) == 1) && (xi == 1))
                    fprintf(' @(%d)%dx%d <= %f\n',i,xi,zi, floorMaps{i}(xi,zi));
                end
            end
       end
    end
    
end
