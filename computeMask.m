function[mask] = computeMask(mask,box,K,R)
    global camera_ht;
    face(1).v = [box.mX box.mX box.mX box.mX;box.mY box.MY box.MY box.mY;box.mZ box.mZ box.MZ box.MZ];
    face(2).v = [box.MX box.MX box.MX box.MX;box.mY box.MY box.MY box.mY;box.mZ box.mZ box.MZ box.MZ];
    face(3).v = [box.mX box.MX box.MX box.mX;box.mY box.mY box.mY box.mY;box.mZ box.mZ box.MZ box.MZ];
    face(4).v = [box.mX box.MX box.MX box.mX;box.MY box.MY box.MY box.MY;box.mZ box.mZ box.MZ box.MZ];
    face(5).v = [box.mX box.mX box.MX box.MX;box.mY box.MY box.MY box.mY;box.mZ box.mZ box.mZ box.mZ];
    face(6).v = [box.mX box.mX box.MX box.MX;box.mY box.MY box.MY box.mY;box.MZ box.MZ box.MZ box.MZ];
    for i=1:6  
        B = face(i).v;
        B(2,:) = B(2,:)-camera_ht;
        vertices = K*R*B;
        vertices(1,:) = vertices(1,:)./vertices(3,:);
        vertices(2,:) = vertices(2,:)./vertices(3,:);
        [img_x, img_y] = norm_img_to_img(vertices(1,:),vertices(2,:),size(mask,2),size(mask,1));
        img_x = [img_x img_x(1)];
        img_y = [img_y img_y(1)];
        mask = mask | poly2mask(img_x,img_y,size(mask,1),size(mask,2));
    end
end