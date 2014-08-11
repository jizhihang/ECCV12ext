

function drawVoxels(Xc_dummy,Yc_dummy,Zc_dummy,new_inds,fignum)


% hold on;
% for i=1:length(inds)
% %     voxel([cam_xs(inds(i)) cam_ys(inds(i)) cam_zs(inds(i))],...
% %        -1* grid_res*[1 1 1],'r',1);
%     voxel([Xc(inds(i)) Yc(inds(i)) Zc(inds(i))],...
%        [1 1 1],'r',1);
% 
% end


% hold on;figure;
% inds = find(obj_cone);
% for i=1:length(inds)
% %     voxel([cam_xs(inds(i)) cam_ys(inds(i)) cam_zs(inds(i))],...
% %         -1*grid_res*[1 1 1],'b',1);
%     voxel([Xc(inds(i)) Yc(inds(i)) Zc(inds(i))],...
%         [1 1 1],'b',1);
% end


figure(fignum);hold on; grid_res=1;
for i=1:length(new_inds)
%     voxel([cam_xs(inds(i)) cam_ys(inds(i)) cam_zs(inds(i))],...
%         -1*grid_res*[1 1 1],'b',1);
    voxel([Xc_dummy(new_inds(i)) Yc_dummy(new_inds(i)) Zc_dummy(new_inds(i))],...
        [1 1 1],'b',1);
end
