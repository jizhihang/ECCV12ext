%%Code that checks if center wall's height and width is less than 20% of
%%the image. If that is the case then results of Lee et al. are not
%%reliable and return 0.

function[boxUser] = computeBoxUser(room,img)
    switch room.type
        case {1,3}
            height = abs(room.box(2).p1(2)-room.box(2).p2(2));
        case {2,4}
            height = abs(room.box(2).p1(2)-room.box(2).p2(2));
        case 5
            height = max(abs(room.box(2).p1(2)-room.box(2).p2(2)),abs(room.box(2).p3(2)-room.box(2).p4(2)));
            width  = abs(room.box(2).p2(1)-room.box(2).p4(1));
            if width<0.2*size(img,2)
                boxUser = 0;
                return;
            end
    end
    if height<0.2*size(img,1)
        boxUser = 0;
        return;
    end
    boxUser=1;
end