%%Function which given Vanishing Points, Camera Calibration and Box Layout
%%from Hedau et al. creates a 3D room estimate.
%%
%%
%%Based on code from Hedau et al. Please see freespace code for
%%explanations.
function[room3D,K1,R1] = compute3DRoom_V(Polyg,vp,h,w,img,K1,R1)
        global camera_ht;
        
        flag = true;
        R = R1;
        R(2,:) = -R1(2,:);
        K = K1;
        K(2,3) = -K1(2,3)+1;
        K(1,3) = K1(1,3)+size(img,2)/size(img,1);
        K = K*size(img,1)/2;
        K(3,3) = 1;
        
        while flag            

           [room_ht room_wt SurfaceNormals DistfromSurface DistOn visplanes corners3D K R]=getWallCorners(Polyg,vp,h,w,K,R);
           [pts_c]=warpimg3D(img,h,w,DistfromSurface,SurfaceNormals,visplanes,Polyg,R,K,102);
           
           [Xc Yc Zc Xc_floor Yc_floor Zc_floor Xc_dummy Yc_dummy,Zc_dummy]=createVoxelgrid(pts_c,Polyg,R,K,h,w,camera_ht);
            
            block_size=0.25;
            Xc=Xc_dummy;
            Yc=Yc_dummy;
            Zc=Zc_dummy;
            Yc = Yc+camera_ht;
            minX = min(min(Xc),0);
            maxX = max(Xc)+block_size;
            minY = min(Yc);
            maxY = max(Yc)+block_size;
            minZ = min(min(Zc),0);
            maxZ = max(Zc)+block_size;
            if visplanes(5)==1
                if maxY-minY > 12
                    camera_ht = camera_ht - 0.5;
                elseif maxY-minY < 8
                    camera_ht = camera_ht + 0.5;
                else
                    mD = max(max(Zc)-min(Zc),max(Xc)-min(Xc));
                    if mD > 15
                        camera_ht = camera_ht - 0.5;
                    elseif mD < 4
                        camera_ht = camera_ht + 0.5;
                    else
                        flag = false;
                    end
                end
               
            else
                mD = max(max(Zc)-min(Zc),max(Xc)-min(Xc));
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
        
        
        room3D.visibilities = [0 0 0 0];
        if visplanes(2)==1
            %get 4 corners of middle wall
            corners = [1 h;w h];
            numV = size(Polyg{2},1);
            dists = (corners(:,1)*ones(1,numV)-ones(2,1)*Polyg{2}(:,1)').^2 + ...
                (corners(:,2)*ones(1,numV)-ones(2,1)*Polyg{2}(:,2)').^2;
            [vv,ii] = min(dists,[],2);
            corner_bl = Polyg{2}(ii(1),:);
            corner_br = Polyg{2}(ii(2),:);
            n = [0;1;0];
            p1 = [corner_bl(1); corner_bl(2); 1];
            p2 = [corner_br(1); corner_br(2); 1];
            P1 = R'*(-camera_ht * K^-1* p1 / ((R*n)' * K^-1 * p1));            
            P2 = R'*(-camera_ht * K^-1* p2 / ((R*n)' * K^-1 * p2));
            if abs(P1(1)-P2(1)) < abs(P1(3)-P2(3))
                if abs(P1(1)-minX) < abs(P1(1)-maxX)
                    room3D.visibilities(1)=1;
                else
                    room3D.visibilities(2)=1;
                end
            else
                room3D.visibilities(4)=1;
            end
        end
        
        if visplanes(3)==1
            corners = [w h];
            numV = size(Polyg{3},1);
            dists = (corners(:,1)*ones(1,numV)-ones(1,1)*Polyg{3}(:,1)').^2 + ...
                (corners(:,2)*ones(1,numV)-ones(1,1)*Polyg{3}(:,2)').^2;
            [vv,ii] = min(dists,[],2);
            corner_rbr = Polyg{3}(ii,:);
            n = [0;1;0];
            p1 = [corner_rbr(1); corner_rbr(2); 1];
            P11 = R'*(-camera_ht * K^-1* p1 / ((R*n)' * K^-1 * p1));  
            if abs(P11(1)-P2(1)) < abs(P11(3)-P2(3))
                if abs(P11(1)-minX) < abs(P11(1)-maxX)
                    room3D.visibilities(1)=1;
                else
                    room3D.visibilities(2)=1;
                end
            else
                room3D.visibilities(4)=1;
            end
        end
        if visplanes(4)==1
            corners = [1 h];
            numV = size(Polyg{4},1);
            dists = (corners(:,1)*ones(1,numV)-ones(1,1)*Polyg{4}(:,1)').^2 + ...
                (corners(:,2)*ones(1,numV)-ones(1,1)*Polyg{4}(:,2)').^2;
            [vv,ii] = min(dists,[],2);
            corner_lbr = Polyg{4}(ii,:);
            n = [0;1;0];
            p2 = [corner_lbr(1); corner_lbr(2); 1];
            P2 = R'*(-camera_ht * K^-1* p2 / ((R*n)' * K^-1 * p2));  
            if abs(P1(1)-P2(1)) < abs(P1(3)-P2(3))
                if abs(P1(1)-minX) < abs(P1(1)-maxX)
                    room3D.visibilities(1)=1;
                else
                    room3D.visibilities(2)=1;
                end
            else
                room3D.visibilities(4)=1;
            end
        end
        
        
        room3D.discreteBlocks = discrete_blocks;
        room3D.minX = minX;
        room3D.minY = minY;
        room3D.minZ = minZ;
        room3D.maxX = maxX;
        room3D.maxY = maxY;
        room3D.maxZ = maxZ;
        room3D.block_size = block_size;
       
end
