function point = GeneratePoint(ri, PF)
    maxPF = max(PF);
    minPF = min(PF);
    point = zeros(1, 2);
    point(1) = round(minPF(1) + (maxPF(1) - minPF(1)) ./ 4 * ri, 4);
    point(2) = round(minPF(2) + (maxPF(2) - minPF(2)) ./ 4 * (4 - ri), 4);
%     point = minPF + (maxPF - minPF) ./ 4 * ri;
end