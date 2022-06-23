function [FrontNo,MaxFNo] = ghatNDSort(PopObj,nSort,point, Memory)
% ˫�ط�֧������
    
    [PopObj,~,Loc] = unique(PopObj,'rows');
    %MemoryObj = Memory.objs;
    % ��ʼ������
    [N,~]   = size(PopObj);
    FrontNo = inf(1,N);
    MaxFNo  = 0;
    % ������δ���ֲ�ĸ��壬����ѭ��
    while any(FrontNo==inf)
        MaxFNo = MaxFNo + 1;
        % �õ���ǰ��ķ�֧���
        fIndex = find(FrontNo==inf);
        fFrontNo = NDSort(PopObj(fIndex,:),1);       
        
        % ������伯��Ϊ��
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
        
        % ����p֧������
        pPopObj = abs(PopObj(fIndex(fFrontNo==1),:) - repmat(point,size(PopObj(fIndex(fFrontNo==1),:),1),1));
        pFrontNo = NDSort(pPopObj,1);
        pFrontNo(pFrontNo==1) = MaxFNo;
        FrontNo(fIndex(fFrontNo==1)) = pFrontNo;
    end
    % ��ԭ֮ǰ��˳��
    FrontNo = FrontNo(Loc);
    % ���и����Ŀ��ֵ��ͬʱ���޸���Ⱥ todo
    if size(FrontNo,1) ~= 1
        FrontNo = (FrontNo)';
    end
    % ���Ʊ���������ĸ�������,�����nSort��һ��Ϊ���ֲ��ʵ�ʸ�������
    % ��Ҫ��������ѡ����ɸѡһ�β��ܸպõõ�����ΪnSort����Ⱥ
    MaxFNo = 1;
    while sum(FrontNo<=MaxFNo) < min(nSort,length(FrontNo))
        MaxFNo = MaxFNo + 1;
    end
    FrontNo(FrontNo>MaxFNo) = inf;
end

