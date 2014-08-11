%%Function to calibrate camera given vanishing point estimates.
function [K R] =  calibrate_camera_fast(V)

%%Check if Vanishing Points lie at infinity
infchk = abs(V(1,:))>100 | abs(V(2,:))>100;

%None
if sum(infchk)==0
    V1 = [V(:,1);1];
    V2 = [V(:,2);1];
    V3 = [V(:,3);1];
    if(V2(1)>V3(1))
        tempV = V2;
        V2 = V3;
        V3 = tempV;
    end
    horizon = lineFromPts(V2(1), V2(2), V3(1), V3(2));
    A = [V1(2)+V2(2) V1(1)+V2(1) -1;V3(2)+V2(2) V3(1)+V2(1) -1;V1(2)+V3(2) V1(1)+V3(1) -1];
    B = [V1(1)*V2(1)+V1(2)*V2(2); V3(1)*V2(1)+V3(2)*V2(2); V1(1)*V3(1)+V1(2)*V3(2)];
    CP = A\B;
    v = CP(1);
    u = CP(2);
    f = abs(sqrt(abs(CP(3))));
    K = [f 0 u; 0 f v; 0 0 1];
    r2 = (K^-1*V1)/norm(K^-1*V1);
    r1 = (K^-1*V2)/norm(K^-1*V2);
    r3 = (K^-1*V3)/norm(K^-1*V3);
    r2 = r2/sign(r2(2));  %make sure it points upward
    R = [r1, r2, r3];
%1 VP at infinity
elseif sum(infchk)==1
    V1 = [V(:,1);1];
    V2 = [V(:,2);1];
    V3 = [V(:,3);1];
    if(V2(1)>V3(1))
        tempV = V2;
        V2 = V3;
        V3 = tempV;
    end
    
    ii = find(infchk==0);
    v1 = V(:,ii(1))';
    v2 = V(:,ii(2))';
    r=((0-v1(:,1)).*(v2(:,1)-v1(:,1))+(0-v1(:,2)).*(v2(:,2)-v1(:,2)))./((v2(:,1)-v1(:,1)).^2+(v2(:,2)-v1(:,2)).^2);
    
    u0= v1(:,1) + r.*(v2(:,1)-v1(:,1));
    v0= v1(:,2) + r.*(v2(:,2)-v1(:,2));
    
    temp=u0.*(v1(:,1)+v2(:,1))+v0.*(v2(:,2)+v1(:,2))-(v1(:,1).*v2(:,1)+v2(:,2).*v1(:,2)+u0.^2+v0.^2);
    if temp>0
        f = (temp).^(0.5);
        K = [f 0 u0; 0 f v0; 0 0 1];
        r2 = (K^-1*V1)/norm(K^-1*V1);
        r1 = (K^-1*V2)/norm(K^-1*V2);
        r3 = (K^-1*V3)/norm(K^-1*V3);
        r2 = r2/sign(r2(2));  %make sure it points upwards       
        R = [r1, r2, r3];
    else
        infchk = abs(V(1,:))>10 | abs(V(2,:))>10;
        vp = V';
        if (infchk(1)~=1)
            u0 = vp(1,1);
            v0 = vp(1,2);
        end
        if (infchk(2)~=1)
            u0 = vp(2,1);
            v0 = vp(2,2);
        end
        if (infchk(3)~=1)
            u0 = vp(3,1);
            v0 = vp(3,2);
        end
        R = eye(3);
        f=2.8;
        K = [f 0 u0; 0 f v0; 0 0 1];
    end
else
    vp = V'; 
    if (infchk(1)~=1)
        u0 = vp(1,1);
        v0 = vp(1,2);
    end
    if (infchk(2)~=1)
        u0 = vp(2,1);
        v0 = vp(2,2);
    end
    if (infchk(3)~=1)
        u0 = vp(3,1);
        v0 = vp(3,2);
    end

    R = eye(3);
    
    f=2.8;
    K = [f 0 u0; 0 f v0; 0 0 1];
end


%just a sanity check
%these values should be 0:
%eq1 = V1'*(K'^-1*K^-1)*V2
%eq2 = V1'*(K'^-1*K^-1)*V3
%eq3 = V2'*(K'^-1*K^-1)*V3


%compute camera rotation:
%first VP is vertical, so we assign that to R2
% r2 = (K^-1*V1)/norm(K^-1*V1);
% r1 = (K^-1*V2)/norm(K^-1*V2);
% r3 = (K^-1*V3)/norm(K^-1*V3);
% r2 = r2/sign(r2(2));  %make sure it points upwards
% 
% R = [r1, r2, r3];
