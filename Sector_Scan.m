function [Route_Group, Route_Matrix,Time_Matrix,Customer] = Sector_Scan(List_Size, alpha)
    %����ɨ������㷨
    %�������ݵ���ͷ������
    %������Ϊ��������
    
    %List_Size    �趨��·��Ĵ�С
    %alpha        �趨ɨ��Ƕ�
    alphaorg = alpha;


    %------------------------------------------------
    %��һ��������ֱ�����겢���㼫����
    %Node_Cor Ϊֱ������
    %Node_TW Ϊʱ�䴰�������
    Cor_Data = xlsread('input_node.xlsx');
    Node_Cor = Cor_Data(:,[3,4]);
    Node_TW = Cor_Data(:,[6,7])*24;                         %ʱ�䴰����ΪСʱ��
    Node_Weight = Cor_Data(:,5);

    %ֱ�������׼������������Ϊԭ��
    for i = 2:size(Node_Cor)
        Node_Cor(i,1) = Node_Cor(i,1) - Node_Cor(1,1);
        Node_Cor(i,2) = Node_Cor(i,2) - Node_Cor(1,2);
    end
    Node_Cor(1,1) = 0;
    Node_Cor(1,2) = 0;

    %���㼫����
    Node_Pol = zeros(1001,2);
    for i = 2:size(Node_Cor)
        [Node_Pol(i,1),Node_Pol(i,2)] = cart2pol(...
            Node_Cor(i,1),Node_Cor(i,2));
    end


    %------------------------------------------------
    %�ڶ���������ʱ����·�����ݲ���ʼ��
    fileID = fopen('input_distance-time.txt');
    Route_Data = textscan(fileID, '%f %f %f %f %f', ...
        'Delimiter',',','headerlines',1);
    fclose(fileID);
    Route_Data = cell2mat(Route_Data);                    %cell����ת����ͨ����
    Route_Matrix = zeros(1001,1001);                      %·�߾����ʼ����1Ϊ��������
    Time_Matrix = Route_Matrix;                           %ʱ������ʼ����1Ϊ��������


    %����·�߾����ʱ�����
    for i = 1:size(Route_Data)
        Route_Data(i,2) = Route_Data(i,2)+1;
        Route_Data(i,3) = Route_Data(i,3)+1;
        Route_Matrix(Route_Data(i,2),Route_Data(i,3)) = Route_Data(i,4);
        Time_Matrix(Route_Data(i,2),Route_Data(i,3)) = Route_Data(i,5)/60; %���ӻ���ΪСʱ
    end


    %------------------------------------------------
    %����������������������
    Not_Visit = (2:1001);                                 %��ʼ��δ�����
    Route_Group = {};

    while size(Not_Visit ~= 1)
        alpha = alphaorg;                                                 %��ԭ��ʼɨ��Ƕ�
        Node_List = [];
        Node_Count = 1;                                                 %������������
        longest = max(Node_Pol(Not_Visit,2));                 %Ѱ��δ������о���ԭ����Զ��
        Longest_No = find(Node_Pol(:,2)==longest);        %Ѱ���±�
        Not_Visit(Not_Visit == Longest_No) = [];             %���õ��δ�������ɾȥ
        Node_List(1) =Longest_No;                                  %���õ�������
        Search_Center = Node_Cor(Longest_No,:);           %������������ֱ������


        while Node_Count < List_Size
            [Search_Angle,x] = cart2pol...
            (Search_Center(1),Search_Center(2));          %����������׼��Search_Angle

            Next_Point = SearchPoint (Search_Center, Not_Visit, ...
            Search_Angle,Node_Cor,Node_Pol, alpha);       %������һ����
            
            %�����µ���������
            %�����趨������һ��Ϊ0������ζ�Ҳ�����һ�����ʵĵ�
            %������Ƕȷ�Χ�ڵĵ��Ѿ�������
            
            if Next_Point ~= 1
                Search_Center(1) = mean(Node_Cor(Node_List,1));
                Search_Center(2) = mean(Node_Cor(Node_List,2));
                Not_Visit(Not_Visit == Next_Point) = [];
                Node_Count = Node_Count+1;
                Node_List(end+1) = Next_Point;         
            else
                alpha = alpha + alphaorg/10 ;  %��������Ŀ����������ɨ��Ƕ�
            end

        end
        Route_Group {end+1} = Node_List;
        
    end

    %�����ͻ��ṹ��
    for i = 1:1001
        Customer(i).Number = i;                         % �ͻ�����
        Customer(i).Route = 0;                          % ����·�ߣ���ʼ��Ϊ0
        Customer(i).X = Node_Cor(i,1);                  % X����
        Customer(i).Y = Node_Cor(i,2);                  % Y����
        Customer(i).Begin = Node_TW(i,1);               % ʱ�䴰��ʼʱ��
        Customer(i).End = Node_TW(i,2);                 % ʱ�䴰����ʱ��
        Customer(i).Demand = Node_Weight(i);            % �õ�ͻ�������
    end
    Customer(1).Demand = 0;
end