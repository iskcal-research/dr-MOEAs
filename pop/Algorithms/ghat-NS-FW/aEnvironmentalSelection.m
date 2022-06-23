function [Population,FrontNo,CrowdDis] = aEnvironmentalSelection(Population,N,point,Memory)

    %% Non-dominated sorting
    [FrontNo,MaxFNo] = ghatNDSort(Population.objs, N, point, Memory);
    
    
    %% Calculate the crowding distance of each solution
    Next = FrontNo < MaxFNo;
    CrowdDis = CrowdingDistance(Population.objs,FrontNo);
    
    %% Select the solutions in the last front based on their crowding distances
    Last     = find(FrontNo==MaxFNo);
    [~,Rank] = sort(CrowdDis(Last),'descend');
    Next(Last(Rank(1:N-sum(Next)))) = true;
    
    %% Population for next generation
    Population = Population(Next);
    FrontNo    = FrontNo(Next);
    CrowdDis   = CrowdDis(Next);
end