function project_room_with_walls(room3D, im, K, R, camera_height, varargin)

if length(varargin)==1
    ax = varargin{1};
else
    figure
    ax = gca;
end

axes(ax);

imupdown(:,:,1) = flipud(im(:,:,1));
imupdown(:,:,2) = flipud(im(:,:,2));
imupdown(:,:,3) = flipud(im(:,:,3));
image([-size(im,2)/size(im,1),size(im,2)/size(im,1)], [-1,1], imupdown);
axis 'xy'
axis equal
axis tight; 

hold on

M = K * [R, [0; -camera_height; 0]];

%room3D.discreteBlocks = room3D.discreteBlocks/max(max(max(room3D.discreteBlocks)));
room3D.discreteBlocks = room3D.discreteBlocks>.8;
 room3D.discreteBlocks = bwperim(room3D.discreteBlocks);
[ind1 ind2 ind3] = ind2sub(size(room3D.discreteBlocks), find(room3D.discreteBlocks==1));

sorted_ind = sortrows([ind1 ind2 ind3], [2, -1, -3]);
ind1 = sorted_ind(:,1);
ind2 = sorted_ind(:,2);
ind3 = sorted_ind(:,3);



min_X = room3D.minX;
max_X = room3D.maxX;
min_Y = room3D.minY;
max_Y = room3D.maxY;
min_Z = room3D.minZ;
max_Z = room3D.maxZ;
%min_Z = max(0,min_Z);
%min_X = max(0,min_X);

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


if (room3D.visibilities(1))
    fill(p(1, [1 3 2 4]), p(2, [1 3 2 4]), 'r', 'FaceAlpha', .4);
end
if (room3D.visibilities(2))
    fill(p(1, [1 3 2 4]+4), p(2, [1 3 2 4]+4), 'r', 'FaceAlpha', .4);
end
if (room3D.visibilities(3))
    fill(p(1, [1 4 8 5]), p(2, [1 4 8 5]), 'b', 'FaceAlpha', .4);
end
if (room3D.visibilities(4))
    fill(p(1, [6 7 3 2]), p(2, [6 7 3 2]), 'b', 'FaceAlpha', .4);
end


%fill(p(1, [1 3 7 5]), p(2, [1 3 7 5]), 'k', 'FaceAlpha', .25);



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
      
      fill(p(1,[1 3 2 4]+4), p(2,[1 3 2 4]+4), 'r');

      fill(p(1,[2 3 7 6]), p(2,[2 3 7 6]), 'b');

      fill(p(1,[2 4 8 6]), p(2,[2 4 8 6]), 'g');

      fill(p(1,[1 3 7 5]), p(2,[1 3 7 5]), 'g');
      fill(p(1,[1 4 8 5]), p(2,[1 4 8 5]), 'b');
      fill(p(1,[1 3 2 4]), p(2,[1 3 2 4]), 'r');

end


end