clc
clear
import matlab.io.*
%������
%�����趨
List_Size = 50;                                                       %�����С
alpha = 0.15;                                                             %ɨ���ʼ�Ƕ�
Iter_Max = 100;                                                    %���ɱ��������
Time_P = 24;                                                         %��ʱ�ͷ��ɱ�

%����ɨ��
[Route_Group, Route_Matrix,Time_Matrix,Customer] = Sector_Scan(List_Size, alpha);

% %����ɨ�軭ͼ
% figure(10);
% for i = 1:length(Route_Group)
%     x=[Customer(Route_Group{i}).X];
%     y=[Customer(Route_Group{i}).Y];
%     scatter(x,y,2)
%     hold on 
%     scatter(0,0)
%     hold off
% end
    
%�ֱ������������ڵ�����ֵ
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
    %��Լ�㷨�õ���ʼ��
    [iniRoute,Customer] = Initialization_Route(Route_Group{i}, Route_Matrix, Time_Matrix,Customer,Vechile_Data(2),Driving_Range_Group(2),Vehicle_Cost(2),Time_P);
    [Ans(i).Ini_DIs_Cost,Ans(i).Ini_SubT_Cost,Ans(i).Ini_Vehi_Cost,Ans(i).Ini_IVECO, Ans(i).Ini_TRUCK,iniRoute] = Calculate_Ans( iniRoute,Unit_Cost_Group,Driving_Range_Group,Max_Weight_Cost,Vehicle_Cost,Time_P);
    Ans(i).Ini_Route = iniRoute;
    
    
    %���������㷨�õ����Ž�
    [Route_Ans] = Tabu_Search(Iter_Max, iniRoute, Route_Group{i},Customer,Route_Matrix,Time_Matrix, Driving_Range_Group(2),Vechile_Data(2),Max_Weight_Cost(2),Time_P);
 
    %ɾ��·�����еĿ�·��
    Delete_Route = [];
    for j = 1 : length(Route_Ans)
        if length(Route_Ans(j).V) == 2
            Delete_Route (end+1) = j;
        end
    end
    Route_Ans(Delete_Route) = [];
    
    %�����������Ľ������Ans�ṹ����
    [Ans(i).Final_DIs_Cost, Ans(i).Final_SubT_Cost, Ans(i).Final_Vehi_Cost, Ans(i).Final_IVECO, Ans(i).Final_TRUCK, Route_Ans] =  ...
        Calculate_Ans(Route_Ans,Unit_Cost_Group,Driving_Range_Group,Max_Weight_Cost,Vehicle_Cost,Time_P);
    Ans(i).Final_Route = Route_Ans;

    
    %���Route�±꣬����Ӱ����һ����·
    for j = Route_Group{i}
        Customer(j).Route = 0;
    end
end

%���û�ͼ����
Pathmap(Ans);

%��������������

Result_Output(Ans);

