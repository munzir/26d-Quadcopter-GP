function P = getPolynomialMatrix(t)
    P = [ 1,   t,   t^2,     t^3,      t^4,      t^5,       t^6,         t^7; ...
          0,   1,   2*t,   3*t^2,    4*t^3,    5*t^4,     6*t^5,       7*t^6; ...
          0,   0,     2,     6*t,   12*t^2,   20*t^3,    30*t^4,      42*t^5; ...
          0,   0,     0,       6,     24*t,   60*t^2,   120*t^3,     210*t^4; ...
          0,   0,     0,       0,       24,    120*t,   360*t^2,     840*t^3; ...
          0,   0,     0,       0,        0,      120,     720*t,    2520*t^2; ...
          0,   0,     0,       0,        0,        0,       720,      5040*t; ...
          0,   0,     0,       0,        0,        0,         0,       5040 ] ;
end