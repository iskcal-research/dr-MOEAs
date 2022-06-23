function igd_arr = IGD_TR(result, PF, first, period)
    idx = [1:29] .* period;
    idx = [first, first + idx];
    record_fit = idx .* 100;
    fit = cat(1, result{:, 1});
    igd_arr = zeros(1, 30);
    for i = 1:length(idx)
%         pop = result{idx(i), 2};
        pop = result{fit == record_fit(i), 2};
        point = result{fit == record_fit(i), 3};
        
        pPF = GetPreferencePF(PF, point);
        igd_arr(i) = IGD(pop.objs, pPF);
    end
end

function pPF = GetPreferencePF(PF, point)
    pPFObj = abs(PF - point);
    FrontNo = NDSort(pPFObj, 1);
    pPF = PF(FrontNo==1, :);
end