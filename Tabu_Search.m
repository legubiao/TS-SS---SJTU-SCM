function [Route_Ans] = Tabu_Search(Iter_Max,Route,Route_Group,Customer,Route_Matrix,Time_Matrix,Driving_Range,Unit_Cost,Capacity,Time_P)
    % ����������ȡ�������ӣ�����һ��·����ѡ��һ����뵽��һ��·����
    % �ڸò������γɵ�������ѡȡʹĿ�꺯����С�ķǽ��ɽ�������������ӷ����������Ľ�
    Customer_Number = length(Customer);
    Vehicle_Number = length(Route);
    Tabu = zeros(Customer_Number, Vehicle_Number);
    TabuCreate = zeros(1,Customer_Number);
    Ans = inf;
    
    %Ĭ��ʹ�ô�����·���������е�·�߷���С�����������򽫸�·�߻���С��
    

    Iteration = 0; % ��������Ϊ0
    Tabu_Tenure = 20; % ����ʱ��

    while Iteration < Iter_Max
        Iteration = Iteration+1;
        BestC = 0;
        BestR = 0;
        BestP = 0;
        BestV = inf;

        Alpha = 1;         %װ�������
        Beta = 1;           %��ʱ�䴰���
        Gamma = 1;      %Ӳʱ�䴰���
        Delta = 1;          %·�����
        Sita = 0.5;
        
        Position = 0;

        
        for i = Route_Group
           % if Customer(i).Route ~= 0
                % �ҳ��� i ��������·���е�λ��
                for j = 1:length(Route(Customer(i).Route).V)           
                    if Route(Customer(i).Route).V(j).Number == i
                        Position = j;
                        break
                    end
                end
                
                %��ԭ·����ȥ���ڵ�
                Route(Customer(i).Route) = Delete_Customer( Route(Customer(i).Route),Position, Route_Matrix, Time_Matrix);

                for j = 1:Vehicle_Number
                    % ���ɲ������������Ϊ��ֹʹ���µĳ���
                    if(length(Route(j).V) >= 2 && Tabu(i,j) <= Iteration)
                        for l = 2:length(Route(j).V)
                            if Customer(i).Route ~= j               
                                % ����·���м���ڵ�
                                Route(j) = Insert_Customer( Route(j),l ,Customer(i),Route_Matrix, Time_Matrix );
%                                 Route(j) = Make_Route(Route(j),Customer, Route_Matrix, Time_Matrix);

                                % ����Ŀ�꺯��ֵ
                                TempV = Calculation(Route, Alpha, Beta,Gamma,Delta,Capacity,Unit_Cost,Driving_Range,Time_P);
                                if TempV < BestV
                                    BestV = TempV;
                                    BestC = i;
                                    BestR = j;
                                    BestP = l;
                                end

                                %��ԭ��·��
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

        %��������ѭ������ѡ�Ľ���������µ�����·���滮
        %���¸ı���ĸ�����·�������أ����볤�ȣ�����ʱ�䴰������
 
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


