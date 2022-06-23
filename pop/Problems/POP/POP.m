function varargout = POP(Operation,Global,input)

    global mu;
    global sigma;
    num = Global.ParameterSet(1);
    switch Operation
        case 'init'
            [mu, sigma, D] = getPort(num);
            
            Global.M        = 2;
            Global.D        = D;
            Global.lower    = zeros(1,Global.D);
            Global.upper    = ones(1, Global.D);
            Global.operator = @EAreal;
            
            PopDec    = rand(input,Global.D);
            varargout = {PopDec};
        case 'value'
            PopDec = input;
            PopDec = PopDec ./ sum(PopDec, 2);
            [N,~]  = size(PopDec);
            
            PopObj = zeros(N, 2);
            PopObj(:, 1) = - PopDec * mu;
            for i = 1:N
                PopObj(i, 2) = PopDec(i, :) * sigma * PopDec(i, :)';
            end
            
            PopCon = [];
            
            varargout = {input,PopObj,PopCon};
        case 'PF'
            h = dlmread(sprintf('./Problems/POP/port/portef%d.txt', num));
            h(:, 1) = -h(:, 1);
            varargout = {h};
    end
end