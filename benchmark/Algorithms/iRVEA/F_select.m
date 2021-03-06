% The selection function in RVEA
function [Selection] = F_select(FunctionValue, V, theta0, refV)

[N M] = size(FunctionValue);
VN = size(V, 1);

Zmin = min(FunctionValue,[],1);

%Translation
FunctionValue = (FunctionValue - repmat(Zmin, [size(FunctionValue,1) 1]));

%Solutions associattion to reference vectors
clear class;
uFunctionValue = FunctionValue./repmat(sqrt(sum(FunctionValue.^2,2)), [1 M]);
cosine = uFunctionValue*V'; %calculate the cosine values between each solution and each vector
acosine = acos(cosine);
[maxc maxcidx] = max(cosine, [], 2);
class = struct('c', cell(1,VN)); %classification
for i = 1:N
    class(maxcidx(i)).c = [class(maxcidx(i)).c, i];
end

Selection = [];
for k = 1:VN
    if(~isempty(class(k).c))
        sub = class(k).c;
        subFunctionValue = FunctionValue(sub,:);
        
        %APD calculation
        subacosine = acosine(sub, k);
        subacosine = subacosine/refV(k); % angle normalization
        D1 = sqrt(sum(subFunctionValue.^2,2)); % Euclidean distance from solution to the ideal point
        D = D1.*(1 + (theta0)*(subacosine)); % APD
        
        [mind mindidx] = min(D);
        Selection = [Selection; sub(mindidx)];
    end;
end;

end

