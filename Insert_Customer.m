function Route = Insert_Customer(Route,P,Customer,Route_Matrix, Time_Matrix)
    
    % �ڽڵ���·���м��ϸýڵ������
    Route.Load = Route.Load + Customer.Demand;
    % �ڽڵ���·���м��ϸýڵ���������ɵ�·�����Ͽ�ԭ·��
    Route.Dis = Route.Dis - Route_Matrix(Route.V(P-1).Number, Route.V(P).Number) + ...
    Route_Matrix(Route.V(P-1).Number, Customer.Number) + Route_Matrix(Customer.Number, Route.V(P).Number);
    %�ڽڵ���·���в���ڵ�
    Route.V = [Route.V(1:P-1), Customer, Route.V(P:end)];

    Route.HardT = 0;
    Route.SubT = 0;
    Load_Time = 0.5; 
    
    % ����·��ʱ�䴰���Լ��
    % �����һ���ͻ����ʱ��
    % ��·V��һ��������һ����Ϊ�������ģ���2��ʼΪ�ͻ���
    if Route.V(2).Begin-Time_Matrix(Route.V(2).Number,Route.V(1).Number) > Route.V(1).Begin
        TNOW = Route.V(2).Begin;
    else
        TNOW = Time_Matrix(Route.V(2).Number,Route.V(1).Number) + Route.V(1).Begin ;
    end

    % ����ӵ�һ���㿪ʼ�Ŀͻ����ʱ��
    for i = 3:length(Route.V)-1
        % ���㵽��һ�����·��
        TNOW = TNOW + Time_Matrix(Route.V(i-1).Number,Route.V(i).Number)+Load_Time;

        % ����Ƿ񳬳���ǰ���Ӳʱ�䴰
        if TNOW > Route.V(i).End
            Route.HardT = Route.HardT + TNOW - Route.V(i).End;

        % ��鵽��һ�����Ƿ���Ҫ�ȴ�
        % �����Ҫ�ȴ�������ϵȴ�ʱ��
        elseif TNOW < Route.V(i).Begin
            Route.SubT = Route.SubT + Route.V(i).Begin - TNOW;
            TNOW = Route.V(i).Begin;
        end
    end
    TNOW = TNOW + Time_Matrix(Route.V(end-1).Number, Route.V(1).Number) + Load_Time;

    if TNOW > Route.V(1).End
        Route.HardT = Route.HardT + TNOW - Route.V(1).End;
    end
end