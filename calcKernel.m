function k = calcKernel(hyp, xp, xq)
    len = exp(hyp.cov(1));  % char length
    sf  = exp(hyp.cov(2));  % signal var
    val = (xp-xq)*(xp-xq)'/(len*len);
    k   = sf*sf*exp(-0.5*val);
end