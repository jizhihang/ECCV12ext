%%Function that creates hypothesis of cuboids inside the room. The
%%hypothesis are created by sliding the cuboids along the walls and score
%%is estimated based on how many voxels inside the box are occupied.

function[boxhyp] = createBoxHypothesis(room3D,dB,boxes,wall,perp,ht,hn,edge_image,factor,K,R)

    boxhyp = boxes;
    minX = room3D.minX;
    maxX = room3D.maxX;
    minY = 0;
    maxY = room3D.maxY;
    minZ = room3D.minZ;
    maxZ = room3D.maxZ;
    block_size = room3D.block_size;
    discrete_blocks = room3D.discreteBlocks;
    block_height=ht;
    
    %wall 1
    for i=room3D.minX:0.5:room3D.maxX-wall
        %minZ and maxZ
        boxhyp(hn).mX = i;
        boxhyp(hn).MX = i+wall;
        boxhyp(hn).mZ = room3D.maxZ-perp;
        boxhyp(hn).MZ = room3D.maxZ;
        boxhyp(hn).mY = 0;
        boxhyp(hn).MY = block_height;
        min_disc_block_X = max(min(round((boxhyp(hn).mX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        max_disc_block_X = max(min(round((boxhyp(hn).MX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        min_disc_block_Y = max(min(round((0-minY)/block_size)+1,size(discrete_blocks,2)),1);
        max_disc_block_Y = max(min(round((boxhyp(hn).MY-minY)/block_size)+1,size(discrete_blocks,2)),1);
        min_disc_block_Z = max(min(round((boxhyp(hn).mZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        max_disc_block_Z = max(min(round((boxhyp(hn).MZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        A = dB(min_disc_block_X:max_disc_block_X,min_disc_block_Y:max_disc_block_Y,min_disc_block_Z:max_disc_block_Z);
        boxhyp(hn).score = sum(A(:))/numel(A(:))*factor;%(block_height*wall*perp*(1/block_size)^3)*factor; 
        boxhyp(hn).score1 = sum(A(:))/(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).volume = (block_height*wall*perp*(1/block_size)^3);
        hn=hn+1;
    end
    
    %wall2
    for i=room3D.minZ:0.5:room3D.maxZ-wall
        %minZ and maxZ
        boxhyp(hn).mZ = i;
        boxhyp(hn).MZ = i+wall;
        boxhyp(hn).mX = room3D.maxX-perp;
        boxhyp(hn).MX = room3D.maxX;
        boxhyp(hn).mY = 0;
        boxhyp(hn).MY = block_height;
        min_disc_block_X = max(min(round((boxhyp(hn).mX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        max_disc_block_X = max(min(round((boxhyp(hn).MX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        min_disc_block_Y = max(min(round((0-minY)/block_size)+1,size(discrete_blocks,2)),1);
        max_disc_block_Y = max(min(round((boxhyp(hn).MY-minY)/block_size)+1,size(discrete_blocks,2)),1);
        min_disc_block_Z = max(min(round((boxhyp(hn).mZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        max_disc_block_Z = max(min(round((boxhyp(hn).MZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        A = dB(min_disc_block_X:max_disc_block_X,min_disc_block_Y:max_disc_block_Y,min_disc_block_Z:max_disc_block_Z);
        boxhyp(hn).score = sum(A(:))/numel(A(:))*factor;%(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).score1 = sum(A(:))/(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).volume = (block_height*wall*perp*(1/block_size)^3);
        hn=hn+1;
    end

    %wall 3
    for i=room3D.minX:0.5:room3D.maxX-wall
        %minZ and maxZ
        boxhyp(hn).mX = i;
        boxhyp(hn).MX = i+wall;
        boxhyp(hn).mZ = room3D.minZ;
        boxhyp(hn).MZ = room3D.minZ+perp;
        boxhyp(hn).mY = 0;
        boxhyp(hn).MY = block_height;
        min_disc_block_X = max(min(round((boxhyp(hn).mX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        max_disc_block_X = max(min(round((boxhyp(hn).MX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        min_disc_block_Y = max(min(round((0-minY)/block_size)+1,size(discrete_blocks,2)),1);
        max_disc_block_Y = max(min(round((boxhyp(hn).MY-minY)/block_size)+1,size(discrete_blocks,2)),1);
        min_disc_block_Z = max(min(round((boxhyp(hn).mZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        max_disc_block_Z = max(min(round((boxhyp(hn).MZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        A = dB(min_disc_block_X:max_disc_block_X,min_disc_block_Y:max_disc_block_Y,min_disc_block_Z:max_disc_block_Z);
        boxhyp(hn).score = sum(A(:))/numel(A(:))*factor;%(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).score1 = sum(A(:))/(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).volume = (block_height*wall*perp*(1/block_size)^3);
        hn=hn+1;
    end
    
    %wall2
    for i=room3D.minZ:0.5:room3D.maxZ-wall
        %minZ and maxZ
        boxhyp(hn).mZ = i;
        boxhyp(hn).MZ = i+wall;
        boxhyp(hn).mX = room3D.minX;
        boxhyp(hn).MX = room3D.minX+perp;
        boxhyp(hn).mY = 0;
        boxhyp(hn).MY = block_height;
        min_disc_block_X = max(min(round((boxhyp(hn).mX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        max_disc_block_X = max(min(round((boxhyp(hn).MX-minX)/block_size)+1,size(discrete_blocks,1)),1);
        min_disc_block_Y = max(min(round((0-minY)/block_size)+1,size(discrete_blocks,2)),1);
        max_disc_block_Y = max(min(round((boxhyp(hn).MY-minY)/block_size)+1,size(discrete_blocks,2)),1);
        min_disc_block_Z = max(min(round((boxhyp(hn).mZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        max_disc_block_Z = max(min(round((boxhyp(hn).MZ-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        A = dB(min_disc_block_X:max_disc_block_X,min_disc_block_Y:max_disc_block_Y,min_disc_block_Z:max_disc_block_Z);
        boxhyp(hn).score = sum(A(:))/numel(A(:))*factor;%(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).score1 = sum(A(:))/(block_height*wall*perp*(1/block_size)^3)*factor;
        boxhyp(hn).volume = (block_height*wall*perp*(1/block_size)^3);
        hn=hn+1;
    end
    
    
end