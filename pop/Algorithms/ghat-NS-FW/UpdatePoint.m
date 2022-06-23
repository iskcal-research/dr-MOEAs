function Points = UpdatePoint(Points, s, PF, refRand)
    [N, M] = size(Points);
    minPF = min(PF);
    maxPF = max(PF);
    for i = 1 : N
        v = rand(refRand, 1, M) - 0.5;
        v = v ./ norm(v);
        if (all(v>0) && PFDominateRef(Points(i, :), PF)) || (all(v<0) && RefDominatePF(Points(i, :), PF))
            v = -v;
        end
        step = v .* s;
        step = step .* (maxPF - minPF);
        point = Points(i, :) + v .* s ; % .* Points(i, :)
        point = (point < minPF) .* minPF + (1-(point < minPF)) .* point;
        point = (point > maxPF) .* maxPF + (1-(point > maxPF)) .* point;
        Points(i, :) = point;
    end    
end

function dominated = PFDominateRef(point, PopObj)
    dominated = false;
    [N,M] = size(PopObj);
    for j = 1 : N
        m = 1; 
        while m <= M && point(1,m) >= PopObj(j,m)
            m = m + 1;
        end
        dominated = m > M;
        if dominated
           break;
        end
    end
end

function dominated = RefDominatePF(point, PopObj)
    dominated = false;
    [N,M] = size(PopObj);
    for j = 1 : N
        m = 1;
        while m <= M && PopObj(j,m) >= point(1,m)
            m = m + 1;
        end
        dominated = m > M;
        if dominated
           break;
        end
    end
end