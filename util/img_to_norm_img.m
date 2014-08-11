%%Function to convert image coordinates to normalized image coordinates.
function[x1,y1] = img_to_norm_img(x,y,w,h)
    x1 = (2*x-w)/h;
    y1 = 1-2*y/h;
end