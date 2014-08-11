function mask = getSurfaceMask(surface, K, R, imageSize)
    global camera_ht;
    %sutract off camera height, and then project and normalize
    surface(2,:) = surface(2,:) - camera_ht;
    vertices = K*R*surface;
    vertices(1,:) = vertices(1,:)./vertices(3,:);
    vertices(2,:) = vertices(2,:)./vertices(3,:);
    [img_x, img_y] = norm_img_to_img(vertices(1,:),vertices(2,:),imageSize(2), imageSize(1));
    img_x = [img_x img_x(1)];
    img_y = [img_y img_y(1)];
    img_x = max(min(img_x,imageSize(2)),0);
    img_y = max(min(img_y,imageSize(1)),0);
    %get the mask of the top surface
    mask = poly2mask(img_x,img_y,imageSize(1), imageSize(2));
end