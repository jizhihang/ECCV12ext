function [Y] = computeNonGroundFast(K,R,p,X,Z) 
global camera_ht;
d = camera_ht;
t = [0; 0*d; 0];
ttt = [0; d; 0];
C = K*R;
A = [p(1) -C(1,2);p(2) -C(2,2);1 -C(3,2)];
B = [C(1,1)*X+C(1,3)*Z;C(2,1)*X+C(2,3)*Z;C(3,1)*X+C(3,3)*Z];
P = A\B;
P5 = [X; P(2); Z];
P5 = P5 + ttt;
Y = P5(2);
end