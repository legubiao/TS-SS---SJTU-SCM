clc
clear
import matlab.io.*
%主程序
%参数设定
List_Size = 50;                                                       %分组大小
alpha = 0.15;                                                             %扫描初始角度
Iter_Max = 100;                                                    %禁忌表迭代次数
Time_P = 24;                                                         %超时惩罚成本

%扇形扫描
[Route_Group, Route_Matrix,Time_Matrix,Customer] = Sector_Scan(List_Size, alpha);

% %扇形扫描画图
% figure(10);
% for i = 1:length(Route_Group)
%     x=[Customer(Route_Group{i}).X];
%     y=[Customer(Route_Group{i}).Y];
%     scatter(x,y,2)
%     hold on 
%     scatter(0,0)
%     hold off
% end
    
%分别计算各个区域内的最优值
Group_length = length(Route_Group);

Vechile_Data = xlsread('input_vehicle_type');
Driving_Range_Group = Vechile_Data(:,5);
Unit_Cost_Group = Vechile_Data(:,6);
Max_Weight_Cost = Vechile_Data(:,3);
Vehicle_Cost = Vechile_Data(:,7);

Driving_Range = Driving_Range_Group(2);
Unit_Cost = Vechile_Data(2);
Capacity = Max_Weight_Cost(2);

for i = 1:Group_length
    %节约算法得到初始解
    [iniRoute,Customer] = Initialization_Route(Route_Group{i}, Route_Matrix, Time_Matrix,Customer,Vechile_Data(2),Driving_Range_Group(2),Vehicle_Cost(2),Time_P);
    [Ans(i).Ini_DIs_Cost,Ans(i).Ini_SubT_Cost,Ans(i).Ini_Vehi_Cost,Ans(i).Ini_IVECO, Ans(i).Ini_TRUCK,iniRoute] = Calculate_Ans( iniRoute,Unit_Cost_Group,Driving_Range_Group,Max_Weight_Cost,Vehicle_Cost,Time_P);
    Ans(i).Ini_Route = iniRoute;
    
    
    %禁忌搜索算法得到更优解
    [Route_Ans] = Tabu_Search(Iter_Max, iniRoute, Route_Group{i},Customer,Route_Matrix,Time_Matrix, Driving_Range_Group(2),Vechile_Data(2),Max_Weight_Cost(2),Time_P);
 
    %删除路线组中的空路径
    Delete_Route = [];
    for j = 1 : length(Route_Ans)
        if length(Route_Ans(j).V) == 2
            Delete_Route (end+1) = j;
        end
    end
    Route_Ans(Delete_Route) = [];
    
    %将禁忌搜索的结果加入Ans结构体中
    [Ans(i).Final_DIs_Cost, Ans(i).Final_SubT_Cost, Ans(i).Final_Vehi_Cost, Ans(i).Final_IVECO, Ans(i).Final_TRUCK, Route_Ans] =  ...
        Calculate_Ans(Route_Ans,Unit_Cost_Group,Driving_Range_Group,Max_Weight_Cost,Vehicle_Cost,Time_P);
    Ans(i).Final_Route = Route_Ans;

    
    %清空Route下标，避免影响下一组线路
    for j = Route_Group{i}
        Customer(j).Route = 0;
    end
end

%调用画图函数
Pathmap(Ans);

%调用输出结果函数

Result_Output(Ans);

