%��Լ�㷨�õ���ʼ·��
%return iniRoute����ÿ�д���һ��·��
%����һ�������ڵ�ı������Route_Group��1000����ÿ��������Route_Matrix��ʱ��Time_Matrix����λ��Сʱ���Լ�����Data��3*1001���󣬵�һ������ʱ�䴰���ڶ�����ʱ�䴰�������иõ����������
%��Ҫ���ⲿ��������ȫ�ֱ�����t, c, s

%1001*1001����timeSpend��¼i��jʱ��t_ij,��λСʱ
%1000*2����T��¼ÿ�����硢����ʱ�䴰������0�㣩
%1000*1����Demand��¼i������q_i

%������
%������ΪRoute�ṹ��

function [Route_Struct,Customer] = Initialization_Route(Route_Group, Route_Matrix, Time_Matrix,Customer,Unit_Cost,Driving_Range,Vehicle_Cost,Time_P)
    D = Route_Matrix;
    timeSpend = Time_Matrix;
    Demand = [Customer.Demand];
    T = [Customer.Begin;Customer.End];
    T = T';
    time = (T(:,1)+T(:,2))/2; %����ʱ�䴰�е�
    dotNum = length(Route_Group); %�����ڵ����Ŀ
    dotDeleted = []; %�ѽ���·���ĵ�
    deleteDotNum = 0;
    global t; %��ǰʱ�䣨����һ�������ʱ,�ɳ�ʼ��Ϊ8��
    global c; %��ǰ�ػ�������ʼ����0��
    global s; %��ǰ��ʻ���루��ʼ����0��

    matchTo1 = Inf*ones(dotNum,2); %��һ�д洢ƥ��ȣ��ڶ��д洢��Ӧ����±�
    route = []; %·�����飬��ͬ·������0����

    while(deleteDotNum<dotNum)

    %�ҵ���һ���ϲ���
    matchTo1 = [Inf,1];
    for i=1:dotNum %����Route_Group�е�i�����ƥ���
        if(ismember(Route_Group(i),dotDeleted))
            continue;
        else
            extentOfMatch = 0.75*D(1,Route_Group(i))/max(D(1,:)) + 0.25*(time(Route_Group(i))-8)/max(time-8);
            matchTo1 = [matchTo1;[extentOfMatch,Route_Group(i)]]; 
        end
    end
    [~,bestMatchTo1Row] = min(matchTo1(:,1));
    bestMatchTo1 = matchTo1(bestMatchTo1Row,2); %�õ��������ʱ������ӽ���һ����Ϊ��һ���㣬������������±�
    
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
    %�ҵ���һ����

    nextDot = nextDeleteDot(bestMatchTo1,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P);
    if nextDot==-1
        route(length(route)+1) = 0; %��·������
        continue;
    else
        route(length(route)+1) = nextDot;
        deleteDotNum = deleteDotNum + 1;
        dotDeleted = [dotDeleted,nextDot]; %delete nextDot
    end

    %����·������һ������뵽route��ֱ��infeasibleΪֹ
    while(nextDot~=-1)
        nextDot = nextDeleteDot(nextDot,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P);
        if nextDot~=-1
            route(length(route)+1) = nextDot;
            deleteDotNum = deleteDotNum + 1;
            dotDeleted = [dotDeleted,nextDot]; %delete nextDot
        end
    end
    route(length(route)+1) = 0; %��·������,output route
    end

    [Route_Struct,Customer] = transform(route,Customer,Route_Matrix, Time_Matrix);
    end

    %subfunction��������ǰ��i��ȫ�ֱ���t,c,s,deleteDotNum,dotDeleted,������һ���ϲ���
    %if nextDot = -1, then ��ǰ·���ϲ���ֹ
    function nextDot = nextDeleteDot(i,D,timeSpend,Demand,T,dotDeleted, Route_Group,Driving_Range,Unit_Cost,Vehicle_Cost,Time_P)
    global t;
    global c;
    global s;
    F_saveRow = 1;
    lengthR = length(Route_Group);
    F_save = zeros(lengthR,2); %��һ���ǽ�Լ����ֵ���ڶ����Ƕ�Ӧ�ĵ��±�
    for j=1:lengthR %�����Լ����
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

    % subfuntion, ��route�д��������ת��ΪRoute�ṹ��
    function [Route_Struct,Customer] = transform(route,Customer,Route_Matrix, Time_Matrix)
        j = 1;
        RouteStruct(1).V(1) = Customer(1);
        %����Route_Struct�ṹ���·��V, ������RouteStruct�ṹ����
        for i = 1:length(route)
            if route(i) ~= 0
                Customer(route(i)).Route = j;
                RouteStruct(j).V(end+1) = Customer(route(i));
            else
                RouteStruct(j).V(end+1) = Customer(1);    
                %����Route_Struct�ṹ���·�̡�ʱ��Ȳ���
                Route_Struct(j)= Make_Route(RouteStruct(j),  Route_Matrix, Time_Matrix);
                
                j = j + 1;
                RouteStruct(j).V(1) = Customer(1);
            end
        end
        RouteStruct(end) = [];
    end