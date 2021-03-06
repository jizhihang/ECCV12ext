function project_room_with_walls(room3D, im, K, R, camera_height, varargin)

clf

if length(varargin)==1
    fprintf('We are here\n');
    ax = varargin{1};
else
    figure(1);
    ax = gca;
end

axes(ax);

imupdown(:,:,1) = flipud(im(:,:,1));
imupdown(:,:,2) = flipud(im(:,:,2));
imupdown(:,:,3) = flipud(im(:,:,3));
image([-size(im,2)/size(im,1),size(im,2)/size(im,1)], [-1,1], imupdown);
width = size(im,2);
height = size(im,1);
axis 'xy'
axis equal
axis tight; 

hold on

M = K * [R, [0; -camera_height; 0]];

% room3D.discreteBlocks = room3D.discreteBlocks/max(max(max(room3D.discreteBlocks)));
% room3D.discreteBlocks = room3D.discreteBlocks>.5;
% room3D.discreteBlocks = bwperim(room3D.discreteBlocks);
% [ind1 ind2 ind3] = ind2sub(size(room3D.discreteBlocks), find(room3D.discreteBlocks==1));
% sorted_ind = sortrows([ind1 ind2 ind3], [2, -1, -3]);
% ind1 = sorted_ind(:,1);
% ind2 = sorted_ind(:,2);
% ind3 = sorted_ind(:,3);
% min_X = room3D.block_size*(ind1(:)-1)+room3D.minX;
% max_X = room3D.block_size*ind1(:)+room3D.minX;
% min_Y = room3D.block_size*(ind2(:)-1)+room3D.minY;
% max_Y = room3D.block_size*ind2(:)+room3D.minY;
% min_Z = room3D.block_size*(ind3(:)-1)+room3D.minZ;
% max_Z = room3D.block_size*ind3(:)+room3D.minZ;
%     
% center_X = (min_X+max_X)/2;
% center_Y = (min_Y+max_Y)/2;
% center_Z = (min_Z+max_Z)/2;
% 
%     
% P = [center_X'; center_Y'; center_Z'];
%     
% p = M*[P; ones(1,size(P,2))];
% p = p(1:2,:)./repmat(p(3,:), [2,1]);
% 
% distances = P-repmat([0;camera_height;0], 1, length(ind1));
% distances = sqrt(sum(distances.^2));
% [~, sorted_ind] = sort(distances, 'descend');
% ind1 = ind1(sorted_ind);
% ind2 = ind2(sorted_ind);
% ind3 = ind3(sorted_ind);


min_X = room3D.minX;
max_X = room3D.maxX;
min_Y = room3D.minY;
max_Y = room3D.maxY;
min_Z = room3D.minZ;
max_Z = room3D.maxZ;
%min_Z = 6;
%min_Z = max(6,min_Z);
%min_X = max(0.1,min_X);
%min_X = max(2, min_X);

    P1 = [min_X; min_Y; min_Z];
    P3 = [min_X; min_Y; max_Z];
    P2 = [min_X; max_Y; max_Z];
    P4 = [min_X; max_Y; min_Z];
    P5 = [max_X; min_Y; min_Z];
    P7 = [max_X; min_Y; max_Z];
    P6 = [max_X; max_Y; max_Z];
    P8 = [max_X; max_Y; min_Z];
    P = [P1 P2 P3 P4 P5 P6 P7 P8];
    P = P+eps;
    p = M*[P; ones(1,size(P,2))];
%     behind_cam = sign(p(3,:))==-1;
    p(3,:) = abs(p(3,:));
    p = p(1:2,:)./repmat(p(3,:), [2,1]);

    
    inbounds = (p(2,:)>=-1) & (p(2,:)<=1)...
        & (p(1,:)>=-width/height) & (p(1,:) <=width/height);
    
%fill(p(1, [1 3 7 5]), p(2, [1 3 7 5]), 'g', 'edgecolor','none');
%fill(p(1, [2 4 8 6]), p(2, [2 4 8 6]), 'g', 'edgecolor','none');


%fill(p(1, [1 3 7 5]), p(2, [1 3 7 5]), 'g', 'FaceAlpha', .3);
%fill(p(1, [2 4 8 6]), p(2, [2 4 8 6]), 'g', 'FaceAlpha', .3);


if(0)
    %if (room3D.visibilities(1))
    %if (any(~behind_cam([1 3 2 4])))
    if (any(inbounds([1 3 2 4])))
        fill(p(1, [1 3 2 4]), p(2, [1 3 2 4]), 'r', 'FaceAlpha', .3);
       % fill(p(1, [1 3 2 4]), p(2, [1 3 2 4]), 'r', 'edgecolor','none');
    end
    %if (room3D.visibilities(2))
    %if (any(~behind_cam([1 3 2 4]+4)))
    if (any(inbounds([1 3 2 4]+4)))
        fill(p(1, [1 3 2 4]+4), p(2, [1 3 2 4]+4), 'r', 'FaceAlpha', .3);
        %fill(p(1, [1 3 2 4]+4), p(2, [1 3 2 4]+4), 'r', 'edgecolor','none');
    end
    %if (room3D.visibilities(3))
    %if (any(~behind_cam([1 4 8 5])))
    if (any(inbounds([1 4 8 5])))
        fill(p(1, [1 4 8 5]), p(2, [1 4 8 5]), 'b', 'FaceAlpha', .3);
        %fill(p(1, [1 4 8 5]), p(2, [1 4 8 5]), 'b', 'edgecolor','none');
    end
    %if (room3D.visibilities(4))
    %if (any(~behind_cam([6 7 3 2])))
    if (any(inbounds([6 7 3 2])))
        fill(p(1, [6 7 3 2]), p(2, [6 7 3 2]), 'b', 'FaceAlpha', .3);
        %fill(p(1, [6 7 3 2]), p(2, [6 7 3 2]), 'b', 'edgecolor','none');
    end
end

room3D.discreteBlocks = room3D.discreteBlocks>.8;
 room3D.discreteBlocks = bwperim(room3D.discreteBlocks);
[ind1 ind2 ind3] = ind2sub(size(room3D.discreteBlocks), find(room3D.discreteBlocks==1));

sorted_ind = sortrows([ind1 ind2 ind3], [2, -1, -3]);
ind1 = sorted_ind(:,1);
ind2 = sorted_ind(:,2);
ind3 = sorted_ind(:,3);

for i = 1:size(ind1,1)
    min_X = room3D.block_size*(ind1(i)-1)+room3D.minX;
    max_X = room3D.block_size*ind1(i)+room3D.minX;
    min_Y = room3D.block_size*(ind2(i)-1)+room3D.minY;
    max_Y = room3D.block_size*ind2(i)+room3D.minY;
    min_Z = room3D.block_size*(ind3(i)-1)+room3D.minZ;
    max_Z = room3D.block_size*ind3(i)+room3D.minZ;
    
    P1 = [min_X; min_Y; min_Z];
    P3 = [min_X; min_Y; max_Z];
    P2 = [min_X; max_Y; max_Z];
    P4 = [min_X; max_Y; min_Z];
    P5 = [max_X; min_Y; min_Z];
    P7 = [max_X; min_Y; max_Z];
    P6 = [max_X; max_Y; max_Z];
    P8 = [max_X; max_Y; min_Z];
    P = [P1 P2 P3 P4 P5 P6 P7 P8];
    
      p = M*[P; ones(1,size(P,2))];
      p = p(1:2,:)./repmat(p(3,:), [2,1]);
      
      fill(p(1,[1 3 2 4]+4), p(2,[1 3 2 4]+4), 'r', 'EdgeColor','none');

      fill(p(1,[2 3 7 6]), p(2,[2 3 7 6]), 'b', 'EdgeColor','none');

      fill(p(1,[2 4 8 6]), p(2,[2 4 8 6]), 'g', 'EdgeColor','none');

      fill(p(1,[1 3 7 5]), p(2,[1 3 7 5]), 'g', 'EdgeColor','none');
      fill(p(1,[1 4 8 5]), p(2,[1 4 8 5]), 'b', 'EdgeColor','none');
      fill(p(1,[1 3 2 4]), p(2,[1 3 2 4]), 'r', 'EdgeColor','none');

end

hold off;

% for i = 1:size(ind1,1)
%     min_X = room3D.block_size*(ind1(i)-1)+room3D.minX;
%     max_X = room3D.block_size*ind1(i)+room3D.minX;
%     min_Y = room3D.block_size*(ind2(i)-1)+room3D.minY;
%     max_Y = room3D.block_size*ind2(i)+room3D.minY;
%     min_Z = room3D.block_size*(ind3(i)-1)+room3D.minZ;
%     max_Z = room3D.block_size*ind3(i)+room3D.minZ;
%     
%     P1 = [min_X; min_Y; min_Z];
%     P3 = [min_X; min_Y; max_Z];
%     P2 = [min_X; max_Y; max_Z];
%     P4 = [min_X; max_Y; min_Z];
%     P5 = [max_X; min_Y; min_Z];
%     P7 = [max_X; min_Y; max_Z];
%     P6 = [max_X; max_Y; max_Z];
%     P8 = [max_X; max_Y; min_Z];
%     P = [P1 P2 P3 P4 P5 P6 P7 P8];
%     
%       p = M*[P; ones(1,size(P,2))];
%       p = p(1:2,:)./repmat(p(3,:), [2,1]);
%       
%       
%       
%     center_X = (min_X+max_X)/2;
%     center_Y = (min_Y+max_Y)/2;
%     center_Z = (min_Z+max_Z)/2;
%     P = [center_X'; center_Y'; center_Z'];
%       distances = P-[0;camera_height;0];
% 
%      
%       %fill(p(1,[1 3 2 4]+4), p(2,[1 3 2 4]+4), 'r');
%       
%      if( distances(3)<0)
%          fill(p(1,[2 3 7 6]), p(2,[2 3 7 6]), 'b','edgecolor','none');
%      else
%          fill(p(1,[1 4 8 5]), p(2,[1 4 8 5]), 'b','edgecolor','none');
%      end
%       
%       if (distances(1)<0)
%           fill(p(1,[1 3 2 4]+4), p(2,[1 3 2 4]+4), 'r','edgecolor','none');
%       else
%           fill(p(1,[1 3 2 4]), p(2,[1 3 2 4]), 'r','edgecolor','none');
%       end
%       
%       if (distances(2)<0)
%         %top
%         fill(p(1,[2 4 8 6]), p(2,[2 4 8 6]), 'g','edgecolor','none');
%       else
%         %bottom
%         fill(p(1,[1 3 7 5]), p(2,[1 3 7 5]), 'g','edgecolor','none');
%       end
% end


end
