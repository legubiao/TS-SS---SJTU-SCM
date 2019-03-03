%节约算法得到初始路径
%return iniRoute矩阵，每行代表一个路径
%输入一个聚类内点的编号数组Route_Group，1000个点每两点间距离Route_Matrix，时间Time_Matrix，单位是小时，以及矩阵Data（3*1001矩阵，第一行是早时间窗，第二行晚时间窗，第三行该点货物重量）
%需要在外部声明三个全局变量：t, c, s

%1001*1001矩阵timeSpend记录i到j时间t_ij,单位小时
%1000*2矩阵T记录每点最早、最晚时间窗（包括0点）
%1000*1矩阵Demand记录i点需求q_i

%彪改造后
%输出结果为Route结构体

function [Route_Struct,Customer] = Initialization_Route(Route_Group, Route_Matrix, Time_Matrix,Customer,Unit_Cost,Driving_Range,Vehicle_Cost,Time_P)
    D = Route_Matrix;
    timeSpend = Time_Matrix;
    Demand = [Customer.Demand];
    T = [Customer.Begin;Customer.End];
    T = T';
    time = (T(:,1)+T(:,2))/2; %早晚时间窗中点
    dotNum = length(Route_Group); %该类内点的数目
    dotDeleted = []; %已进入路径的点
    deleteDotNum = 0;
    global t; %当前时间（从上一个点出发时,可初始化为8）
    global c; %当前载货量（初始化：0）
    global s; %当前行驶距离（初始化：0）

    matchTo1 = Inf*ones(dotNum,2); %第一列存储匹配度，第二列存储对应点的下标
    route = []; %路径数组，不同路径间用0隔开

    while(deleteDotNum<dotNum)

    %找到第一个合并点
    matchTo1 = [Inf,1];
    for i=1:dotNum %计算Route_Group中第i个点的匹配度
        if(ismember(Route_Group(i),dotDeleted))
            continue;
        else
            extentOfMatch = 0.75*D(1,Route_Group(i))/max(D(1,:)) + 0.25*(time(Route_Group(i))-8)/max(time-8);
            matchTo1 = [matchTo1;[extentOfMatch,Route_Group(i)]]; 
        end
    end
    [~,bestMatchTo1Row] = min(matchTo1(:,1));
    bestMatchTo1 = matchTo1(bestMatchTo1Row,2); %得到与起点在时空上最接近的一点作为第一个点，这个变量是其下标
    
    if T(bestMatchTo1,1) <=  8 + timeSpend(1,bestMatchTo1)
        t = 8 + timeSpend(1,bestMatchTo1)+0.5;
    else
        t = T(bestMatchTo1,1) + 0.5;
    end
    
    c = Demand(bestMatchTo1); %initiate c;
    s = D(1,bestMatchTo1); %initiate c;
    deleteDotNum = deleteDotNum + 1;
    dotDeleted(deleteDotNum) = bestMatchTo1; %delete
    route(length(route)+1) = bestMatchTo1;
    %找到第一个点

    nextDot = nextDeleteDot(bestMatchTo1,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P);
    if nextDot==-1
        route(length(route)+1) = 0; %该路径结束
        continue;
    else
        route(length(route)+1) = nextDot;
        deleteDotNum = deleteDotNum + 1;
        dotDeleted = [dotDeleted,nextDot]; %delete nextDot
    end

    %生成路径的下一个点加入到route，直到infeasible为止
    while(nextDot~=-1)
        nextDot = nextDeleteDot(nextDot,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P);
        if nextDot~=-1
            route(length(route)+1) = nextDot;
            deleteDotNum = deleteDotNum + 1;
            dotDeleted = [dotDeleted,nextDot]; %delete nextDot
        end
    end
    route(length(route)+1) = 0; %该路径结束,output route
    end

    [Route_Struct,Customer] = transform(route,Customer,Route_Matrix, Time_Matrix);
    end

    %subfunction，给定当前点i，全局变量t,c,s,deleteDotNum,dotDeleted,计算下一个合并点
    %if nextDot = -1, then 当前路径合并终止
    function nextDot = nextDeleteDot(i,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P)
    global t;
    global c;
    global s;
    F_saveRow = 1;
    lengthR = length(Route_Group);
    F_save = zeros(lengthR,2); %第一列是节约函数值，第二列是对应的点下标
    for j=1:lengthR %计算节约函数
        if(ismember(Route_Group(j),dotDeleted))
            continue;
        else
            if( (T(Route_Group(j),2)>t+timeSpend(i,Route_Group(j)))  && ...
                    (c+Demand(Route_Group(j))<2.5) && ...
                    (s+D(Route_Group(j),1)+D(i,Route_Group(j))<Driving_Range) ) &&...
                   (max(t+timeSpend(i,Route_Group(j)),T(Route_Group(j),1))+0.5+timeSpend(Route_Group(j),1)<24)
               
                if(T(Route_Group(j),1)-t-timeSpend(i,Route_Group(j))<0)
                    F_save(F_saveRow,1) = Vehicle_Cost + (D(1,i)+D(Route_Group(j),1)-D(i,Route_Group(j)))*Unit_Cost;
                    F_save(F_saveRow,2) = Route_Group(j);
                    F_saveRow = F_saveRow+1;
                else
                    F_save(F_saveRow,1) = Vehicle_Cost + (D(1,i)+D(Route_Group(j),1)-D(i,Route_Group(j)))*Unit_Cost- (T(Route_Group(j),1)-t-timeSpend(i,Route_Group(j)))*Time_P;
                    F_save(F_saveRow,2) = Route_Group(j);
                    F_saveRow = F_saveRow+1;
                end
            end
        end
    end

    [maxF_save,F_saveMaxRow]=max(F_save(:,1));
    if(maxF_save<0 || maxF_save==0)
        nextDot = -1;
    else
    F_saveMaxDot = F_save(F_saveMaxRow,2); 
    
    if T(F_saveMaxDot,1) <=  t + timeSpend(i,F_saveMaxDot)
         t = t + timeSpend(i,F_saveMaxDot)+0.5;
    else
        t = T(F_saveMaxDot,1) + 0.5;
    end
    
    c = c + Demand(F_saveMaxDot);
    s = s + D(i,F_saveMaxDot);
    nextDot = F_saveMaxDot;
    end
    end

    % subfuntion, 将route中储存的数据转化为Route结构体
    function [Route_Struct,Customer] = transform(route,Customer,Route_Matrix, Time_Matrix)
        j = 1;
        RouteStruct(1).V(1) = Customer(1);
        %计算Route_Struct结构体的路线V, 储存在RouteStruct结构体中
        for i = 1:length(route)
            if route(i) ~= 0
                Customer(route(i)).Route = j;
                RouteStruct(j).V(end+1) = Customer(route(i));
            else
                RouteStruct(j).V(end+1) = Customer(1);    
                %计算Route_Struct结构体的路程、时间等参数
                Route_Struct(j)= Make_Route(RouteStruct(j),  Route_Matrix, Time_Matrix);
                
                j = j + 1;
                RouteStruct(j).V(1) = Customer(1);
            end
        end
        RouteStruct(end) = [];
    end