function MOEAD(Global)
% <multi/many> <real/binary/permutation>
% Multiobjective evolutionary algorithm based on decomposition
% type --- 1 --- The type of aggregation function

%------------------------------- Reference --------------------------------
% Q. Zhang and H. Li, MOEA/D: A multiobjective evolutionary algorithm based
% on decomposition, IEEE Transactions on Evolutionary Computation, 2007,
% 11(6): 712-731.
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
    type = 2;

    %% Generate the weight vectors
    [W,Global.N] = UniformPoint(Global.N,Global.M);
    T = ceil(Global.N/10);

    %% Detect the neighbours of each solution
    B = pdist2(W,W);
    [~,B] = sort(B,2);
    B = B(:,1:T);

    %% Generate random population
    Population = Global.Initialization();
    [~,FrontNo1,~] = aEnvironmentalSelection(Population,Global.N,Points,[]);
    Z = min(Population.objs,[],1);
    
	change = false;
    refRand = RandStream.create('mrg32k3a','NumStreams',2,'Seed',1); % problem random stream

    %% Optimization
    while Global.NotTermination(Population(FrontNo1 == 1), Points)
        if change
            Points = UpdatePoint(Points, s, Global.PF, refRand);
            
            Population = Global.Initialization();
            Z = min(Population.objs,[],1);
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
        
        % For each solution
        for i = 1 : Global.N
            % Choose the parents
            P = B(i,randperm(size(B,2)));

            % Generate an offspring
%             Offspring = OperatorGAhalf(Population(P(1:2)));
            Offspring = Global.Variation(Population(P(1:2)));

            % Update the ideal point
            Z = min(Z,Offspring.obj);

            % Update the neighbours
            switch type
                case 1
                    % PBI approach
                    normW   = sqrt(sum(W(P,:).^2,2));
                    normP   = sqrt(sum((Population(P).objs-repmat(Z,T,1)).^2,2));
                    normO   = sqrt(sum((Offspring.obj-Z).^2,2));
                    CosineP = sum((Population(P).objs-repmat(Z,T,1)).*W(P,:),2)./normW./normP;
                    CosineO = sum(repmat(Offspring.obj-Z,T,1).*W(P,:),2)./normW./normO;
                    g_old   = normP.*CosineP + 5*normP.*sqrt(1-CosineP.^2);
                    g_new   = normO.*CosineO + 5*normO.*sqrt(1-CosineO.^2);
                case 2
                    % Tchebycheff approach
                    g_old = max(abs(Population(P).objs-repmat(Z,T,1)).*W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.obj-Z),T,1).*W(P,:),[],2);
                case 3
                    % Tchebycheff approach with normalization
                    Zmax  = max(Population.objs,[],1);
                    g_old = max(abs(Population(P).objs-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.obj-Z)./(Zmax-Z),T,1).*W(P,:),[],2);
                case 4
                    % Modified Tchebycheff approach
                    g_old = max(abs(Population(P).objs-repmat(Z,T,1))./W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.obj-Z),T,1)./W(P,:),[],2);
            end
            Population(P(g_old>=g_new)) = Offspring;
            [~,FrontNo1,~] = aEnvironmentalSelection(Population,Global.N,Points,[]);
        end
    end
end