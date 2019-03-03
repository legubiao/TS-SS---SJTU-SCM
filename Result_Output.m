function Result_Output(Ans)
    filename = 'Sector_Scan&Tabu_Search_Result';

    % ----------------------------------------------------------------
    % 工作表1写入最终路径汇总内容
    sheet1 = 1;
    total_Dis_Cost = sum([Ans.Final_DIs_Cost]);
    total_SubT_Cost = sum([Ans.Final_SubT_Cost]);
    total_Vehi_Cost = sum([Ans.Final_Vehi_Cost]);
    total_Final_IVECO = sum([Ans.Final_IVECO]);
    total_Final_TRUCK = sum([Ans.Final_TRUCK]);
    total_Cost = total_Dis_Cost + total_SubT_Cost + total_Vehi_Cost;

    Table1{1,1} = '总路程成本';
    Table1{1,2} = total_Dis_Cost;
    Table1{2,1} = '总超时成本';
    Table1{2,2} = total_SubT_Cost;
    Table1{3,1} = '总车辆成本';
    Table1{3,2} = total_Vehi_Cost;
    Table1{4,1} = 'IVECO总数目';
    Table1{4,2} = total_Final_IVECO;
    Table1{5,1} = 'TRUCK总数目';
    Table1{5,2} = total_Final_TRUCK;
    Table1{6,1} = '总成本';
    Table1{6,2} = total_Cost;
    xlswrite(filename,Table1,sheet1);

    % ----------------------------------------------------------------
    % 工作表2写入最终路线信息
    N = 1;
    for i = 1:length(Ans)
        for j =1: length(Ans(i).Final_Route)
            Table2{N,1} = '线路编号：';
            Table2{N,2} = N;
            Table2{N,3} = '车型：';
            Table2{N,4} = Ans(i).Final_Route.Type;
            Table2{N,5} = '线路：';
            for k = 1:length(Ans(i).Final_Route(j).V)
                Table2{N,5+k} = Ans(i).Final_Route(j).V(k).Number;
            end
            N = N + 1;
        end
    end
    xlswrite(filename,Table2,sheet1,'A10')

    %-----------------------------------------------------------------
end