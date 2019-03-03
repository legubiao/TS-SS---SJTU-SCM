function [Route_Group, Route_Matrix,Time_Matrix,Customer] = Sector_Scan(List_Size, alpha)
    %扇形扫描分组算法
    %进行数据导入和分组操作
    %输出结果为分组结果和
    
    %List_Size    设定线路组的大小
    %alpha        设定扫描角度
    alphaorg = alpha;


    %------------------------------------------------
    %第一步，导入直角坐标并计算极坐标
    %Node_Cor 为直角坐标
    %Node_TW 为时间窗相关数据
    Cor_Data = xlsread('input_node.xlsx');
    Node_Cor = Cor_Data(:,[3,4]);
    Node_TW = Cor_Data(:,[6,7])*24;                         %时间窗换算为小时制
    Node_Weight = Cor_Data(:,5);

    %直角坐标标准化，配送中心为原点
    for i = 2:size(Node_Cor)
        Node_Cor(i,1) = Node_Cor(i,1) - Node_Cor(1,1);
        Node_Cor(i,2) = Node_Cor(i,2) - Node_Cor(1,2);
    end
    Node_Cor(1,1) = 0;
    Node_Cor(1,2) = 0;

    %计算极坐标
    Node_Pol = zeros(1001,2);
    for i = 2:size(Node_Cor)
        [Node_Pol(i,1),Node_Pol(i,2)] = cart2pol(...
            Node_Cor(i,1),Node_Cor(i,2));
    end


    %------------------------------------------------
    %第二步，导入时间与路程数据并初始化
    fileID = fopen('input_distance-time.txt');
    Route_Data = textscan(fileID, '%f %f %f %f %f', ...
        'Delimiter',',','headerlines',1);
    fclose(fileID);
    Route_Data = cell2mat(Route_Data);                    %cell数组转换普通矩阵
    Route_Matrix = zeros(1001,1001);                      %路线矩阵初始化，1为配送中心
    Time_Matrix = Route_Matrix;                           %时间矩阵初始化，1为配送中心


    %计算路线矩阵和时间矩阵
    for i = 1:size(Route_Data)
        Route_Data(i,2) = Route_Data(i,2)+1;
        Route_Data(i,3) = Route_Data(i,3)+1;
        Route_Matrix(Route_Data(i,2),Route_Data(i,3)) = Route_Data(i,4);
        Time_Matrix(Route_Data(i,2),Route_Data(i,3)) = Route_Data(i,5)/60; %分钟换算为小时
    end


    %------------------------------------------------
    %第三步，扇形搜索并分组
    Not_Visit = (2:1001);                                 %初始化未分配点
    Route_Group = {};

    while size(Not_Visit ~= 1)
        alpha = alphaorg;                                                 %还原初始扫描角度
        Node_List = [];
        Node_Count = 1;                                                 %搜索次数计数
        longest = max(Node_Pol(Not_Visit,2));                 %寻找未分配点中距离原点最远的
        Longest_No = find(Node_Pol(:,2)==longest);        %寻找下标
        Not_Visit(Not_Visit == Longest_No) = [];             %将该点从未分配点中删去
        Node_List(1) =Longest_No;                                  %将该点加入点组
        Search_Center = Node_Cor(Longest_No,:);           %计算搜索中心直角坐标


        while Node_Count < List_Size
            [Search_Angle,x] = cart2pol...
            (Search_Center(1),Search_Center(2));          %计算搜索基准角Search_Angle

            Next_Point = SearchPoint (Search_Center, Not_Visit, ...
            Search_Angle,Node_Cor,Node_Pol, alpha);       %计算下一个点
            
            %计算新的搜索中心
            %依据设定，若下一点为0，则意味找不到下一个合适的点
            %即这个角度范围内的点已经找完了
            
            if Next_Point ~= 1
                Search_Center(1) = mean(Node_Cor(Node_List,1));
                Search_Center(2) = mean(Node_Cor(Node_List,2));
                Not_Visit(Not_Visit == Next_Point) = [];
                Node_Count = Node_Count+1;
                Node_List(end+1) = Next_Point;         
            else
                alpha = alpha + alphaorg/10 ;  %如果点的数目不够，扩大扫描角度
            end

        end
        Route_Group {end+1} = Node_List;
        
    end

    %建立客户结构体
    for i = 1:1001
        Customer(i).Number = i;                         % 客户点编号
        Customer(i).Route = 0;                          % 所属路线，初始化为0
        Customer(i).X = Node_Cor(i,1);                  % X坐标
        Customer(i).Y = Node_Cor(i,2);                  % Y坐标
        Customer(i).Begin = Node_TW(i,1);               % 时间窗开始时间
        Customer(i).End = Node_TW(i,2);                 % 时间窗结束时间
        Customer(i).Demand = Node_Weight(i);            % 该点客户需求量
    end
    Customer(1).Demand = 0;
end