function Population = UpdatePopulation(Population, Memory, Point)
%     immigrant = min(length(Memory), 5);
    N = length(Population);
    
    [FrontNo,~] = ghatNDSort(Memory.objs, length(Memory), Point, []);
    
    memIndi = Memory(FrontNo==1);
    immigrant = length(memIndi);
    
%     PopObjs = Memory.objs;
%     
%     dist = pdist2(PopObjs, Point);
%     
%     [~, rank] = sort(dist);
%     closetIndi = Memory(rank(1:immigrant));
    
    Population = aEnvironmentalSelection(Population,N-immigrant,Point, Memory);
    Population = [memIndi, Population];
end