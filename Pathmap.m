function Pathmap(Ans)

%��ͼ����
%��20�����·�߽������4*5�ľ�����ʽ

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
