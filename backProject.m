%%Backproject the clutter mask to create 3D voxel maps.
 
function[dB] = backProject(room3D,K,R,objmask,objconf)
    global camera_ht;
    
     [Xc, Yc, Zc] = meshgrid(room3D.minX+0.125:room3D.block_size:room3D.minX + 0.125 + (size(room3D.discreteBlocks,1)-1)*room3D.block_size,room3D.minY+0.125:room3D.block_size:room3D.minY + 0.125 + (size(room3D.discreteBlocks,2)-1)*room3D.block_size,room3D.minZ+0.125:room3D.block_size:room3D.minZ + 0.125 + (size(room3D.discreteBlocks,3)-1)*room3D.block_size);
     Xc = reshape(Xc,[numel(Xc) 1]);
     Yc = reshape(Yc,[numel(Yc) 1]);
     Zc = reshape(Zc,[numel(Zc) 1]);
     Yc = Yc - camera_ht;
   
    [h w] = size(objmask); 
    
    %% Free space estimation
    
    %% 1. Check if the voxel itself is occupied
    temp1 = K * R* [Xc(:)';Yc(:)';Zc(:)'];
    img_x = reshape(temp1(1,:)./temp1(3,:),size(Xc));
    img_y = reshape(temp1(2,:)./temp1(3,:),size(Yc));
    [img_x, img_y] = norm_img_to_img(img_x,img_y,size(objmask,2),size(objmask,1));
    inds = find(img_x(:)>=1 & img_y(:)>=1 & img_x(:)<=w & img_y(:)<=h);
    img_inds = sub2ind(size(objmask),round(img_y(inds)),round(img_x(inds)));
    obj_cone = zeros(size(Xc));
    obj_cone(inds) = objconf(img_inds);
   
    %Take projection on floor plane
    
    %% 2. Check if the projection on the floor is occupied
    Yc_floor = zeros(1,size(Xc,1))-camera_ht;
    temp2 = K * R* [Xc';Yc_floor;Zc'];
    img_x = reshape(temp2(1,:)./temp2(3,:),size(Xc));
    img_y = reshape(temp2(2,:)./temp2(3,:),size(Yc));
    [img_x, img_y] = norm_img_to_img(img_x,img_y,size(objmask,2),size(objmask,1));
    inds = find(img_x(:)>=1 & img_y(:)>=1 & img_x(:)<=w & img_y(:)<=h);
    img_inds = sub2ind(size(objmask),round(img_y(inds)),round(img_x(inds)));
    obj_cone_f = zeros(size(Xc));
    obj_cone_f(inds) = objconf(img_inds);
    
    %%Multiply the two scores
    combined_score = obj_cone.*obj_cone_f/max(obj_cone.*obj_cone_f);
    dB =reshape(combined_score,[size(room3D.discreteBlocks,2) size(room3D.discreteBlocks,1) size(room3D.discreteBlocks,3)]);
    dB = permute(dB,[2 1 3]);
    
end