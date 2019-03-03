function  [Route] = Make_Route(Route, Route_Matrix, Time_Matrix)

%����Route�ṹ��
%�����������
        %Load  ��·��װ����
        %SubT  ��·�ܵȴ�ʱ��
        %Dis   ��·�ܳ���
        %V     ��·��·�����˳��
        %HardT ��·�Ƿ񳬳�Ӳʱ�䴰
Load = 0;
Dis = 0;
SubT = 0;
HardT = 0;

Route.HardT = 0;
Load_Time = 0.5; 
Route.SubT = 0;


%--------------------------------------------------------------------------
%����·�߳��Ⱥ�·��������

for i = 2: length(Route.V)
    Dis = Dis + Route_Matrix(Route.V(i).Number,Route.V(i - 1).Number);
    Load = Load+ Route.V(i).Demand;
end
Route.Dis = Dis;
Route.Load = Load;
%--------------------------------------------------------------------------


% ����·��ʱ�䴰���Լ��
% �����һ���ͻ����ʱ��
% ��·V��һ��������һ����Ϊ�������ģ���2��ʼΪ�ͻ���
if Route.V(2).Begin-Time_Matrix(Route.V(2).Number,Route.V(1).Number) > Route.V(1).Begin
    TNOW = Route.V(2).Begin;
else
    TNOW = Time_Matrix(Route.V(2).Number,Route.V(1).Number) + Route.V(1).Begin;
end
% �˴�ʱ���Ϊ��һ���ͻ��������

% ����ӵ�һ���㿪ʼ�Ŀͻ����ʱ��
for i = 3:length(Route.V)-1
    % ������һ�����·��ʱ����ǰһ�����ж��ʱ��
    TNOW = TNOW + Time_Matrix(Route.V(i-1).Number, Route.V(i).Number) + Load_Time;
    
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

%���㷵���������ĵ�ʱ��
TNOW = TNOW + Time_Matrix(Route.V(end-1).Number, Route.V(1).Number) + Load_Time;
if TNOW > Route.V(1).End
        Route.HardT = Route.HardT + TNOW - Route.V(1).End;
end

end
