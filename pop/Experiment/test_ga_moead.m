function test_ga_moead()
    op_debug = false;
    maxmax = 30;
    max_run = 30;
    base = 0;
    pop_size = 100;
    eNum = 29;
    pre_arr = [ones(1, 5) * 500];
	s = 0.1;
    tao_t_arr = pre_arr;%[ones(1, 4) * 10, ones(1, 6) * 10, ones(1, 9) * 200];
    
    data = [];
    details = [];
    
    for pro = 1:5
        tao_t = tao_t_arr(pro);
        
        pre = pre_arr(pro);
        for ri = 1:3
                
            % refresh the message
            clc;
            disp([pro, ri]);

            if (op_debug)

                populationRand = RandStream.create('mrg32k3a','NumStreams',1,'Seed',18);
                RandStream.setGlobalStream(populationRand);
                reset(populationRand);
                %Global = GLOBAL('-algorithm', @ghataNS, '-problem', problems{pro}, '-operator', @CSAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-ghataNS_parameter', {ri, s, tao_t, pre, 1, 0, 1});
                Global = GLOBAL('-algorithm', @MOEAD, '-problem', @POP, '-operator', @CSAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-MOEAD_parameter', {ri, s, tao_t, pre, 1, 0, 1}, '-POP_parameter', {pro});
                %Global = GLOBAL('-algorithm', @rNSGAII, '-problem', problems{pro}, '-operator', @CSAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-rNSGAII_parameter', {ri, s, tao_t, pre, 1, 0, 1});
                
                Global.Start();

                igd_arr = IGD_TR(Global.result, Global.PF, pre, tao_t);
                igd_arr_each = IGD_TR_each(Global.result, Global.PF);
                igd_rt = mean(igd_arr);
            else
                igd_rt = [];
                igd_arr_each = [];
                for k = 1:ceil(maxmax/max_run)
                    base = (k-1)*max_run;
                    delete(gcp('nocreate'));
                    parpool('local',max_run);
                    spmd(max_run)
        %     labindex = 3;
                        populationRand = RandStream.create('mrg32k3a','NumStreams',1,'Seed',labindex+base);
                        RandStream.setGlobalStream(populationRand);
                        reset(populationRand);
                        Global = GLOBAL('-algorithm', @MOEAD, '-problem', @POP, '-operator', @CSAreal, '-N', pop_size,  '-evaluation', (eNum*tao_t+pre)*pop_size, '-mode', 3, '-MOEAD_parameter', {ri, s, tao_t, pre, 1, 0, 1}, '-POP_parameter', {pro});
                        Global.Start();

                        igd_arr_single = IGD_TR(Global.result, Global.PF, pre, tao_t);
                        igd_arr_each_single = IGD_TR_each(Global.result, Global.PF);
                        igd_rt_single = mean(igd_arr_single);
                    end
                    par_igd_rt = cat(1, igd_rt_single{1:end});
                    igd_rt = [igd_rt; par_igd_rt];  
                    par_igd_arr_each = cat(1, igd_arr_each_single{1:end});
                    igd_arr_each = [igd_arr_each; par_igd_arr_each];
                end
            end

            avg_igd = mean(igd_rt);
            std_igd = std(igd_rt);
            best_igd = min(igd_rt);
            worst_igd = max(igd_rt);

            data = [data; avg_igd std_igd best_igd worst_igd];
            details = [details; igd_rt'];

            dlmwrite('./Data/Result/EX24/moead.csv', data);
            dlmwrite('./Data/Result/EX24/moead_details.csv', details);
            dlmwrite(sprintf('./Data/Result/EX10/P%d-R%d', pro, ri), igd_arr_each);
        end
    end
end