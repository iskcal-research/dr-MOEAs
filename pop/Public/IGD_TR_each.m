function igd_arr = IGD_TR_each(result, PF)
    igd_arr = zeros(1, size(result, 1));
    M = size(PF, 2);
    prev_pf = nan(1, M);
    prev_ref = nan(1, M);
    for i = 1:length(igd_arr)
        pop = result{i, 2};
        point = result{i, 3};
        
        if all(point == prev_ref)
            pPF = prev_pf;
        else
            pPF = GetPreferencePF(PF, point);
        end
        prev_pf = pPF;
        prev_ref = point;
        igd_arr(i) = IGD(pop.objs, pPF);
    end
end

function pPF = GetPreferencePF(PF, point)
    pPFObj = abs(PF - point);
    FrontNo = NDSort(pPFObj, 1);
    pPF = PF(FrontNo==1, :);
end