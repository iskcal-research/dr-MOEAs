function arMOEA(Global)
    global maxdist;
    global mindist;
    global maxtheta;
    global mintheta;
    
    maxdist = -inf;
    mindist = inf;
    maxtheta = -inf;
    mintheta = inf;

    %% Parameter setting
    [ri, s, tao_t, pre, type, pop_type, op_type] = Global.ParameterSet(2, 0.1, 10, 200, 1, 0, 0);
    Points = GeneratePoint(ri, Global.PF);
    W = ones(1, Global.M) .* (1/Global.M);
    delta = 0.1;
    cur_epsilon = 0.2 + (0.8-0.2).*exp(-(1-Global.evaluated/Global.evaluation));
    cur_delta = 0.7 - Global.evaluated / Global.evaluation * ( 0.7 - 0.3);

    %% Generate random population
    Population = Global.Initialization();
    
    FrontNo    = NarDSort(Population.objs,inf,Points,W,cur_delta, cur_epsilon);
    CrowdDis   = CrowdingDistance(Population.objs,FrontNo);
    Ar = Population(FrontNo == 1);
    maxAr = 100;
    testPop = Ar;
    [~,FrontNo1,~] = aEnvironmentalSelection(testPop,length(testPop),Points,[]);
    
    refRand = RandStream.create('mrg32k3a','NumStreams',2,'Seed',1); % problem random stream

    %% Optimization
    while Global.NotTermination(testPop(FrontNo1 == 1), Points)
%         disp(Global.evaluated);
%         disp(Global.evaluated);
        if Global.evaluated == pre * Global.N || (Global.evaluated > pre * Global.N && mod(Global.evaluated - pre * Global.N, tao_t * Global.N) == 0)
            Points = UpdatePoint(Points, s, Global.PF, refRand);
                maxdist = -inf;
                mindist = inf;
                maxtheta = -inf;
                mintheta = inf;
            Population = Global.Initialization();
            FrontNo    = NarDSort(Population.objs,inf,Points,W,cur_delta, cur_epsilon);
            CrowdDis   = CrowdingDistance(Population.objs,FrontNo);
            Ar = Population(FrontNo == 1);
        end
        
        MatingPool = TournamentSelection(2,Global.N,FrontNo,-CrowdDis);
        Offspring  = Global.Variation(Population(MatingPool));

        cur_epsilon = 0.2 + (0.8-0.2).*exp(-(1-Global.evaluated/Global.evaluation));
        cur_delta = 0.7 - Global.evaluated / Global.evaluation * ( 0.7 - 0.3);
        [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Global.N,Points,W,cur_delta, cur_epsilon);
        
        Ar = UpdateArchiveAr(Ar, maxAr, Population, Points, W, cur_delta, cur_epsilon);
%         [~,~,Loc] = unique(Ar.decs,'rows');
%         Ar = Ar(Loc);
        testPop = Ar;

        [~,FrontNo1,~] = aEnvironmentalSelection(testPop,length(testPop),Points,[]);
    end
end