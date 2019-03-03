function  [Route] = Make_Route(Route, Route_Matrix, Time_Matrix)

%构造Route结构体
%其包含内容有
        %Load  线路总装载量
        %SubT  线路总等待时间
        %Dis   线路总长度
        %V     线路中路径点的顺序
        %HardT 线路是否超出硬时间窗
Load = 0;
Dis = 0;
SubT = 0;
HardT = 0;

Route.HardT = 0;
Load_Time = 0.5; 
Route.SubT = 0;


%--------------------------------------------------------------------------
%计算路线长度和路线总运量

for i = 2: length(Route.V)
    Dis = Dis + Route_Matrix(Route.V(i).Number,Route.V(i - 1).Number);
    Load = Load+ Route.V(i).Demand;
end
Route.Dis = Dis;
Route.Load = Load;
%--------------------------------------------------------------------------


% 计算路线时间窗相关约束
% 计算第一个客户点的时间
% 线路V第一个点和最后一个点为配送中心，从2开始为客户点
if Route.V(2).Begin-Time_Matrix(Route.V(2).Number,Route.V(1).Number) > Route.V(1).Begin
    TNOW = Route.V(2).Begin;
else
    TNOW = Time_Matrix(Route.V(2).Number,Route.V(1).Number) + Route.V(1).Begin;
end
% 此处时间点为第一个客户服务完成

% 计算从第一个点开始的客户点的时间
for i = 3:length(Route.V)-1
    % 加上下一个点的路上时间与前一个点的卸货时间
    TNOW = TNOW + Time_Matrix(Route.V(i-1).Number, Route.V(i).Number) + Load_Time;
    
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

%计算返回配送中心的时间
TNOW = TNOW + Time_Matrix(Route.V(end-1).Number, Route.V(1).Number) + Load_Time;
if TNOW > Route.V(1).End
        Route.HardT = Route.HardT + TNOW - Route.V(1).End;
end

end
