function[room3D,K,R] = computeLayouts_Lee(img,endresult,room)
        
        %%This function loads box results of Lee et al and uses that to obtain
        %%room estimates.
        V = zeros(2,3);
        [V(1,1) V(2,1)] = img_to_norm_img(endresult.vp{1}(1),endresult.vp{1}(2),size(img,2),size(img,1));
        [V(1,2) V(2,2)] = img_to_norm_img(endresult.vp{2}(1),endresult.vp{2}(2),size(img,2),size(img,1));
        [V(1,3) V(2,3)] = img_to_norm_img(endresult.vp{3}(1),endresult.vp{3}(2),size(img,2),size(img,1));  
        %%Do Camera Calibration Using Vanishing Points
        [K R]=calibrate_camera_fast(V);
        %%Compute 3D Room Estimates
        [room3D] = compute3DRoom(K,R,img,room);
end