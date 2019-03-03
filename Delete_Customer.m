function Route = Delete_Customer(Route,P, Route_Matrix, Time_Matrix)
    % �ӽڵ�ԭ·����ɾȥ�ýڵ������    
    Route.Load = Route.Load - Route.V(P).Demand;
    % �ӽڵ�ԭ·����ȥ���ýڵ�����ɵ�·��������
    Route.Dis = Route.Dis - Route_Matrix(Route.V(P-1).Number, Route.V(P).Number) - ...
        Route_Matrix(Route.V(P).Number, Route.V(P+1).Number) + Route_Matrix(Route.V(P-1).Number, Route.V(P+1).Number);
    % �ӽڵ�ԭ·����ɾȥ�ڵ�
    Route.V(P) = [];
    
    
    Route.HardT = 0;
    Route.SubT = 0;
    Load_Time = 0.5; 
    
    % ����·��ʱ�䴰���Լ��
    % �����һ���ͻ����ʱ��
    % ��·V��һ��������һ����Ϊ�������ģ���2��ʼΪ�ͻ���
    if Route.V(2).Begin-Time_Matrix(Route.V(2).Number,Route.V(1).Number) > Route.V(1).Begin
        TNOW = Route.V(2).Begin;
    else
        TNOW = Time_Matrix(Route.V(2).Number,Route.V(1).Number) + Route.V(1).Begin;
    end

    % ����ӵ�һ���㿪ʼ�Ŀͻ����ʱ��
    for i = 3:length(Route.V)
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
    
    if TNOW > Route.V(1).End
        Route.HardT = Route.HardT + TNOW - Route.V(1).End;
    end
end