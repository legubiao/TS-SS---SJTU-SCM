function Route = Delete_Customer(Route,P, Route_Matrix, Time_Matrix)
    % 从节点原路径中删去该节点的需求    
    Route.Load = Route.Load - Route.V(P).Demand;
    % 从节点原路径中去除该节点所组成的路径并重组
    Route.Dis = Route.Dis - Route_Matrix(Route.V(P-1).Number, Route.V(P).Number) - ...
        Route_Matrix(Route.V(P).Number, Route.V(P+1).Number) + Route_Matrix(Route.V(P-1).Number, Route.V(P+1).Number);
    % 从节点原路线中删去节点
    Route.V(P) = [];
    
    
    Route.HardT = 0;
    Route.SubT = 0;
    Load_Time = 0.5; 
    
    % 计算路线时间窗相关约束
    % 计算第一个客户点的时间
    % 线路V第一个点和最后一个点为配送中心，从2开始为客户点
    if Route.V(2).Begin-Time_Matrix(Route.V(2).Number,Route.V(1).Number) > Route.V(1).Begin
        TNOW = Route.V(2).Begin;
    else
        TNOW = Time_Matrix(Route.V(2).Number,Route.V(1).Number) + Route.V(1).Begin;
    end

    % 计算从第一个点开始的客户点的时间
    for i = 3:length(Route.V)
        % 计算到下一个点的路程
        TNOW = TNOW + Time_Matrix(Route.V(i-1).Number,Route.V(i).Number)+Load_Time;

        % 检查是否超出当前点的硬时间窗
        if TNOW > Route.V(i).End
            Route.HardT = Route.HardT + TNOW - Route.V(i).End;

        % 检查到下一个点是否需要等待
        % 如果需要等待，则加上等待时间
        elseif TNOW < Route.V(i).Begin
            Route.SubT = Route.SubT + Route.V(i).Begin - TNOW;
            TNOW = Route.V(i).Begin;
        end
    end
    
    if TNOW > Route.V(1).End
        Route.HardT = Route.HardT + TNOW - Route.V(1).End;
    end
end