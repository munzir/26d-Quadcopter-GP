clc; close all;
dataPath = '/home/mouhyemen/desktop/research/safeLearning/data/';

%% Discretize cartesian space
%   [x, y, z]

fprintf('[Position]     ');
tic
i = linspace(-2,2,10);
[X, Y, Z] = meshgrid(i,i,i);
x   = X(:)';
y   = Y(:)';
z   = Z(:)';
col = 'b.';
subplot(2,2,1);
plot3(x,y,z,col); grid on;
title('Positions');
view(30,30); axis([-3 3 -3 3 -3 3]);
toc

%% Discretize eulerian angle space
%   [phi, theta, psi]

fprintf('[Eulerian]     ');
tic
i = linspace(-pi/2,pi/2,10);
[PHI, THETA, PSI] = meshgrid(i,i,i);
phi     = PHI(:)';
theta   = THETA(:)';
psi     = 2*PSI(:)';
col     = 'r.';
subplot(2,2,2);
plot3(phi,theta,psi,col); grid on;
title('Eulerian Angles');
view(30,30); axis([-3 3 -3 3 -3 3]);
toc

%% Discretize velocity space
%   [vx, vy, vz]

fprintf('[Velocity]     ');
tic
i = linspace(-1,1,10);
[VX, VY, VZ] = meshgrid(i,i,i);
vx  = VX(:)';
vy  = VY(:)';
vz  = VZ(:)';
col = 'g.';
subplot(2,2,3);
plot3(vx,vy,vz,col); grid on;
title('Velocities');
view(30,30); axis([-3 3 -3 3 -3 3]);
toc

%% Discretize body-angle space
%   [p, q, r]

fprintf('[Body-rate]    ');
tic
i = linspace(-1,1,10);
[P, Q, R] = meshgrid(i,i,i);
p  = 0.5*P(:)';
q  = 0.5*Q(:)';
r  = 35*R(:)';
col = 'm.';
subplot(2,2,4);
plot3(p,q,r,col); grid on;
title('Body-rate Angles');
view(30,30); axis([-1 1 -1 1 -40 40]);
toc

%% Discretizing POSITION-YAW Space
%   [x, y, z, yaw]
tic
posYawSpace = [];
row = 0;
for i=1:10:length(x)
    for j=1:5:length(psi)
        row = row + 1;
        posYawSpace(row,:) = [x(i); y(i); z(i); psi(j)];
    end
end
save( strcat(dataPath,'posYawSpace'), 'posYawSpace');
toc