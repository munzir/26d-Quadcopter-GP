function rhs_B = getRHS(x)
    n = length(x) - 1;
    
    rhs_B = zeros(8*n, 1);
    rhs_B(1:4) = [x(1), 0, 0, 0]';
    rhs_B(end-3:end) = [x(end), 0, 0, 0]';
    
    for i=1:n-1
        rhs_B(8*(i-1)+5: 8*(i-1)+8+4) = [x(i+1), 0, 0, 0, ...
                                           0, 0, 0, x(i+1)]';
%         rhs_B(8*(i-1)+5: 8*(i-1)+8+4)'
    end
end