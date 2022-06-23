function phi = Calphi(PopObj, g, w, delta, epsilon)
    global maxdist;
    global mindist;
    global maxtheta;
    global mintheta;
    Dist       = sqrt(((PopObj-repmat(g,size(PopObj,1),1))./repmat(max(PopObj,[],1)-min(PopObj,[],1),size(PopObj,1),1)).^2*(w/sum(w))');
    maxdist = max([maxdist; Dist]);
    mindist = min([mindist; Dist]);
    DistExtent = maxdist - mindist;

    % theta
    theta = zeros(length(Dist), 1);
    for i = 1:length(theta)
        theta(i) = acos(sum(abs(PopObj(i, :)) .* abs(g)) ./ (norm(PopObj(i, :)) .* norm(g)));
    end
    maxtheta = max([maxtheta; theta]);
    mintheta = min([mintheta; theta]);
    thetaExtent = maxtheta - mintheta;


    mm = size(PopObj, 2);
    phi = (epsilon .* theta ./ thetaExtent + (1-epsilon) .* Dist ./ DistExtent) .* (1+1/exp(mm));

end