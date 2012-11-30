unit General;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DB, ADODB, DBGrids, XPMan, StdCtrls, ExtCtrls, UMainFunc;

type
  TMainForm = class(TForm)
    ADOConnection1: TADOConnection;
    dsPlanSbora: TDataSource;
    adoqReport_Warehouse: TADOQuery;
    dbgPlanSbora: TDBGrid;
    dbgPlanOtgruz: TDBGrid;
    dsPlanOtgruz: TDataSource;
    Timer1: TTimer;
    panCurrentDate: TPanel;
    gbPlanSbor: TGroupBox;
    gbPlanOtgruz: TGroupBox;
    tmChanger: TTimer;
    adoqPlanFact: TADOQuery;
    adoqWMSCheck: TADOQuery;
    tWMSCheck: TTimer;
    gbGraph: TGroupBox;
    Image1: TImage;
    adoqForGraph: TADOQuery;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);    // проверяет дату
    procedure tmChangerTimer(Sender: TObject); // меняет экраны
    procedure DoQueryOtgr; // выполнение запроса на отгрузку
    procedure DoQuerySbor; // выполнение запроса на сборку
    procedure tWMSCheckTimer(Sender: TObject);
    function IsWMS(InpStr: string): boolean;
    procedure dbgPlanSboraDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure panCurrentDateClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;

  public
    { Public declarations }
    ScrNumber: byte;
    byDay: array[1..14] of GrPoint;
    byMonth: array[1..8] of GrPoint;
    byYear: array[1..13] of GrPoint;
  end;

const
   MyHotKey = VK_F10;   

var
  MainForm: TMainForm;
  InWMS: array [1..1000] of string;
  WMSCount: integer;
  tempDate: string[30];
  ConnectAdd: string;

implementation

{$R *.dfm}

//------------------------------ Реагирование на клавишу -----------------------
procedure TMainForm.WMHotKey(var Msg: TWMHotKey);
begin
   if (Self.Active) then
      DoSettingsForm(false);
end;

//---------------------- Инициализация -----------------------------------------
procedure TMainForm.FormCreate(Sender: TObject); // при формировании главной формы
begin
   RegisterHotKey(MainForm.Handle, MyHotKey, 0, MyHotKey);
   Self.ScrNumber:= 1;
   //Self.ADOConnection1.Connected := true;
   try
      LoadSettings(Self, Self.ADOConnection1, Self.Timer1,
                   Self.tmChanger, Self.tWMSCheck);
      ConnectAdd:= Self.ADOConnection1.ConnectionString;
      //tWMSCheckTimer(tWMSCheck);
      Self.DoQuerySbor;
      Self.adoqReport_Warehouse.Active := true;
      Self.DoQueryOtgr;
      Self.adoqPlanFact.Active := true;
      Self.gbPlanSbor.Align := alClient;
      Self.gbPlanOtgruz.Align := alClient;
      Self.gbGraph.Align := alClient;
      GridColumnFit(Self.dbgPlanOtgruz);
      GridColumnFit(Self.dbgPlanSbora);
      Self.tWMSCheck.Enabled:= SyncWMS;
      DoGraphSQL(Self.adoqForGraph,byDay,byMonth,byYear);
   except
      ShowMessage('Возникла ошибка при загрузке настроек' + #13 +
      'Дальнейшая работа невозможна' + #13 +
      'Нажмите ОК для настроек');
      DoSettingsForm(true);
      Self.Close;
   end;
end;

//-------------------- Процедура проверки и вывода актуальной даты -------------
procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   Self.panCurrentDate.Caption := CurrentDate;
   if not (tempDate = CurrentDate) then
   begin
      tempDate:= CurrentDate;
      DoGraphSQL(Self.adoqForGraph, byDay, byMonth, byYear);
   end;
end;

//------------------ Процедура переключения экранов ----------------------------
procedure TMainForm.tmChangerTimer(Sender: TObject);
begin
   Self.dbgPlanSbora.Font.Size:=Round(Self.dbgPlanSbora.Width / 115);
   Self.dbgPlanOtgruz.Font.Size:=Round(Self.dbgPlanOtgruz.Width / 115);
   Self.dbgPlanSbora.TitleFont.Size:=Self.dbgPlanSbora.Font.Size;
   Self.dbgPlanOtgruz.TitleFont.Size:=Self.dbgPlanOtgruz.Font.Size;
   ScreenNumber(Self.ScrNumber);
   case Self.ScrNumber of
   // экран с планом
   1: try
         Self.DoQuerySbor; // формируем запрос
         Self.adoqReport_Warehouse.Active:= true; // выполняем запрос
         GridColumnFit(Self.dbgPlanSbora); // выставляем ширину столбцов, при каждом запросе параметры сбрасываются
         Self.gbPlanSbor.Visible:= true; // показываем экран на форме
         Self.gbPlanOtgruz.Visible:= false; // предыдущий экран скрываем
         Self.adoqPlanFact.Active:= false;  // предыдущий запрос убираем
         Self.gbGraph.Visible:= false;
      except
         ShowMessage('Возникла ошибка при подключении к базе' + #13 +
         'Дальнейшая работа невозможна' + #13 +
         'Нажмите ОК для выхода');
         Self.Close;
      end;

   // экран с отгрузкой
   2: try
         Self.DoQueryOtgr; // формируем запрос
         Self.adoqPlanFact.Active := true; // активируем запрос
         GridColumnFit(Self.dbgPlanOtgruz); // выставляем ширину столбцов
         Self.gbPlanOtgruz.Visible := true; // показываем экран на форме
         Self.gbPlanSbor.Visible := false; // и убираем с формы
         Self.adoqReport_Warehouse.Active := false; // старый запрос деактивируем
         Self.gbGraph.Visible:= false;
      except
         ShowMessage('Возникла ошибка при подключении к базе' + #13 +
         'Дальнейшая работа невозможна' + #13 +
         'Нажмите ОК для выхода');
         Self.Close;
      end;

   // экран с графиками
   3: try
         Self.gbGraph.Visible:= true;
         DrawGraph(Self.Image1, byDay, byMonth, byYear);
      except
         ShowMessage('Возникла ошибка при подключении к базе' + #13 +
         'Дальнейшая работа невозможна' + #13 +
         'Нажмите ОК для выхода');
         Self.Close;
      end;
   end;
end;

//------------------------- Формирование запроса на план отбора ----------------
procedure TMainForm.DoQuerySbor;
begin
   Self.adoqReport_Warehouse.SQL.Clear;
   Self.adoqReport_Warehouse.SQL.Add('select Reports_Warehouse.Number,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Documents,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Picking,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.quantity,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.boxes,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.pcs,');
   Self.adoqReport_Warehouse.SQL.Add('ROUND (Reports_Warehouse.mass, 3) AS mass,');
   Self.adoqReport_Warehouse.SQL.Add('ROUND (Reports_Warehouse.volume, 3) AS volume,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Date_Plans,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Status,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.AC,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.DOC');
   Self.adoqReport_Warehouse.SQL.Add('from Reports_Warehouse,');
   Self.adoqReport_Warehouse.SQL.Add('(select Reports_Warehouse.Number,');
   Self.adoqReport_Warehouse.SQL.Add('CAST(Reports_Warehouse.Documents as INTEGER) - CAST(Reports_Warehouse_fact.Documents AS INTEGER) AS Documents,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.AC');
   Self.adoqReport_Warehouse.SQL.Add('from Reports_Warehouse LEFT JOIN Reports_Warehouse_Fact ON Reports_Warehouse.Number = Reports_Warehouse_fact.Number AND Left(Reports_Warehouse_Fact.AC,1) = Left(Reports_Warehouse.AC,1)) as tab');
   Self.adoqReport_Warehouse.SQL.Add('where Reports_Warehouse.Number = tab.Number AND Left(Reports_Warehouse.AC,1) = LEFT(tab.AC,1) AND tab.Documents IS NULL');
   Self.adoqReport_Warehouse.SQL.Add('AND CAST(Reports_Warehouse.Date_Plans AS DATE) BETWEEN CAST(''' + FirstDate + ''' AS DATE) ' +
   'AND CAST(''' + SecondDate + ''' AS DATE)');
   Self.adoqReport_Warehouse.SQL.Add('UNION');
   Self.adoqReport_Warehouse.SQL.Add('select Reports_Warehouse.Number,');
   Self.adoqReport_Warehouse.SQL.Add('CAST(Reports_Warehouse.Documents as INTEGER) - CAST(Reports_Warehouse_fact.Documents AS INTEGER) AS Documents,');
   Self.adoqReport_Warehouse.SQL.Add('CAST (Reports_Warehouse.Picking as REAL) - CAST(Reports_Warehouse_fact.Picking AS REAL) AS Piking,');
   Self.adoqReport_Warehouse.SQL.Add('CAST (Reports_Warehouse.quantity as REAL) - CAST(Reports_Warehouse_fact.quantity AS REAL) AS quantity,');
   Self.adoqReport_Warehouse.SQL.Add('CAST (Reports_Warehouse.boxes as REAL) - CAST(Reports_Warehouse_fact.boxes AS REAL) AS boxes,');
   Self.adoqReport_Warehouse.SQL.Add('CAST (Reports_Warehouse.pcs as REAL) - CAST(Reports_Warehouse_fact.pcs AS REAL) AS pcs,');
   Self.adoqReport_Warehouse.SQL.Add('ROUND (CAST (Reports_Warehouse.mass as REAL) - CAST(Reports_Warehouse_fact.mass AS REAL), 3) AS mass,');
   Self.adoqReport_Warehouse.SQL.Add('ROUND (CAST (Reports_Warehouse.volume as REAL) - CAST(Reports_Warehouse_fact.volume AS REAL), 3) AS volume,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Date_Plans,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.Status,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.AC,');
   Self.adoqReport_Warehouse.SQL.Add('Reports_Warehouse.DOC ');
   Self.adoqReport_Warehouse.SQL.Add('from Reports_Warehouse JOIN Reports_Warehouse_Fact ON Reports_Warehouse.Number = Reports_Warehouse_fact.Number AND Left(Reports_Warehouse_Fact.AC,1) = Left(Reports_Warehouse.AC,1)');
   Self.adoqReport_Warehouse.SQL.Add('AND Reports_Warehouse.Documents > Reports_Warehouse_Fact.Documents');
   Self.adoqReport_Warehouse.SQL.Add('AND CAST(Reports_Warehouse.Date_Plans AS DATE) BETWEEN CAST(''' + FirstDate + ''' AS DATE) ' +
   'AND CAST(''' + SecondDate + ''' AS DATE)');
end;

//-------------------- формирование запроса на отгрузку ------------------------
procedure TMainForm.DoQueryOtgr;
begin
   Self.adoqPlanFact.SQL.Clear;
   Self.adoqPlanFact.SQL.Add
   ('SELECT Number, Drivers, Forwarder, SUM(CAST(Documents AS INT)) AS DocSum, ROUND(SUM(CAST(Mass AS REAL)),3) AS Mass, ROUND(SUM(CAST(Volume AS REAL)),3) AS Volume, Date_Plans, Status, DOC, Date_Delivery ' +
   'FROM Reports_Warehouse_fact ');
   Self.adoqPlanFact.SQL.Add
   ('WHERE CAST(Date_Plans AS DATE) BETWEEN CAST(''' + FirstDate + ''' AS DATE) ' +
   'AND CAST(''' + SecondDate + ''' AS DATE) AND Status NOT IN (''Выдан'', ''Архив'') ');
   Self.adoqPlanFact.SQL.Add
   ('GROUP BY Number, Drivers, Forwarder, Date_Plans, Status, DOC, Date_Delivery');
end;

//------------------------ процедура синхронизации с WMS -----------------------
procedure TMainForm.tWMSCheckTimer(Sender: TObject);
var
   i: integer;
begin
   try
      Self.adoqWMSCheck.SQL.Clear;
      Self.adoqWMSCheck.SQL.Add('SELECT DISTINCT Number, Date_Plans ');
      Self.adoqWMSCheck.SQL.Add('FROM Reports_Warehouse, TRANSIT.dbo.hdr_DeliveryRequest ');
      Self.adoqWMSCheck.SQL.Add('WHERE CAST (Date_Delivery AS DATE) BETWEEN CAST(''' + WeekMinus + ''' AS DATE) AND CAST(''' + WeekPlus + ''' AS DATE)');
      Self.adoqWMSCheck.SQL.Add('AND CAST (DeliveryDate AS DATE) BETWEEN CAST(''' + WeekMinus + ''' AS DATE) AND CAST(''' + WeekPlus + ''' AS DATE)');
      Self.adoqWMSCheck.SQL.Add('AND RouteNumber like ''%''+Rtrim(Number)+''%''');
      Self.adoqWMSCheck.Active := true;
      Self.adoqWMSCheck.First;
      for i:= 1 to Self.adoqWMSCheck.RecordCount do
      begin
         InWMS[i]:= Self.adoqWMSCheck.Fields.Fields[0].AsString;
         Self.adoqWMSCheck.Next;
      end;
      WMSCount:= Self.adoqWMSCheck.RecordCount;
      Self.adoqWMSCheck.Active := false;
   except
      ShowMessage('Возникла ошибка при загрузке настроек' + #13 +
      'Дальнейшая работа невозможна' + #13 +
      'Нажмите ОК для выхода');
      Self.Close;
   end;
end;

//---------- функция проверки наличия документа в транзитной базе --------------
function TMainForm.IsWMS(InpStr: string): boolean;
var
   i: integer;
begin
   Result:= false;
   for i:= 1 to WMSCount do
      if (InpStr = InWMS[i]) then
      begin
         Result:= true;
         break;
      end;
end;

//--------------------- Процедура отрисовки таблички ---------------------------
procedure TMainForm.dbgPlanSboraDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
   if Column.FieldName = 'Number' then
   if (Self.IsWMS(Column.Field.AsString)) then
   begin
      Self.dbgPlanSbora.Canvas.Brush.Color:= clGreen;
      Self.dbgPlanSbora.DefaultDrawColumnCell(Rect, DataCol, Column, State);
   end;
end;

//--------------------- Процедура масштабирования формы ------------------------
procedure TMainForm.FormResize(Sender: TObject);
begin
   Self.panCurrentDate.Font.Size:= Round(Self.Width / 50);
   Self.panCurrentDate.Height:= Round(Self.panCurrentDate.Width / 20);
   Self.gbPlanSbor.Font.Size:= Round(Self.panCurrentDate.Width / 69.78571428571429);
   Self.gbPlanOtgruz.Font.Size:= Round(Self.panCurrentDate.Width / 69.78571428571429);
   Self.gbGraph.Font.Size:= Round(Self.panCurrentDate.Width / 69.78571428571429);
   Self.gbPlanSbor.Font.Style:= Self.panCurrentDate.Font.Style;
   Self.gbPlanOtgruz.Font.Style:= Self.panCurrentDate.Font.Style;
   Self.gbGraph.Font.Style:= Self.panCurrentDate.Font.Style;
   Self.dbgPlanSbora.Font.Size:=Round(Self.dbgPlanSbora.Width / 115);
   Self.dbgPlanOtgruz.Font.Size:=Round(Self.dbgPlanOtgruz.Width / 115);
   Self.dbgPlanSbora.TitleFont.Size:=Self.dbgPlanSbora.Font.Size;
   Self.dbgPlanOtgruz.TitleFont.Size:=Self.dbgPlanOtgruz.Font.Size;
   DrawGraph(Self.Image1,byDay,byMonth,byYear);

   if Self.adoqReport_Warehouse.Active then
      GridColumnFit(Self.dbgPlanSbora);

   if Self.adoqPlanFact.Active then
      GridColumnFit(Self.dbgPlanOtgruz);
end;

//------------------------- процедура уничтожения формы ------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
   Self.ADOConnection1.Connected := false;
   UnRegisterHotKey(MainForm.Handle, MyHotKey);
end;

procedure TMainForm.panCurrentDateClick(Sender: TObject);
begin
   Self.tmChangerTimer(MainForm);
end;

end.
