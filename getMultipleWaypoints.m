function M = getMultipleWaypoints(timeVector)
    n = length(timeVector) - 1 ;
    M = zeros(8*n);

    for i=1:n
        if i == 1       % first curve
            Pstart = getPolynomialMatrix(-1.0);    % initial condition of first curve
            M( 1:4 , 1:8 ) = Pstart(1:4, :);
            
            Pint = getPolynomialMatrix( 1.0);   % intermediary condition of first curve
            M( 5:11    , 1:8 ) = Pint(1:end-1, :);
            
            % starting condition for second curve pos and derivatives
            M( 6: 11  , 9:16) = -Pstart(2:end-1, :);
            M(12: 12  , 9:16) =  Pstart(1, :);
        elseif i~=(n)            % intermediary curves
            % starting condition for ith curve pos and derivatives
            Pstart = getPolynomialMatrix(1.0);
%             fprintf('%i:%i , %i:%i\n',  8*(i-1) + 5 , ...
%                                         8*(i-1) + 7 + 4, ...
%                                         8*(i-1) + 1, ...
%                                         8*(i-1)+8);
            M( 8*(i-1) + 5 : 8*(i-1) + 11  , 8*(i-1) + 1 : 8*(i-1)+8 )  = Pstart(1:end-1, :);

            % end condition of ith curve pos and derivatives
            Pend = getPolynomialMatrix(-1.0);
            M( 8*(i-1)+ 6 : 8*(i-1)+11  , 8*i + 1: 8*i + 8 ) = -Pend(2:end-1,:);
%             fprintf('%i:%i , %i:%i\n',  8*(i-1)+ 6, ...
%                                         8*(i-1)+11, ...
%                                         8*i + 1, ...
%                                         8*i + 8 );

                                    
            
            M( 8*(i-1) + 12 : 8*(i-1) + 12  , 8*i + 1: 8*i + 8 ) = Pend(1, :);
%             fprintf('%i:%i , %i:%i\n',  8*(i-1) + 12, ...
%                                         8*(i-1) + 12, ...
%                                         8*i + 1, ...
%                                         8*i + 8 );
%             fprintf('\n\n');
        end
        if i == n-1   % final curve
%             i
            Pend = getPolynomialMatrix(1.0);    % end cond for final curve pos and deriv
            M( 8*i+5 : 8*i+8 , 8*i + 1: 8*i+8) = Pend(1:4, :);
%             fprintf('%i:%i , %i:%i\n',  8*i+5, ...
%                                 8*i+8 , ...
%                                 8*i + 1, ...
%                                 8*i+8 );
        end
    end
end