% Implementing minimum snap trajectory
clc; clear; close all;

t = [0,1,2,3,4,5,6,7,8,9,10];
x = [0,1,2,4,6,7,7.5,6.5,5,4.5,4.0];

M = getMultipleWaypoints(t);
b = getRHS(x);

coeff = linsolve(M, b);

c = zeros( length(coeff)/8 , 8);

for i=1:length(t)-1
    t1 = linspace(-1.0, 1.0, 101);
    x1 = zeros(1, length(t1));
    
%     fprintf('%i : %i \n', 8*(i-1)+1, 8*(i-1) + 8);
    c(i,:) = coeff(8*(i-1)+1 : 8*(i-1) + 8);
        
    for j=1:length(t1)
        x1(j) = polyval( fliplr(c(i,:)) , t1(j));
    end
    
    fprintf('\n\n');
    
    if i == 1
        xx = x1(1:end-1);
        tx = (t(i) + t(i+1))/2 + t1* (t(i+1) - t(i) )/2;
        tt = tx(1:end-1);
    else
        xx = horzcat(xx, x1(1:end-1));
        tx = (t(i) + t(i+1))/2 + t1* (t(i+1) - t(i) )/2;
        tt = horzcat(tt, tx(1:end-1));
    end
end

% scatter(t,x,'MarkerEdgeColor',[0 .5 .5],...
%               'MarkerFaceColor',[0 .7 .7],...
%               'LineWidth',1.5); 
% grid on; hold on;
% plot(tt, xx);
% xlabel('Time (s)');
% ylabel('x (m)');
% title('Polynomial Trajectory');

% New Color Order
co = get(gca, 'colororder');
temp = co(2,:);
co(2,:) = co(1,:);
co(1,:) = temp;
set(groot, 'defaultAxesColorOrder', co);

subplot(2,2,1);
vx = diff(xx);

plot(tt(1:length(vx)), vx); grid on; hold on;
hold on;
xlabel('Time (s)');
ylabel('$\dot{x}$ (m)','Interpreter','Latex');
title('Velocity Trajectory');

subplot(2,2,2);
ax = diff(vx);
plot(tt(1:length(ax)), ax); grid on;
xlabel('Time (s)');
ylabel('$\ddot{x}$ (m)','Interpreter','Latex');
title('Acceleration Trajectory');


subplot(2,2,3);
jx = diff(ax);
plot(tt(1:length(jx)), jx); grid on;
xlabel('Time (s)');
ylabel('$\dot{}\ddot{x}$ (m)','Interpreter','Latex');
title('Jerk Trajectory');

subplot(2,2,4);
sx = diff(jx);
plot(tt(1:length(sx)), sx); grid on; 
xlabel('Time (s)');
ylabel('$\dot{}\ddot{x}\dot{}$ (m)','Interpreter','Latex');
title('Snap Trajectory');
