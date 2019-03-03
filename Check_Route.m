function [Result,Alpha,Beta,Gamma,Delta] = Check_Route(Route,Vehicle_Number,Capacity,Driving_Range, Alpha,Beta,Gamma,Sita,Delta)
    Q = 0;                          %运量超出量
    D = 0;                          %路程超出量
    T = 0;                           %软时间窗超出量
    HardT = 0;                   %硬时间窗超出量
    Result = 0;
    % 0代表通过，1代表不通过

    %检查是否满足运量约束
    for i = 1: Vehicle_Number
        if (length(Route(i).V) > 2) && (Route(i).Load > Capacity)
            Q = Q + Route(i).Load - Capacity;
            Result = 1;
        end
    end
    
    %检查是否满足里程约束
   for i = 1: Vehicle_Number
        if (length(Route(i).V) > 2) && (Route(i).Dis > Driving_Range)
            D = D + Route(i).Dis - Driving_Range;            
            Result = 1;
        end
    end

    %检查是否满足时间窗约束
    for i =1:Vehicle_Number
        T = T + Route(i).SubT;
        if (Route(i).HardT ~= 0) || (Q ~= 0)
            Result = 1;
            HardT = HardT + Route(i).HardT;
        end
    end

    %分别根据约束满足的情况更新Alpha、Beta和Gamma的值
    if (Q == 0) && (Alpha >= 0.001)
        Alpha = Alpha / (1 + Sita);
    elseif (Q ~= 0) && (Alpha <= 2000)
        Alpha = Alpha*(1 + Sita);
    end

    if (T == 0) && (Beta >= 0.001)
        Beta = Beta / (1 + Sita);
    elseif (T ~= 0)&&(Beta <= 2000)
        Beta = Beta * (1 + Sita);
    end
    
    if (HardT == 0) && (Gamma >= 0.001)
        Gamma = Gamma/(1+Gamma);
    elseif (HardT ~=0) && (Gamma <=2000)
        Gamma = Gamma*(1+Sita);
    end
    
    if (D == 0) && (Delta >= 0.001)
        Delta = Delta/(1+Delta);
    elseif (D ~=0) && (Delta <=2000)
        Delta = Delta*(1+Sita);
    end
    
end
