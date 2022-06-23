function igd_arr = IGD_gap(result, PF, first, period)
    idx = [1:28] .* period;
    idx = [first, first + idx];
    record_fit = idx .* 100;
    fit = cat(1, result{:, 1});
    igd_arr = zeros(1, 29);
    for i = 1:length(idx)
%         pop = result{idx(i), 2};
        row = find(cat(1, result{:, 1}) == record_fit(i));
        igds = zeros(1, 2);
        for j = 1:2
           pop = result{row(j), 2};
           point = result{row(j), 3};
           pPF = GetPreferencePF(PF, point);
           igds(j) = IGD(pop.objs, pPF);
        end

        igd_arr(i) = igds(2)-igds(1);
    end
end

function pPF = GetPreferencePF(PF, point)
    pPFObj = abs(PF - point);
    FrontNo = NDSort(pPFObj, 1);
    pPF = PF(FrontNo==1, :);
end