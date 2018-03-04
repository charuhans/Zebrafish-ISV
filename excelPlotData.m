function [success] = excelPlotData(ResultFile, excelCellIndexSheet1, header, letters, headerWithUnits, numberOfCharts)
    %letters = {'B','C','D','E','F','G','H','I','J'};
    %headerWithUnits = {'AverageDiameterHole(pixels)', 'AverageAreaHole(pixels)', 'TotalAreaHole(pixels)', 'Count', 'TotalAreaCV(pixels)', 'OrientationCV(degree)',...
        %'EquivDiameterCV(pixels)', 'PerimeterCV', 'SolidityCV'};
    %numberOfCharts = 9;
    success = false;
    Excel = actxserver('Excel.Application');

    % Make the Excel File Visible
    set(Excel,'Visible',1);

    Workbook = invoke(Excel.Workbooks,'Open', ResultFile);

    resultsheet = 'Sheet1';
    try
        sheet = get(Excel.Worksheets,'Item', resultsheet);
        invoke(sheet, 'Activate');
    catch
        % If the Excel Sheet ‘ExperimentSheet’ is not found, throw an error message
        errordlg([resultsheet 'not found']);
    end
    
   
    for i = 1:numberOfCharts
        Chart = Excel.ActiveSheet.Shapes.AddChart; % ActiveSheet.Shapes.AddChart.Select
        %Let us Rename this chart to 'according to header'
        Chart.Name = header{i+1};
        ExpChart = Excel.ActiveSheet.ChartObjects(header{i+1});
        ExpChart.Activate;
        %% Delete Default Entries
        % Let us delete all the entries in the chart generated by defalut
        try
            Series = invoke(Excel.ActiveChart,'SeriesCollection',1);
            invoke(Series,'Delete');
            Series = invoke(Excel.ActiveChart,'SeriesCollection',1);
            invoke(Series,'Delete');
            Series = invoke(Excel.ActiveChart,'SeriesCollection',1);
            invoke(Series,'Delete');
        catch e
        end
        %We are left with an empty chart now.
        %Insert a Chart for Column B
        NewSeries = invoke(Excel.ActiveChart.SeriesCollection,'NewSeries');
        NewSeries.XValues = ['=' resultsheet '!A' int2str(2) ':A' int2str(excelCellIndexSheet1 - 1)];
        NewSeries.Values  = ['=' resultsheet '!' letters{i} int2str(2) ':' letters{i} int2str(excelCellIndexSheet1 - 1)];
        NewSeries.Name    = ['=' resultsheet '!' letters{i} int2str(25) ];
        Excel.ActiveChart.ChartType = 'xlLineMarkers';
        %% Set the Axes
        % Set the x-axis
        Axes = invoke(Excel.ActiveChart,'Axes',1);
        set(Axes,'HasTitle',1);
        set(Axes.AxisTitle,'Caption',header{1});

        % Set the y-axis
        Axes = invoke(Excel.ActiveChart,'Axes',2);
        set(Axes,'HasTitle',1);
        set(Axes.AxisTitle,'Caption',headerWithUnits{i})

        %Give the Chart a title
        %%%Excel.ActiveChart.HasTitle = 1;
        %%%Excel.ActiveChart.ChartTitle.Characters.Text = header{i+1};
        
         %% Chart Placement
        Location  =  [  xlcolumn(i + 5) int2str(i + 5)];
        GetPlacement = get(Excel.ActiveSheet,'Range', Location);

        % Resize the Chart
        ExpChart.Width = 300;
        ExpChart.Height= 200;
        ExpChart.Left  = GetPlacement.Left;
        ExpChart.Top   = GetPlacement.Top;

        success = true;
    end       
    %% Save the Excel File		
	invoke(Excel.ActiveWorkbook,'Save'); 
	Excel.Quit
	Excel.delete
	clear Excel

end    
    
function loc = xlcolumn(column)

if isnumeric(column)
    if column>256
        error('Excel is limited to 256 columns! Enter an integer number <256');
    end
    letters = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    count = 0;
    if column-26<=0
        loc = char(letters(column));
    else
        while column-26>0
            count = count + 1;
            column = column - 26;
        end
        loc = [char(letters(count)) char(letters(column))];
    end
    
else
    letters = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
    if size(column,2)==1
        loc =findstr(column,letters);
    elseif size(column,2)==2
        loc1 =findstr(column(1),letters);
        loc2 =findstr(column(2),letters);
        loc = (26 + 26*loc1)-(26-loc2);
    end
end
end



