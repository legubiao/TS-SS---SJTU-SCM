function [Dis_Cost, SubT_Cost,Vehi_Cost,IVECO_Num,TRUCK_Num,Route] = Calculate_Ans(Route,Unit_Cost_Group,Driving_Range_Group,Max_Weight_Cost,Vehicle_Cost,Time_P)
%计算路线实际成本
%默认路线符合约束
    Dis_Cost = 0;
    SubT_Cost = 0;
    Vehi_Cost = 0;
    IVECO_Num = 0;
    TRUCK_Num = 0;
    

    for i = 1:length(Route)
        if (Route(i).Dis <= Driving_Range_Group(1))&& (Route(i).Load <= Max_Weight_Cost(1))
            Dis_Cost = Dis_Cost + Route(i).Dis*Unit_Cost_Group(1)/1000;
            SubT_Cost = SubT_Cost + Route(i).SubT*Time_P ;
            Vehi_Cost = Vehi_Cost + Vehicle_Cost(1);
            Route(i).Type = 'IVECO';
            IVECO_Num = IVECO_Num + 1 ;
        else
            Dis_Cost = Dis_Cost + Route(i).Dis*Unit_Cost_Group(2)/1000;
            SubT_Cost =  SubT_Cost + Route(i).SubT*Time_P;
            Vehi_Cost = Vehi_Cost + Vehicle_Cost(2);
            Route(i).Type = 'TRUCK';
            TRUCK_Num = TRUCK_Num + 1;
        end
    end
end

