%%Training Script
files = dir('./test/*.mat');
for i=125:-1:1
    %%Load D. Lee's results
    load(['./test/' files(i).name],'endresult','img','gcimg');
    imshow(img);
    
    %%Compute Camera Matrix
    corg = [round(size(img,2)/2) round(size(img,1)/2)];
    aspect = size(img,2)/size(img,1);
    
    V(:,1) = [(endresult.vp{1}(1)-corg(1))/corg(1) (-endresult.vp{1}(2)+corg(2))/corg(2)]';
    V(:,2) = [(endresult.vp{2}(1)-corg(1))/corg(1) (-endresult.vp{2}(2)+corg(2))/corg(2)]';
    V(:,3) = [(endresult.vp{3}(1)-corg(1))/corg(1) (-endresult.vp{3}(2)+corg(2))/corg(2)]';
    
    [K,R] = calibrate_camera(V);
    
    
    %% Estimate End Points on the Ground to get Ground Limits
    groundPts = zeros(4,3);
    verticalPts = zeros(2,3);
    
    room = endresult.roomhyp(endresult.bestcfg.bld);
    figure(5);
    disp_room(room,img);
    %room = endresult.roomhyp(10);
    switch room.type
        case {1,3}
            gL = zeros(4,2);
            groundPts(1,:) = [(room.box(1).p2(1)-corg(1))/corg(1)  (-room.box(1).p2(2)+corg(2))/corg(2) 1];
            [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
            groundPts(2,:) = [(room.box(1).p4(1)-corg(1))/corg(1)  (-room.box(1).p4(2)+corg(2))/corg(2) 1];
            [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
            groundPts(3,:) = [(room.box(2).p4(1)-corg(1))/corg(1)  (-room.box(2).p4(2)+corg(2))/corg(2) 1];
            [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
            groundPts(4,:) = [size(img,2)/size(img,1) -1 1];
            [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
            vH = zeros(2,1);
            verticalPts(1,:) = [(room.box(1).p3(1)-corg(1))/corg(1)  (-room.box(1).p3(2)+corg(2))/corg(2) 1];
            if numel(room.box(2).p3)<2
                verticalPts(2,:) = [size(img,2)/size(img,1) 1 1];
            else
                verticalPts(2,:) = [(room.box(2).p3(1)-corg(1))/corg(1)  (-room.box(2).p3(2)+corg(2))/corg(2) 1];
            end
            vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
            vH(2) = computeNonGroundFast(K,R,verticalPts(2,:)',gL(3,1),gL(3,2));
   
        case {2,4}
            gL = zeros(4,2);
            groundPts(1,:) = [-size(img,2)/size(img,1) -1 1];
            [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
            groundPts(2,:) = [(room.box(1).p2(1)-corg(1))/corg(1)  (-room.box(1).p2(2)+corg(2))/corg(2) 1];
            [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
            groundPts(3,:) = [(room.box(1).p4(1)-corg(1))/corg(1)  (-room.box(1).p4(2)+corg(2))/corg(2) 1];
            [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
            groundPts(4,:) = [(room.box(2).p4(1)-corg(1))/corg(1)  (-room.box(2).p4(2)+corg(2))/corg(2) 1];
            [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
            vH = zeros(2,1);
            if numel(room.box(2).p3)<2
                 verticalPts(1,:) = [-size(img,2)/size(img,1) 1 1];
            else
                verticalPts(1,:) = [(room.box(1).p1(1)-corg(1))/corg(1)  (-room.box(1).p1(2)+corg(2))/corg(2) 1];
            end
            
           
            verticalPts(2,:) = [(room.box(2).p1(1)-corg(1))/corg(1)  (-room.box(2).p1(2)+corg(2))/corg(2) 1];
            vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
            vH(2) = computeNonGroundFast(K,R,verticalPts(2,:)',gL(3,1),gL(3,2));           
         case 5
            gL = zeros(4,2);
            groundPts(1,:) = [(room.box(1).p2(1)-corg(1))/corg(1)  (-room.box(1).p2(2)+corg(2))/corg(2) 1];
            [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
            groundPts(2,:) = [(room.box(1).p4(1)-corg(1))/corg(1)  (-room.box(1).p4(2)+corg(2))/corg(2) 1];
            [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
            groundPts(3,:) = [(room.box(3).p2(1)-corg(1))/corg(1)  (-room.box(3).p2(2)+corg(2))/corg(2) 1];
            [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
            groundPts(4,:) = [(room.box(3).p4(1)-corg(1))/corg(1)  (-room.box(3).p4(2)+corg(2))/corg(2) 1];
            [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
            vH = zeros(2,1);
            verticalPts(1,:) = [(room.box(1).p3(1)-corg(1))/corg(1)  (-room.box(1).p3(2)+corg(2))/corg(2) 1];
            verticalPts(2,:) = [(room.box(3).p1(1)-corg(1))/corg(1)  (-room.box(3).p1(2)+corg(2))/corg(2) 1];
            vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
            vH(2) = computeNonGroundFast(K,R,verticalPts(2,:)',gL(3,1),gL(3,2));                  
    end
            
    block_size = 1;
        
    % Discretize the room
    minX = min(min(gL(:,1)),0);
    maxX = min(max(gL(:,1)),block_size*500);
    minY = 0;
    maxY = max(vH);
    minZ = min(min(gL(:,2)),0);
    maxZ = min(max(gL(:,2)),block_size*500);
   

    discrete_blocks = zeros(round((maxX-minX)/block_size), round((maxY-minY)/block_size), round((maxZ-minZ)/block_size));
    
    %%Loop over cuboid hypothesis and get occupancy map ?
    for j=1:numel(endresult.cuboidhyp)       
        gpInd = [3 4 7 8];
        vpInd = [1 2 5 6];
        X = zeros(4,1);
        Y = zeros(4,1);
        Z = zeros(4,1);
        for k=1:length(gpInd)
            %%Compute Ground Point
            x1 = endresult.cuboidhyp(j).junc3(gpInd(k)).pt(1);
            y1 = endresult.cuboidhyp(j).junc3(gpInd(k)).pt(2);
            gP = [(x1-corg(1))/corg(1) (-y1+corg(2))/corg(2) 1];
            [X(k) Z(k)] = computeGroundPts(K,R,gP);
            %%Compute Corresponding Vertical Point
            x1 = endresult.cuboidhyp(j).junc3(vpInd(k)).pt(1);
            y1 = endresult.cuboidhyp(j).junc3(vpInd(k)).pt(2);
            vP = [(x1-corg(1))/corg(1) (-y1+corg(2))/corg(2) 1];
            Y(k) = computeNonGroundFast(K,R,vP',X(k),Z(k));
        end       
        min_disc_block_X = max(min(round((min(X)-minX)/block_size)+1,size(discrete_blocks,1)),1);
        max_disc_block_X = max(min(round((max(X)-minX)/block_size)+1,size(discrete_blocks,1)),1);
        min_disc_block_Y = max(min(round((0-minY)/block_size)+1,size(discrete_blocks,2)),1);
        max_disc_block_Y = max(min(round((max(Y)-minY)/block_size)+1,size(discrete_blocks,2)),1);
        min_disc_block_Z = max(min(round((min(Z)-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        max_disc_block_Z = max(min(round((max(Z)-minZ)/block_size)+1,size(discrete_blocks,3)),1);
        
        discrete_blocks(min_disc_block_X:max_disc_block_X, min_disc_block_Y:max_disc_block_Y, min_disc_block_Z:max_disc_block_Z) = discrete_blocks(min_disc_block_X:max_disc_block_X, min_disc_block_Y:max_disc_block_Y, min_disc_block_Z:max_disc_block_Z)+1;
    end

    figure(2);
    imagesc(squeeze(sum(discrete_blocks, 2)));
    title('Top View');
    figure(3);
    imagesc(squeeze(sum(discrete_blocks, 3)));
    title('Side View');
    figure(4);
    disp_cubes(endresult.cuboidhyp, img);
    pause;
    %%How do we normalize ??
    
    
    %% Prepare Features
    omap = imresize(endresult.omapmore,[size(img,1) size(img,2)],'nearest');
    %%Two Features: omap, gcimg
    
    
    
    %%Given a block predict th volumetric
    close all
    
end
