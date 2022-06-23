function [mu, sigma, D] = getPort(num)
    port = dlmread(sprintf('./Problems/POP/port/port%d.txt', num));
    
    D = port(1, 1);
    mu = port(2:D+1, 1);
    s = port(2:D+1, 2);
    
    sigma = zeros(D, D);
    for i = D+2:size(port, 1)
       j = port(i, 1);
       k = port(i, 2);
       sigma(j, k) = s(j) * s(k) * port(i, 3);
       sigma(k, j) = sigma(j, k);
    end            
end