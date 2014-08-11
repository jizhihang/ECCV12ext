function[X Z] = computeGroundPts(K,R,p)
        global camera_ht;
        d = camera_ht;
        t = [0; 0*d; 0];
        ttt = [0; d; 0];
        %ground plane
        n = [0;1;0];
        p1 = [p(1); p(2); 1];
        %P1 is on the ground
        P1 = R'*(-d * K^-1* p1 / ((R*n)' * K^-1 * p1)) + t;
        P1 = P1+ttt;
        X = P1(1);
        Z = P1(3);
end