function ghataNS(Global)

    %% Parameter setting
    [ri, s, tao_t, pre, type, pop_type, op_type] = Global.ParameterSet(2, 0.1, 10, 200, 1, 0, 0);
    Point = GeneratePoint(ri, Global.PF);
    if op_type == 1
        copy = 1.5;
    else
        copy = 1;
    end    
    
    Memory = [];
    freq = pre * Global.N;
    refRand = RandStream.create('mrg32k3a','NumStreams',2,'Seed',1); % problem random stream

    %% Generate random population
    Population = Global.Initialization();
    %Global.Initialization();
    [Population,FrontNo,CrowdDis] = aEnvironmentalSelection(Population,Global.N,Point,Memory);
    
    %% Optimization
    while Global.NotTermination(Population(FrontNo == 1), Point)
%         disp(Global.evaluated);
        if (type ~= 0)
            Memory = UpdateMemory(Memory, Population);
        end
        if Global.evaluated == pre * Global.N || (Global.evaluated > pre * Global.N && mod(Global.evaluated - pre * Global.N, tao_t * Global.N) == 0)
            % the reference point should be changed
%             if pop_type == 1 
%                 % use the current population to update the reference point
%                 Point = UpdatePoint(Point, s, Population.objs, refRand);
%             else
                % use the true PF to update the reference point
                Point = UpdatePoint(Point, s, Global.PF, refRand);
%             end
                       
            freq = tao_t * Global.N;
            
            % select the strategy of the dynamic response and update the
            % population
            switch(type)
                case 0 % nothing
                    Population = Population;
                case 1 % memory
                    Population = UpdatePopulation(Population, Memory, Point);
            end
                  
            % get the frontNo of the individuals in the population            
            [Population,FrontNo,CrowdDis] = aEnvironmentalSelection(Population,length(Population),Point,Memory);
            
            % data for plot
%             Global.result(end+1, :) = {Global.evaluated,Population(FrontNo == 1),Point};
        end
        
        % check the rest fitness in the current environment
        N = copy*Global.N;
        if Global.evaluated < pre * Global.N && Global.evaluated + copy*Global.N > pre * Global.N
            N = pre * Global.N - Global.evaluated;
        elseif Global.evaluated >= pre * Global.N && rem(Global.evaluated - pre * Global.N, freq) + copy*Global.N > freq
            N = freq - rem(Global.evaluated - pre * Global.N, freq);
        end
        
        if (op_type == 0)
            MatingPool = TournamentSelection(2,N,FrontNo,-CrowdDis);
            Offspring  = Global.Variation(Population(MatingPool));
        else
            [~, idx] = sortrows([FrontNo; -CrowdDis]');
            
            CrowdDis(CrowdDis==inf) = -1;
            CrowdDis(CrowdDis==-1) = 2*max(CrowdDis);
            s_idx = zeros(N, 1);
            i = 1;
            j = 1;
            while i <= N && j <= Global.N
                cur = idx(j);
                copy_num = ceil(N * CrowdDis(cur)/sum(CrowdDis));
                s_idx(i:min(i+copy_num-1, N)) = cur;
                j = j + 1;
                i = i+copy_num;
            end
            
            m_idx = randi(Global.N-1, N, 1);
            m_idx(m_idx>=s_idx) = m_idx(m_idx>=s_idx) + 1;
            MatingPool = [s_idx; m_idx];
            Offspring  = Global.Variation(Population(MatingPool));
            
%             immi_n = min(max(0, N), cc1*Global.N);
%             Immi = [];
%             
%             if immi_n > 0
%                 immi_decs = rand(immi_n, Global.D) .* repmat((Global.upper - Global.lower), immi_n, 1) + repmat(Global.lower, immi_n, 1);
%                 Immi = INDIVIDUAL(immi_decs);
%             end
%             
%             Population = [Population Immi];
%             [Population,FrontNo,CrowdDis] = aEnvironmentalSelection(Population,length(Population),Point,Memory);
%             
%             off1_n = min(max(0, N-immi_n), cc2*Global.N);
%             MatingPool1 = TournamentSelection(2,off1_n,FrontNo,-CrowdDis);
%             Offspring1  = Global.Variation(Population(MatingPool1));
%             
%             nd_decs = [];
%             i = 0;
%             while size(nd_decs, 1) <= 20
%                 i = i + 1;
%                 nd_decs = Population(FrontNo<=i).decs;
%             end
%             
%             ndnum = size(nd_decs, 1);
%             off2_n = min(max(0, N-immi_n-off1_n), cc3*Global.N);
%             Offspring2 = [];
%             if (off2_n > 0)
%                 nd_index = zeros(off2_n, 3);
%                 for i = 1:off2_n
%                     nd_index(i, :) = randperm(ndnum-1, 3);
%                     nd_index(i, nd_index(i, :) >= i) = nd_index(i, nd_index(i, :) >= i) + 1;
%                 end
%                 decs2 = nd_decs(nd_index(:, 1), :) - repmat(rand(off2_n, 1), 1, Global.D) .* (nd_decs(nd_index(:, 2), :) - nd_decs(nd_index(:, 3), :));
%                 Offspring2 = INDIVIDUAL(decs2);
%             end
%             
%             Offspring = [Offspring1 Offspring2];
        end
        [Population,FrontNo,CrowdDis] = aEnvironmentalSelection([Population,Offspring],Global.N,Point, Memory);
    end
end