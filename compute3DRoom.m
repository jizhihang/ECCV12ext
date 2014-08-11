function[room3D] = compute3DRoom(K,R,img,room)
    
    global camera_ht;
    flag = true;
    
    while flag
        
        room3D.visibilities = [0 0 0 0];
        %5 types of room in lee's matfiles based on visibilities of walls
        %and cielings.
        
        % room type:
        %  1.      2.       3.        4.        5.                    
        %                      \           /       \     /            
        %                       1--     --2         1---2             
        %    |        |         |         |         |   |             
        %    3--    --4         3--     --4         3---4             
        %   /          \       /           \       /     \            
        %
        
        switch room.type
            %%All Cases 3 steps
            %Step 1: Compute Points on the Ground (Wall and Floor
            %intersection corners
            
            %%Step 2: Compute if Walls will be Visible or not (4 walls,
            %%floor, cieling
            
            %%Step 3: Compute the Height of the Room
            
            
            case {1,3}
                %Case 1,3, Left Wall and Center
                gL = zeros(4,2);
                
                %Compute 3 Points on the Ground in 3D
                [groundPts(1,1) groundPts(1,2)] = img_to_norm_img(room.box(1).p2(1),room.box(1).p2(2),size(img,2),size(img,1));
                [groundPts(2,1) groundPts(2,2)] = img_to_norm_img(room.box(1).p4(1),room.box(1).p4(2),size(img,2),size(img,1));
                [groundPts(3,1) groundPts(3,2)] = img_to_norm_img(room.box(2).p4(1),room.box(2).p4(2),size(img,2),size(img,1));
                groundPts(1:4,3) = 1;
                [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
                [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
                [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
                groundPts(4,:) = [size(img,2)/size(img,1) -1 1];
                [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
                
                
                %%Compute Wall Visibilities
                if abs(gL(1,1)-gL(2,1))<abs(gL(1,2)-gL(2,2))
                    if abs(gL(1,1)-min(gL(:,1)))<abs(gL(1,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(1,2)-min(gL(:,2)))<abs(gL(1,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                    
                end
                
                
                if abs(gL(3,1)-gL(2,1))<abs(gL(3,2)-gL(2,2))
                    if abs(gL(3,1)-min(gL(:,1)))<abs(gL(3,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(3,2)-min(gL(:,2)))<abs(gL(3,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                end
                
                %Compute Height of the Room
                vH = zeros(2,1);
                [verticalPts(1,1) verticalPts(1,2)] = img_to_norm_img(room.box(1).p3(1),room.box(1).p3(2),size(img,2),size(img,1));
                verticalPts(1:2,3) = 1;
                vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
                
            case {2,4}
                gL = zeros(4,2);
                groundPts(1,:) = [-size(img,2)/size(img,1) -1 1];
                [groundPts(2,1) groundPts(2,2)] = img_to_norm_img(room.box(1).p2(1),room.box(1).p2(2),size(img,2),size(img,1));
                [groundPts(3,1) groundPts(3,2)] = img_to_norm_img(room.box(1).p4(1),room.box(1).p4(2),size(img,2),size(img,1));
                [groundPts(4,1) groundPts(4,2)] = img_to_norm_img(room.box(2).p4(1),room.box(2).p4(2),size(img,2),size(img,1));
                groundPts(1:4,3) = 1;
                
                [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
                [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
                [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
                [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
                
                
                
                if abs(gL(3,1)-gL(2,1))<abs(gL(3,2)-gL(2,2))
                    if abs(gL(3,1)-min(gL(:,1)))<abs(gL(3,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(3,2)-min(gL(:,2)))<abs(gL(3,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                end
                if abs(gL(3,1)-gL(4,1))<abs(gL(3,2)-gL(4,2))
                    if abs(gL(3,1)-min(gL(:,1)))<abs(gL(3,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(3,2)-min(gL(:,2)))<abs(gL(3,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                end
                
                vH = zeros(2,1);
                if numel(room.box(2).p3)<2
                    [verticalPts(1,1) verticalPts(1,2)] = img_to_norm_img(-size(img,2)/size(img,1),1,size(img,2),size(img,1));

                else
                    [verticalPts(1,1) verticalPts(1,2)] = img_to_norm_img(room.box(1).p1(1),room.box(1).p1(2),size(img,2),size(img,1));

                end
                
                [verticalPts(2,1) verticalPts(2,2)] = img_to_norm_img(room.box(2).p1(1),room.box(2).p1(2),size(img,2),size(img,1));
                verticalPts(1:2,3) = 1;

                vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
                vH(2) = computeNonGroundFast(K,R,verticalPts(2,:)',gL(3,1),gL(3,2));
            case 5
                gL = zeros(4,2);
                [groundPts(1,1) groundPts(1,2)] = img_to_norm_img(room.box(1).p2(1),room.box(1).p2(2),size(img,2),size(img,1));
                [groundPts(2,1) groundPts(2,2)] = img_to_norm_img(room.box(1).p4(1),room.box(1).p4(2),size(img,2),size(img,1));
                [groundPts(3,1) groundPts(3,2)] = img_to_norm_img(room.box(3).p2(1),room.box(3).p2(2),size(img,2),size(img,1));
                [groundPts(4,1) groundPts(4,2)] = img_to_norm_img(room.box(3).p4(1),room.box(3).p4(2),size(img,2),size(img,1));
                groundPts(1:4,3) = 1;

                
                [gL(1,1) gL(1,2)] = computeGroundPts(K,R,groundPts(1,:));
                [gL(2,1) gL(2,2)] = computeGroundPts(K,R,groundPts(2,:));
                [gL(3,1) gL(3,2)] = computeGroundPts(K,R,groundPts(3,:));
                [gL(4,1) gL(4,2)] = computeGroundPts(K,R,groundPts(4,:));
                vH = zeros(2,1);
                
                [verticalPts(1,1) verticalPts(1,2)] = img_to_norm_img(room.box(1).p3(1),room.box(1).p3(2),size(img,2),size(img,1));
                [verticalPts(2,1) verticalPts(2,2)] = img_to_norm_img(room.box(3).p3(1),room.box(3).p3(2),size(img,2),size(img,1));
                verticalPts(1:2,3) = 1;
                vH(1) = computeNonGroundFast(K,R,verticalPts(1,:)',gL(2,1),gL(2,2));
                vH(2) = computeNonGroundFast(K,R,verticalPts(2,:)',gL(3,1),gL(3,2));
                if abs(gL(1,1)-gL(2,1))<abs(gL(1,2)-gL(2,2))
                    if abs(gL(1,1)-min(gL(:,1)))<abs(gL(1,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(1,2)-min(gL(:,2)))<abs(gL(1,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                    
                end
                if abs(gL(3,1)-gL(2,1))<abs(gL(3,2)-gL(2,2))
                    if abs(gL(3,1)-min(gL(:,1)))<abs(gL(3,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(3,2)-min(gL(:,2)))<abs(gL(3,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                end
                if abs(gL(3,1)-gL(4,1))<abs(gL(3,2)-gL(4,2))
                    if abs(gL(3,1)-min(gL(:,1)))<abs(gL(3,1)-max(gL(:,1)))
                        room3D.visibilities(1) = 1;
                    else
                        room3D.visibilities(2) = 1;
                    end
                else
                    if abs(gL(3,2)-min(gL(:,2)))<abs(gL(3,2)-max(gL(:,2)))
                        room3D.visibilities(3) = 1;
                    else
                        room3D.visibilities(4) = 1;
                    end
                end
                
                
        end
        
        %quarter of an feet = 3 inches
        block_size = 0.25;
        
        % Discretize the room: Compute Max and Mins of XYZ
        minX = min(min(gL(:,1)),0);
        maxX = min(max(gL(:,1)),block_size*500);
        minY = 0;
        maxY = max(vH);
        minZ = min(min(gL(:,2)),0);
        maxZ = min(max(gL(:,2)),block_size*500);
        
        %Check if height of the room is between 8-12 feet...yes => sounds
        %good....no=> change camera height until we have good height
        %ceilings
        if ismember(room.type,[3 4 5])
            if maxY-minY > 12
                camera_ht = camera_ht - 0.5;
            elseif maxY-minY < 8
                camera_ht = camera_ht + 0.5;
            else
                flag=false;
            end
        else
            mD = max(max(gL(:,1))-min(gL(:,1)),max(gL(:,2))-min(gL(:,2)));
            if mD > 15
                camera_ht = camera_ht - 0.5;
            elseif mD < 4
                camera_ht = camera_ht + 0.5;
            else
                flag = false;
            end
        end
    end

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