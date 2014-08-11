function [room3D] = doInverseVoxelFill(imagename,imgnum,room3D,K,R,imsegs, img)
    global camera_ht;
    
    sitHeight = 0.75;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Get clutter map data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%  Get obj confidences
    filename=fullfile('../dataset/hedauOutput/',[imagename(1:end-4) '_lc_st2.mat' ]);
    load(filename);
    pg={avg_pg};
    cimages = msPg2confidenceImages(imsegs(imgnum),pg);
    objconf=cimages{1}(:,:,6);
    objmask=objconf>0.45;
    
    %% Backproject the clutter labels to create occupied voxel maps 
    dB =  backProject(room3D,K,R,objmask,objconf);

    %take the max over the voxel map to get the labels
    collapsed = max(dB,[],2);
    collapsed = reshape(collapsed,[size(collapsed,1), size(collapsed,3)]);
   
    filename=fullfile('../dataset/hedauOutput/',[imagename(1:end-4) '_lc_st2.mat' ]);
    load(filename);
    pg={avg_pg};
    cimages = msPg2confidenceImages(imsegs(imgnum),pg);
    objconf=cimages{1}(:,:,6);

    objconfRaw = objconf;
    objconf = objconf ./ max(objconf(:));
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Load the affordance maps
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    standHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.standHeat.mat']), size(img));
    sitHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.sitHeat.mat']), size(img));
    sitFeetHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.sitfeetHeat.mat']),size(img));
   
    %normalization factors -- there were some old ones, but they do not work on newly calibrated scores
    normSit = 1/8; normStand = 1/8; normReach = 1/8;

    %normalize
    nStand = standHeatmap / normStand;
    nSit = sitHeatmap / normSit;
    nSitFeet = sitFeetHeatmap / normSit;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Do some stuff then backproject affordance maps
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %precompute
    block_size = room3D.block_size;
    discrete_blocks = zeros(size(room3D.discreteBlocks));
    discrete_blocks = double(dB > 0.5);
    xDim =size(discrete_blocks,1); zDim = size(discrete_blocks,3);
   


    standDilateSize = floor(size(nStand,2) / 10);
    nStand = imdilate(nStand,strel('rectangle',[standDilateSize,standDilateSize]));
    
   
    maxNorm = max([max(nStand(:)),max(nSit(:))]);
    oc = objconf * maxNorm;
   
    %this backprojects the affordance map onto the tops of cubes
    floorMaps = floorVoxelConvert(room3D, K, R, img, {0.5 .* nStand}, 0);
    floorMaps{1} = imdilate(floorMaps{1},strel('rectangle',[2,2]));
    sitMaps = floorVoxelConvert(room3D, K, R, img, {0.5 .* oc + 0.5 .* nSit}, sitHeight);


    %So sitMaps and floorMaps are slices of the voxel grid containing the "sittingness" and
    %standingness of the grid. If we subtract their difference

    diffMap = (sitMaps{1} - floorMaps{1});


    maxSitY = max(min(round((sitHeight-0)/block_size)+1,size(discrete_blocks,2)),1);

    %get rid of clutter above the sittable part of the image
    discrete_blocks(:,maxSitY:end,:) = 0;
   
    %get rid of clutter right near the camear
    for x=1:floor(xDim/5)
        for z=1:floor(zDim/5)
            diffMap(x,z) = 0;            
        end
    end
   
    %add the clutter + affordance cues
    for yi=1:maxSitY-1
        discrete_blocks(:,yi,:) = discrete_blocks(:,yi,:) + reshape(diffMap,[xDim,1,zDim]);
    end


     
    valSet = (sum(room3D.discreteBlocks(:,1:maxSitY,:),2) ./ maxSitY) > 0.5;

    valSet = reshape(valSet, [xDim,zDim]);

    %Here's where morphological stuff might help
%    valSet = double(imerode(uint8(valSet), strel('rectangle',[7,7])));
%    valSet = double(imdilate(uint8(valSet), strel('rectangle',[5,5])));

    for yi=1:maxSitY
        fprintf('filling in the slices\n');
        room3D.discrete_blocks(:,yi,:) = reshape(valSet, [xDim, 1, zDim]);
    end


    %I'm leaving these in: these are other ways you could filter the continuous stuff
    %Just threshold
    %room3D.discreteBlocks = discrete_blocks > cutThresh;  

    %Threshold and intersect with the original blocks from clutter
    %room3D.discreteBlocks = (discrete_blocks>cutThresh) & (dB > 0.3);

    room3D.discreteBlocks = discrete_blocks;
    
end

