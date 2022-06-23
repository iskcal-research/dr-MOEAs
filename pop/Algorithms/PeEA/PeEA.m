function PeEA(Global)
% <multi/many> <real/binary/permutation>
% Pareto front shape estimation based evolutionary algorithm

%------------------------------- Reference --------------------------------
% L. Li, G. G. Yen, A. Sahoo, L. Chang, and T. Gu, On the estimation of
% pareto front and dimensional similarity in many-objective evolutionary
% algorithm, Information Sciences, 2021, 563: 375-400.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2022 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    [ri, s, tao_t, pre, type, pop_type, op_type] = Global.ParameterSet(2, 0.1, 10, 200, 1, 0, 0);
    Points = GeneratePoint(ri, Global.PF);  
    change = false;

    %% Generate random population
    Population = Global.Initialization();    
    [~,FrontNo1,~] = aEnvironmentalSelection(Population,Global.N,Points,[]);

    refRand = RandStream.create('mrg32k3a','NumStreams',2,'Seed',1);
    
    %% Optimization
    while Global.NotTermination(Population(FrontNo1 == 1), Points)
        if change
            Points = UpdatePoint(Points, s, Global.PF, refRand);
            Population = Global.Initialization();
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
        
        MatingPool = MatingSelection(Population.objs);
        Offspring  = Global.Variation(Population(MatingPool));
        Population = EnvironmentalSelection([Population,Offspring],Global.N); 
        
        [~,FrontNo1,~] = aEnvironmentalSelection(Population,Global.N,Points,[]);
    end
end