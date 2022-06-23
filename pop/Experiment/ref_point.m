function ref_point()
	problems = {@ZDT1, @ZDT2, @ZDT3, @ZDT4, ...
                @DTLZ1, @DTLZ2, @DTLZ3, @DTLZ4, @DTLZ5, @DTLZ6, ...
                @WFG1, @WFG2, @WFG3, @WFG4, @WFG5, @WFG6, @WFG7, @WFG8, @WFG9};
    ref = cell(length(problems), 3);
    
    for i = 1:length(problems)
        Global = GLOBAL('-algorithm', @ghataNS, '-problem', problems{i}, '-evaluation', 1, '-mode', 3, '-M', 2);
        Global.Start();
        pf = Global.PF;
        for j = 1:3
            point = GeneratePoint(j, pf);
            ref{i, j} = point;
        end
    end
end