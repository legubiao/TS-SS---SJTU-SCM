function Result = Calculation(Route, Alpha, Beta,Gamma,Delta,Capacity,Unit_Cost,Driving_Range,Time_P)
    Q = 0;             %装载量
    T = 0;              %软时间窗
    D = 0;             %路程
    Out_D = 0;     %超出路程
    HardT = 0;      %硬时间窗

    for i = 1:length(Route)
        if (length(Route(i).V) > 2) && (Route(i).Load > Capacity)
            Q = Q + Route(i).Load - Capacity;
        end
        T = T + Route(i).SubT;
        D = D + Route(i).Dis;
        HardT = HardT + Route(i).HardT;
        
        if (length(Route(i).V) > 2) && (Route(i).Dis > Driving_Range)
            Out_D = Out_D + Route(i).Dis - Driving_Range;
        end
        
    end
    Result = Delta*Out_D*5760 + D*Unit_Cost/1000 + Alpha*Q*5760 + Beta*T*Time_P + Gamma* HardT* 5760;
end

