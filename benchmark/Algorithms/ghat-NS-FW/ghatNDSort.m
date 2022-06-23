function [FrontNo,MaxFNo] = ghatNDSort(PopObj,nSort,point, Memory)
% 双重非支配排序
    
    [PopObj,~,Loc] = unique(PopObj,'rows');
    %MemoryObj = Memory.objs;
    % 初始化参数
    [N,~]   = size(PopObj);
    FrontNo = inf(1,N);
    MaxFNo  = 0;
    % 若存在未被分层的个体，进入循环
    while any(FrontNo==inf)
        MaxFNo = MaxFNo + 1;
        % 得到当前层的非支配解
        fIndex = find(FrontNo==inf);
        fFrontNo = NDSort(PopObj(fIndex,:),1);       
        
        % 如果记忆集不为空
        if (MaxFNo == 1 && ~isempty(Memory))  
%             aFrontNo = NDSort([PopObj(fIndex(fFrontNo==1), :), Memory.objs], 1);
%             aFrontNo = aFrontNo(1:sum(fFrontNo==1));
%             fFrontNo(fFrontNo==1) = aFrontNo(fFrontNo==1);
            ndPos = find(fFrontNo == 1);
            for idx = ndPos
%                 testdc = [PopObj(fIndex(idx), :); Memory.objs];
%                 mFrontNo = NDSort(testdc, 1);
                mFrontNo = NDSort([PopObj(fIndex(idx), :); Memory.objs], 1);
                if mFrontNo(1) == inf
                    fFrontNo(idx) = inf;
                end
            end
        end
        
        % 进行p支配排序
        pPopObj = abs(PopObj(fIndex(fFrontNo==1),:) - repmat(point,size(PopObj(fIndex(fFrontNo==1),:),1),1));
        pFrontNo = NDSort(pPopObj,1);
        pFrontNo(pFrontNo==1) = MaxFNo;
        FrontNo(fIndex(fFrontNo==1)) = pFrontNo;
    end
    % 还原之前的顺序
    FrontNo = FrontNo(Loc);
    % 所有个体的目标值相同时，修复种群 todo
    if size(FrontNo,1) ~= 1
        FrontNo = (FrontNo)';
    end
    % 限制被赋予层数的个体数量,输入的nSort不一定为被分层的实际个体数量
    % 需要经过环境选择在筛选一次才能刚好得到数量为nSort的种群
    MaxFNo = 1;
    while sum(FrontNo<=MaxFNo) < min(nSort,length(FrontNo))
        MaxFNo = MaxFNo + 1;
    end
    FrontNo(FrontNo>MaxFNo) = inf;
end

