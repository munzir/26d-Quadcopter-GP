% Trying some trajectory
clc; clear;
close all;
clf;
pause on;
%%
valMax =  0.1;
valMin = -valMax;

a = [randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
    randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
    randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax)];

b = [randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
    randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
    randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax)];

wf      = randVal(1, 0.5, 0.25);
Tperiod = round(2*pi/wf);

number  = 2000;
step    = 0.5;

ref     = zeros( size(a,1) , number );
dref     = zeros( size(a,1) , number );
ddref     = zeros( size(a,1) , number );
colIdx  = 1;

beginT  = 0;
endT    = 1.05*Tperiod;

windowWidth = 100;
kernel  = ones(windowWidth,1) / windowWidth;
time = [];
while colIdx < number
    timeFrame    = beginT: step : endT;
    for i = 1:length(timeFrame)
        if colIdx >= number
            break
        end
        t = timeFrame(i);
        for joint = 1:size(a,1)
            for l = 1:size(a,2)
                ref(joint, colIdx) = ref(joint, colIdx)  + ...
                    (a(joint,l)/(wf*l))*sin(wf*l*t ) -  ...
                    (b(joint,l)/(wf*l))*cos(wf*l*t );
                
                dref(joint, colIdx) = a(joint,l)*cos(wf*l*t) + ...
                    b(joint,l)*sin(wf*l*t);
                
                ddref(joint, colIdx) = -wf*l*a(joint,l)*sin(wf*l*t) + ...
                    wf*l*b(joint,l)*cos(wf*l*t);
            end
        end
        colIdx = colIdx + 1;
    end
            
    x_ref = filter(kernel, 1, ref(1,:));
    y_ref = filter(kernel, 1, ref(2,:));
    z_ref = filter(kernel, 1, ref(3,:));
    
    xd_ref = filter(kernel, 1, dref(1,:));
    yd_ref = filter(kernel, 1, dref(2,:));
    zd_ref = filter(kernel, 1, dref(3,:));
    
    xdd_ref = filter(kernel, 1, ddref(1,:));
    ydd_ref = filter(kernel, 1, ddref(2,:));
    zdd_ref = filter(kernel, 1, ddref(3,:));
    
    
%     plot3(x_ref, y_ref, z_ref); grid on;
%     title('Flight Path','Interpreter','Latex');
%     xlabel('X [meters]','Interpreter','Latex');
%     ylabel('Y [meters]','Interpreter','Latex');
%     zlabel('Z [meters]','Interpreter','Latex');
%     pause(0.001);
%     hold off;
    
    beginT = endT;
    wf = randVal(1, 0.05, 0.015);
    Tperiod = round(2*pi/wf);
    endT = endT + 1.05*Tperiod;
    
    a = [randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
        randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
        randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax)];
    
    b = [randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
        randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax);...
        randVal(1,valMin,valMax) , randVal(1,valMin,valMax) , randVal(1,valMin,valMax)];
    
    %     pause(0.5);
    
end

%% Plotting position, velocity, and acceleration reference trajectories
figure;
subplot(1,3,1); plot3(x_ref, y_ref, z_ref);    grid on;
title('Flight Path - Position','Interpreter','Latex');
xlabel('X [meters]','Interpreter','Latex');
ylabel('Y [meters]','Interpreter','Latex');
zlabel('Z [meters]','Interpreter','Latex');

subplot(1,3,2); plot3(xd_ref, yd_ref, zd_ref); grid on;
title('Flight Path - Velocity','Interpreter','Latex');
xlabel('X [meters]','Interpreter','Latex');
ylabel('Y [meters]','Interpreter','Latex');
zlabel('Z [meters]','Interpreter','Latex');
subplot(1,3,3); plot3(xdd_ref,ydd_ref,zdd_ref); grid on;
title('Flight Path - Acceleration','Interpreter','Latex');
xlabel('X [meters]','Interpreter','Latex');
ylabel('Y [meters]','Interpreter','Latex');
zlabel('Z [meters]','Interpreter','Latex');


%% Comparing drone's heading with reference heading

figure;
psi_ref = atan2(yd_ref, xd_ref);
u = cos(psi_ref);
v = sin(psi_ref);
w = zeros(1,length(psi_ref));

step = 2;
quiver3(x_ref(1:step:end), y_ref(1:step:end), z_ref(1:step:end), ...
    u(1:step:end), v(1:step:end), w(1:step:end), 0.5, 'r');
grid on; hold on;

title('Drone heading','Interpreter','Latex');
xlabel('X [meters]','Interpreter','Latex');
ylabel('Y [meters]','Interpreter','Latex');
zlabel('Z [meters]','Interpreter','Latex');
%         legend('Reference', 'Actual');
limit = 0.5;
axis([  min(x_ref)-limit    max(x_ref)+limit ...
    min(y_ref)-limit    max(y_ref)+limit ...
    min(z_ref)-limit    max(z_ref)+limit   ]);

view(30,30)


%% Save trajectory variables
% EXAMPLE USAGE: save filename variable_name
save xref_trajectory x_ref
save dxref_trajectory xd_ref
save ddxref_trajectory xdd_ref

save yref_trajectory y_ref
save dyref_trajectory yd_ref
save ddyref_trajectory ydd_ref

save zref_trajectory z_ref
save dzref_trajectory zd_ref
save ddzref_trajectory zdd_ref
