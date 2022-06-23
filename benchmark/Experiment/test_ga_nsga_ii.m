function test_ga_nsga_ii()
    op_debug = false;
    max_run = 30;
    pop_size = 100;
    problems = {@ZDT1, @ZDT2, @ZDT3, @ZDT4, ...
                @DTLZ1, @DTLZ2, @DTLZ3, @DTLZ4, @DTLZ5, @DTLZ6, ...
                @WFG1, @WFG2, @WFG3, @WFG4, @WFG5, @WFG6, @WFG7, @WFG8, @WFG9};
%     problems = {@ZDT1, @ZDT2, @ZDT3, @DTLZ1, @DTLZ2, @DTLZ3};
    eNum = 29;
    pre_arr = [ones(1, 4) * 200, ones(1, 6) * 200, ones(1, 9) * 500];
    s = 0.1;
    tao_t_arr = pre_arr;%[ones(1, 4) * 10, ones(1, 6) * 10, ones(1, 9) * 200];
    
    data = [];
    details = [];
    
    for pro = 5:length(problems)
        pre = pre_arr(pro);  
        tao_t = tao_t_arr(pro);
        for ri = 1:3

            % refresh the message
            clc;
            disp([pro, ri]);

            if (op_debug)

                populationRand = RandStream.create('mrg32k3a','NumStreams',1,'Seed',labindex);
                RandStream.setGlobalStream(populationRand);
                reset(populationRand);
                Global = GLOBAL('-algorithm', @ghataNS, '-problem', problems{pro}, '-operator', @EAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-ghataNS_parameter', {ri, s, tao_t, pre, 1, 0, 0});
                Global.Start();

                igd_arr = IGD_TR(Global.result, Global.PF, pre, tao_t);
                igd_rt = mean(igd_arr);
                igd_arr_each = IGD_TR_each(Global.result, Global.PF);
            else
                delete(gcp('nocreate'));
                parpool('local',max_run);
                spmd(max_run)
%     labindex = 3;
                    populationRand = RandStream.create('mrg32k3a','NumStreams',1,'Seed',labindex);
                    RandStream.setGlobalStream(populationRand);
                    reset(populationRand);
                    Global = GLOBAL('-algorithm', @ghataNS, '-problem', problems{pro}, '-operator', @EAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-ghataNS_parameter', {ri, s, tao_t, pre, 1, 0, 0});
                    Global.Start();

                    igd_arr = IGD_TR(Global.result, Global.PF, pre, tao_t);
                    igd_rt = mean(igd_arr);
                    igd_arr_each = IGD_TR_each(Global.result, Global.PF);
                end
                igd_rt = cat(1, igd_rt{1:end});        
                igd_arr_each = cat(1, igd_arr_each{1:end});
            end

            avg_igd = mean(igd_rt);
            std_igd = std(igd_rt);
            best_igd = min(igd_rt);
            worst_igd = max(igd_rt);

            data = [data; avg_igd std_igd best_igd worst_igd];
            details = [details; igd_rt'];

            dlmwrite('./Data/Result/EX1/ga_ar.csv', data);
            dlmwrite('./Data/Result/EX1/ga_ar_details.csv', details);
            dlmwrite(sprintf('./Data/Result/EX1/P%d-R%d', pro, ri), igd_arr_each);
        end
    end
end