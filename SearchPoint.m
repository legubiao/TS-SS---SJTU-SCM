function [nearest_No] = SearchPoint (Search_Center, ...
    Not_Visit, Search_Angle,Node_Cor,Node_Pol, alpha)

%�������������ڵ����еĵ�
%������Ϣ��
%δ�����           Not_Visit
%��׼��              Search_Angle
%���е㼫����    Node_Pol
%���е�ֱ������ Node_Cor
%������              alpha

%Ѱ�����������ڵĵ�
Selected_Points = [];
for i = Not_Visit
    if abs(Node_Pol(i,1)-Search_Angle) <= alpha
        Selected_Points (end+1)= i ;
    end
end

%�����������������е���������ĵ�ŷ�Ͼ���
if size(Selected_Points) ~= 0
    length_to_center = [];
    x = Search_Center(1);
    y = Search_Center(2);
    for j =Selected_Points
    length_to_center(end+1) = sqrt((x - Node_Cor(j,1))^2+(y - Node_Cor(j,2))^2);
    end
    [nearest, No] = min(length_to_center); 
    nearest_No = Selected_Points(No);
else
    nearest_No = 1;
end
end


