function [Route_Ans] = Tabu_Search(Iter_Max,Route,Route_Group,Customer,Route_Matrix,Time_Matrix,Driving_Range,Unit_Cost,Capacity,Time_P)
    % 禁忌搜索采取插入算子，即从一条路径中选择一点插入到另一条路径中
    % 在该操作下形成的邻域中选取使目标函数最小的非禁忌解或者因满足藐视法则而被解禁的解
    Customer_Number = length(Customer);
    Vehicle_Number = length(Route);
    Tabu = zeros(Customer_Number, Vehicle_Number);
    TabuCreate = zeros(1,Customer_Number);
    Ans = inf;
    
    %默认使用大车来跑路，如果结果中的路线符合小车的运量，则将该路线换成小车
    

    Iteration = 0; % 迭代次数为0
    Tabu_Tenure = 20; % 禁忌时长

    while Iteration < Iter_Max
        Iteration = Iteration+1;
        BestC = 0;
        BestR = 0;
        BestP = 0;
        BestV = inf;

        Alpha = 1;         %装载量相关
        Beta = 1;           %软时间窗相关
        Gamma = 1;      %硬时间窗相关
        Delta = 1;          %路程相关
        Sita = 0.5;
        
        Position = 0;

        
        for i = Route_Group
           % if Customer(i).Route ~= 0
                % 找出点 i 在其所属路线中的位置
                for j = 1:length(Route(Customer(i).Route).V)           
                    if Route(Customer(i).Route).V(j).Number == i
                        Position = j;
                        break
                    end
                end
                
                %从原路径中去除节点
                Route(Customer(i).Route) = Delete_Customer( Route(Customer(i).Route),Position, Route_Matrix, Time_Matrix);

                for j = 1:Vehicle_Number
                    % 禁忌插入操作，后者为禁止使用新的车辆
                    if(length(Route(j).V) >= 2 && Tabu(i,j) <= Iteration)
                        for l = 2:length(Route(j).V)
                            if Customer(i).Route ~= j               
                                % 在新路径中加入节点
                                Route(j) = Insert_Customer( Route(j),l ,Customer(i),Route_Matrix, Time_Matrix );
%                                 Route(j) = Make_Route(Route(j),Customer, Route_Matrix, Time_Matrix);

                                % 计算目标函数值
                                TempV = Calculation(Route, Alpha, Beta,Gamma,Delta,Capacity,Unit_Cost,Driving_Range,Time_P);
                                if TempV < BestV
                                    BestV = TempV;
                                    BestC = i;
                                    BestR = j;
                                    BestP = l;
                                end

                                %还原新路径
                                Route(j)= Delete_Customer( Route(j),l, Route_Matrix, Time_Matrix);
                            end
                        end
                    end
                end
                Route(Customer(i).Route)= Insert_Customer(  Route(Customer(i).Route),Position ,Customer(i),Route_Matrix, Time_Matrix );
         end
       % end

        
        if length(Route(BestR).V) == 2
            TabuCreate(BestC) = Iteration + 2*Tabu_Tenure + rand*9;
        end
        Tabu(BestC, Customer(BestC).Route) = Iteration + Tabu_Tenure + rand*9;
        
        for i = 1:length(Route(Customer(BestC).Route).V)
            if Route(Customer(BestC).Route).V(i).Number == BestC
                Position = i;
                break; 
            end
        end

        %依据上述循环中挑选的结果，生成新的总体路径规划
        %更新改变过的各单条路径的载重，距离长度，超出时间窗的总量
 
        Route(Customer(BestC).Route)= Delete_Customer(  Route(Customer(BestC).Route),Position, Route_Matrix, Time_Matrix);
       
        Customer(BestC).Route = BestR;
        Route(BestR) =  Insert_Customer(Route(BestR),BestP, Customer(BestC),Route_Matrix, Time_Matrix);
        
        Vehicle_Number = length(Route);
        [Check_Result,Alpha,Beta,Gamma,Delta] = Check_Route(Route,Vehicle_Number,Capacity,Driving_Range,Alpha,Beta,Gamma,Sita,Delta);
        if (Check_Result == 0) && (Ans > BestV)
            clear Route_Ans;
            Route_Ans = Route;
            Ans = BestV;
        end
    end
end


