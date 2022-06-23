function point = GeneratePoint(ri, PF)
    maxPF = max(PF);
    minPF = min(PF);
    point = round(minPF + (maxPF - minPF) ./ 4 * ri, 4);
%     point = minPF + (maxPF - minPF) ./ 4 * ri;
end