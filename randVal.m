function value = randVal(n, valMin, valMax)
    value = valMin + rand(1, n)*(valMax-valMin);
end