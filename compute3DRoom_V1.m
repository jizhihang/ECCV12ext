function[room3D] = compute3DRoom_V1(Polyg,K,R,img,vH)
    
    global camera_ht;
    gL = zeros(size(Polyg{1},1),2);
    groundPoints = zeros(size(Polyg{1},1),3);
    
    %Compute 3 Points on the Ground in 3D
    for i=1:size(Polyg{1},1)
        [groundPts(i,1) groundPts(i,2)] = img_to_norm_img(Polyg{1}(i,1),Polyg{1}(i,2),size(img,2),size(img,1));
        groundPts(i,3) = 1;
        [gL(i,1) gL(i,2)] = computeGroundPts(K,R,groundPts(i,:));
    end
    
    gL
    %quarter of an feet = 3 inches
    block_size = 0.25;
        
    % Discretize the room: Compute Max and Mins of XYZ
    minX = min(min(gL(:,1)),0);
    maxX = min(max(gL(:,1)),block_size*500);
    minY = 0;
    maxY = abs(vH);
    minZ = min(min(gL(:,2)),0);
    maxZ = min(max(gL(:,2)),block_size*500);
    
        discrete_blocks = zeros(round((maxX-minX)/block_size), round((maxY-minY)/block_size), round((maxZ-minZ)/block_size));

        
          %setup room3D datastructure finally.
    room3D.discreteBlocks = discrete_blocks;
    room3D.minX = minX;
    room3D.minY = minY;
    room3D.minZ = minZ;
    room3D.maxX = maxX;
    room3D.maxY = maxY;
    room3D.maxZ = maxZ;
    room3D.block_size = block_size;
end
