% Implementing minimum snap trajectory
clc; clear;
% close all;

mode = 4;
number = 0;
values = 150;
type = 2;

while type ~= 0 && type ~= 1
    type = input('Collect trajectory type. Training: 0   |   Testing: 1  =  ');

    if type == 0
        typeName = 'train';
    elseif type == 1
        typeName = 'test';
    end
end

while mode ~= 2
    clf;
    
    maxValue = 10;
    rows = 3;
    cols = 10;
    
    t = linspace(0, 20, cols);
    
    %% Position reference trajectory
    extra = 2;
    pos_ref = 2*rand(rows, cols+extra);
    ref     = pos_ref(:,1:end-extra);
    
    %% Solve system of equations
    M = getMultipleWaypoints(t);
    
    b_x = getRHS(ref(1,:));
    b_y = getRHS(ref(2,:));
    b_z = getRHS(ref(3,:));
    
    coeff_x = linsolve(M, b_x);
    coeff_y = linsolve(M, b_y);
    coeff_z = linsolve(M, b_z);
    
    c_x = zeros( length(coeff_x)/8 , 8);
    c_y = zeros( length(coeff_y)/8 , 8);
    c_z = zeros( length(coeff_z)/8 , 8);
    
    %% Compute trajectories
    t1 = linspace(-1.0, 1.0, round(values/8) );
    for i=1:length(t)-1
        
        x1 = zeros(1, length(t1));
        y1 = zeros(1, length(t1));
        z1 = zeros(1, length(t1));
        
        %     fprintf('%i : %i \n', 8*(i-1)+1, 8*(i-1) + 8);
        c_x(i,:) = coeff_x(8*(i-1)+1 : 8*(i-1) + 8);
        c_y(i,:) = coeff_y(8*(i-1)+1 : 8*(i-1) + 8);
        c_z(i,:) = coeff_z(8*(i-1)+1 : 8*(i-1) + 8);
        
        for j=1:length(t1)
            x1(j) = polyval( fliplr(c_x(i,:)) , t1(j));
            y1(j) = polyval( fliplr(c_y(i,:)) , t1(j));
            z1(j) = polyval( fliplr(c_z(i,:)) , t1(j));
        end
        
        %     fprintf('\n\n');
        
        if i == 1
            xx = x1(1:end-1);
            yy = y1(1:end-1);
            zz = z1(1:end-1);
            
            tx = (t(i) + t(i+1))/2 + t1* (t(i+1) - t(i) )/2;
            tt = tx(1:end-1);
        else
            xx = horzcat(xx, x1(1:end-1));
            yy = horzcat(yy, y1(1:end-1));
            zz = horzcat(zz, z1(1:end-1));
            
            tx = (t(i) + t(i+1))/2 + t1* (t(i+1) - t(i) )/2;
            tt = horzcat(tt, tx(1:end-1));
        end
    end
    
    %% Compute velocity and acceleration trajectories
    vx      = diff(xx);
    vy      = diff(yy);
    vz      = diff(zz);
    
    ax      = diff(vx);
    ay      = diff(vy);
    az      = diff(vz);
    
    x_ref   = xx(1:values);
    y_ref   = yy(1:values);
    z_ref   = zz(1:values);
    
    xd_ref  = vx(1:values);
    yd_ref  = vy(1:values);
    zd_ref  = vz(1:values);
    
    xdd_ref = ax(1:values);
    ydd_ref = ay(1:values);
    zdd_ref = az(1:values);
    
    %% Plotting waypoints and trajectory curves for position only
    plot3(xx, yy, zz, '--');
    grid on; hold on;
    scatter3(ref(1,:), ref(2,:), ref(3,:), 'MarkerEdgeColor',[1 .5 .5],...
        'MarkerFaceColor',[1 .7 .7],...
        'LineWidth',1.5);
    
    for i=1:length(ref)
        text(ref(1,i)+0.1, ref(2,i)-0.15, ref(3,i)-0.1, num2str(i));
    end
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    title('Polynomial Trajectory');
    view(30, 30);
    
    
    mode = input(strcat('[', typeName, '] Save: 0    | Skip: 1   | Exit: 2 = ') );
    
    if mode == 0
        number = number + 1;
        %% Save trajectory information
        dataPath = '/home/mouhyemen/desktop/research/safeLearning/data/';
        fieldName = strcat('trajectory_', num2str(number));
        
        reference = [ x_ref'   y_ref'   z_ref' ...
                      xd_ref'  yd_ref'  zd_ref' ...
                     xdd_ref' ydd_ref' zdd_ref']';
        trajectory.(fieldName) = reference;
        
        filename = strcat(dataPath, typeName, 'Trajectory');
        save(filename, '-struct', 'trajectory');
        fprintf('Total datapoints: %d\n', number*values);
    elseif mode == 1
        continue;
    elseif mode == 2
        return
    end
    
end