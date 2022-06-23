function iRVEA(Global)
    %% Parameter setting
    [ri, s, tao_t, pre, type, pop_type, op_type, alpha,fr] = Global.ParameterSet(2, 0.1, 10, 200, 1, 0, 0, 2,0.1);
    Points = GeneratePoint(ri, Global.PF);
    rr = 0.15;
    rec = [];
    change = false;

    %% Generate the reference points and random population
    [V0,Global.N] = UniformPoint(Global.N,Global.M);
    V0 = V0 ./ vecnorm(V0, 2, 2);
    Population     = Global.Initialization();
    [~,FrontNo1,~] = aEnvironmentalSelection(Population,Global.N,Points,[]);
    V              = V0;
    
    vc = Points ./ vecnorm(Points, 2, 2);
    Vi = rr .* V0 + (1-rr) .* vc;
    V = Vi ./ vecnorm(Vi, 2, 2);
    
    cosineVV = V*V';
    [scosineVV, neighbor] = sort(cosineVV, 2, 'descend');
    acosVV = acos(scosineVV(:,2));
    refV = (acosVV);
    
    refRand = RandStream.create('mrg32k3a','NumStreams',2,'Seed',1); % problem random stream

    %% Optimization
    while Global.NotTermination(Population(FrontNo1==1), Points)
%         disp(Global.evaluated);
        rec = [rec; Global.evaluated];
        if change
            Points = UpdatePoint(Points, s, Global.PF, refRand);
            
            vc = Points ./ vecnorm(Points, 2, 2);
            Vi = rr .* V0 + (1-rr) .* vc;
            V = Vi ./ vecnorm(Vi, 2, 2);
            
            cosineVV = V*V';
            [scosineVV, neighbor] = sort(cosineVV, 2, 'descend');
            acosVV = acos(scosineVV(:,2));
            refV = (acosVV); 
            change = false;
        end
        rest = Global.N;
        
       if (Global.evaluated + Global.N > pre * 100 && Global.evaluated < pre * 100)
           rest = pre * 100 - Global.evaluated;
           change = true;
       end
       
       if (Global.evaluated > pre * 100 && mod(Global.evaluated - pre * 100, tao_t * 100) + Global.N > tao_t * 100)
           rest = tao_t * 100 - mod(Global.evaluated - pre * 100, tao_t * 100);
           change = true;
       end
       
       if rest < Global.N
           trash = INDIVIDUAL(zeros(rest, Global.D));
           continue;
       end
       
        MatingPool = randi(length(Population),1,Global.N);
        Offspring  = Global.Variation(Population(MatingPool));
        %Population = EnvironmentalSelection([Population,Offspring],V,(Global.evaluated/Global.evaluation)^alpha);
        Ins = [Population, Offspring];
        theta0 =  (Global.evaluated/Global.evaluation)^alpha*(Global.M);
        [Selection] = F_select(Ins.objs,V, theta0, refV);
        Population = Ins(Selection);
        if ~mod(ceil(Global.evaluated/Global.N),ceil(fr*Global.evaluation/Global.N))
            V(1:Global.N,:) = ReferenceVectorAdaptation(Population.objs,V0);
            cosineVV = V*V';
            [scosineVV, neighbor] = sort(cosineVV, 2, 'descend');
            acosVV = acos(scosineVV(:,2));
            refV = (acosVV); 
        end
        [~,FrontNo1,~] = aEnvironmentalSelection(Population,length(Population),Points,[]);
    end
end