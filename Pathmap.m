function Pathmap(Ans)

%画图函数
%将20个组的路线结果化成4*5的矩阵形式

    for i = 1:length(Ans)
        subplot(4,5,i) 
        Inians = Ans(i);
        scatter(0,0);
        hold on;
       for j = 1:length(Inians.Final_Route)
            x=[Inians.Final_Route(j).V.X];
            y=[Inians.Final_Route(j).V.Y];
            scatter(x,y,2);
            plot(x,y);
       end
       hold off;
    end
end
