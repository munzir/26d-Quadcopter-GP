% clc; clear; %close all;


for j=1:num_test_samples
    fprintf('Query point %d/%d\n', j, num_test_samples);
%     xq = horzcat(qTest(j,:), dqTest(j,:), ddqTest(j,:));
    xq = horzcat(qTest(j,:), dqTest(j,:) );
    for i=1:num_training_samples
        k(i) = calc_Kernel(hyp2, trainTrajectory(i,:), xq);
    end
    kernelTau(j,:)  = testPhiBeta(j,:) + k*alpha;
    kAlpha(j,:)     = k*alpha;
    kValues(:,j)    = k';
end

%% Evaluate normalized-MSE on predicted torque and torque from testing set
nMSE = compute_nMSE(kernelTau, testTorque);
fprintf('nMSE between predicted torque and actual torque:\n');
disp(nMSE);

nMSEreal = compute_nMSE(testPhiBeta, testTorque);
fprintf('nMSE between rbd torque and actual torque:\n');
disp(nMSEreal);

fprintf('Order of improvement in prediction:\n');
disp((nMSEreal./nMSE))



%% Plotting torques - predicted torque, PhiBeta test torque, actual test torque
rows = 3;   cols = 3;
figure;
for i = 1:7
    subplot(rows, cols, i);
    plot(time_test, kernelTau(:,i),   'b', ...
        time_test,  testPhiBeta(:,i), 'g', ...
        time_test,  testTorque(:,i),  'r');
%     plot(time_test,  kAlpha(:,i),     'c');
    leg1 = legend('$\tau_{pred}$','$\tau_{rbd}$', '$\tau_{robot}$');
%     leg1 = legend('$k*\alpha$');
    ylabel('Torque','Interpreter','latex');
    grid on;

    xlabel('Time (seconds)','Interpreter','latex');
    %     leg1 = legend('$\tau_{kernel}$','$\tau_{gpml}$');
    set(leg1,'Interpreter','latex');
%     [a, MSGID] = lastwarn();
%     warning('off', MSGID);
    title(['Joint ', num2str(i)],'Interpreter','latex');
    
end

