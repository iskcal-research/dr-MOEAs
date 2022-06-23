function check()
    % ex1 ttest
    with_a = dlmread('./Data/Result/EX3/csa_ar_details.csv');
    without_a = dlmread('./Data/Result/EX4/csa_none_details.csv');
    
    n = size(with_a, 1);
    result = zeros(n,1);
    for i=1:n
        result(i) = ttest2(with_a(i, :), without_a(i, :));
    end
    dlmwrite('./Data/ex1.csv', result);
    
    % ex2 ttest
    csa = dlmread('./Data/Result/EX3/csa_ar_details.csv');
    ga = dlmread('./Data/Result/EX1/ga_ar_details.csv');
    
    n = size(csa, 1);
    result = zeros(n,1);
    for i=1:n
        result(i) = ttest2(csa(i, :), ga(i, :));
    end
    dlmwrite('./Data/ex2.csv', result);
end