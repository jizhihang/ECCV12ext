function[x1,y1] = norm_img_to_img(x,y,w,h)
    x1 = (h*x+w)/2;
    y1 = h*(1-y)/2;
end