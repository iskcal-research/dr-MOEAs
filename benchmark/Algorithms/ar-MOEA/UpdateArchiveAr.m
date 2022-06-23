function Ar = UpdateArchiveAr(Ar, maxAr, Population, Points, W, cur_delta, cur_epsilon)
    N = length(Population);
    m = size(Ar, 1);
    for i = 1:N
%         disp(i);
        if m == 0
            Ar = Population(i);
        else
            if ismember(Population(i).decs, Ar.decs, 'rows') || ismember(Population(i).objs, Ar.objs, 'rows') 
                continue;
            end
            
            %phi = Calphi([Population(i) Ar], Points, W, cur_delta, cur_epsilon);
            tpop = [Population(i) Ar];
            [front, ~, phi] = NarDSort(tpop.objs,1, Points,W,cur_delta, cur_epsilon);

            if front(1) > 1
                continue;
            else
                Ar = tpop(front == 1);
                phi = phi(front == 1);
                assert(length(Ar) == length(phi));
                if length(Ar) > maxAr
                    [~,maxidx] = max(phi);
                    Ar(maxidx) = [];
                end
            end
        end
    end
end