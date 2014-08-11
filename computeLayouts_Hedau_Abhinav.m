function[room3D,K,R] = computeLayouts_Hedau(imagename,Allvpdata,imgnum,h,w,img)

%%This function loads box results of hedau et al and uses that to obtain
%%room estimates.
filename=fullfile('../boxes_hedauParty/',[imagename(1:end-4) '_layres.mat']);
load(filename);
vv=lay_scores(:,1);
ii=lay_scores(:,2);
layoutid=ii(1);
for fie=1:5
    Polyg{fie}=[];
    if size(polyg{layoutid,fie})>0
        Polyg{fie}=polyg{layoutid,fie};
    end
end

ShowGTPolyg(img,Polyg,2);

V = zeros(2,3);

%[V(1,1) V(2,1)] = img_to_norm_img(Allvpdata(imgnum).vp(1,1),Allvpdata(imgnum).vp(1,2),Allvpdata(imgnum).dim(2),Allvpdata(imgnum).dim(1));
%[V(1,2) V(2,2)] = img_to_norm_img(Allvpdata(imgnum).vp(2,1),Allvpdata(imgnum).vp(2,2),Allvpdata(imgnum).dim(2),Allvpdata(imgnum).dim(1));
%[V(1,3) V(2,3)] = img_to_norm_img(Allvpdata(imgnum).vp(3,1),Allvpdata(imgnum).vp(3,2),Allvpdata(imgnum).dim(2),Allvpdata(imgnum).dim(1));

[V(1,1) V(2,1)] = img_to_norm_img(Allvpdata(imgnum).vp(1,1),Allvpdata(imgnum).vp(1,2),size(img,2),size(img,1));
[V(1,2) V(2,2)] = img_to_norm_img(Allvpdata(imgnum).vp(2,1),Allvpdata(imgnum).vp(2,2),size(img,2),size(img,1));
[V(1,3) V(2,3)] = img_to_norm_img(Allvpdata(imgnum).vp(3,1),Allvpdata(imgnum).vp(3,2),size(img,2),size(img,1));

[A ind] = max(abs(V(2,:)));
if ind ~= 1
    temp = V(:,ind);
    V(:,ind) = V(:,1);
    V(:,1) = temp;
end

%%Using Vanishing Points Estimate Camera Calibration
[K R]=calibrate_camera_fast(V);

%%%%Either THIS
[room3D1,K,R] = compute3DRoom_V(Polyg,Allvpdata(imgnum).vp,h,w,img,K,R);
[room3D2] = compute3DRoom_V1(Polyg,K,R,img,room3D1.maxY);
room3D = room3D2;

%%%%OR THIS
%[room3D,K,R] = compute3DRoom_V(Polyg,Allvpdata(imgnum).vp,h,w,img,K,R);


end
