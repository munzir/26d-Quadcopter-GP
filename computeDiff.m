function [ diff, rbd ] = computeDiff(path, inputs, observations)
load(strcat(path, 'droneParams'))

%% Compute rigid-body dynamics acceleration from data
F = getF(inputs);
[R13, R23, R33] = getRotElements(inputs);
ddx_rbd = -F.*R13/m;
ddy_rbd = -F.*R23/m;
ddz_rbd = g-F.*R33/m;

% Retrieve sampled acceleration 
ddx_sample  = observations(:,1);
ddy_sample  = observations(:,2);
ddz_sample  = observations(:,3);

% Compute difference between sampled and rbd data
ddx_diff = ddx_sample - ddx_rbd;
ddy_diff = ddy_sample - ddy_rbd;
ddz_diff = ddz_sample - ddz_rbd;

%% Compute rigid-body dynamics body rates
[Tx, Ty, Tz] = getTauElements(inputs);
[p, q, r] = getBodyRateElements(inputs);

pdot_ = Tx - (Iz-Iy) * q .* r ;
qdot_ = Ty - (Ix-Iz) * p .* r ;
rdot_ = Tz - (Iy-Ix) * q .* p ;

pdot_rbd = pdot_/Ix;
qdot_rbd = qdot_/Iy;
rdot_rbd = rdot_/Iz;

% Retrieive sampled body-rates
pdot_sample = observations(:,4);
qdot_sample = observations(:,5);
rdot_sample = observations(:,6);

% Compute difference between sampled and rbd data
pdot_diff = pdot_sample - pdot_rbd;
qdot_diff = qdot_sample - qdot_rbd;
rdot_diff = rdot_sample - rdot_rbd;

%% Difference & rbd
diff = [ddx_diff, ddy_diff, ddz_diff, pdot_diff, qdot_diff, rdot_diff];
rbd  = [ddx_rbd, ddy_rbd, ddz_rbd, pdot_rbd, qdot_rbd, rdot_rbd];

end

