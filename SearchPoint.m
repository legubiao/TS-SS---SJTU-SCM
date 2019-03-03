function [nearest_No] = SearchPoint (Search_Center, ...
    Not_Visit, Search_Angle,Node_Cor,Node_Pol, alpha)

%计算在搜索角内的所有的点
%输入信息：
%未分配点           Not_Visit
%基准角              Search_Angle
%所有点极坐标    Node_Pol
%所有点直角坐标 Node_Cor
%搜索角              alpha

%寻找在搜索角内的点
Selected_Points = [];
for i = Not_Visit
    if abs(Node_Pol(i,1)-Search_Angle) <= alpha
        Selected_Points (end+1)= i ;
    end
end

%计算在搜索角内所有点对搜索中心的欧氏距离
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


