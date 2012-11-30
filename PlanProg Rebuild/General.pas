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
    procedure Timer1Timer(Sender: TObject);    // ��������� ����
    procedure tmChangerTimer(Sender: TObject); // ������ ������
    procedure DoQueryOtgr; // ���������� ������� �� ��������
    procedure DoQuerySbor; // ���������� ������� �� ������
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

//------------------------------ ������������ �� ������� -----------------------
procedure TMainForm.WMHotKey(var Msg: TWMHotKey);
begin
   if (Self.Active) then
      DoSettingsForm(false);
end;

//---------------------- ������������� -----------------------------------------
procedure TMainForm.FormCreate(Sender: TObject); // ��� ������������ ������� �����
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
      ShowMessage('�������� ������ ��� �������� ��������' + #13 +
      '���������� ������ ����������' + #13 +
      '������� �� ��� ��������');
      DoSettingsForm(true);
      Self.Close;
   end;
end;

//-------------------- ��������� �������� � ������ ���������� ���� -------------
procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   Self.panCurrentDate.Caption := CurrentDate;
   if not (tempDate = CurrentDate) then
   begin
      tempDate:= CurrentDate;
      DoGraphSQL(Self.adoqForGraph, byDay, byMonth, byYear);
   end;
end;

//------------------ ��������� ������������ ������� ----------------------------
procedure TMainForm.tmChangerTimer(Sender: TObject);
begin
   Self.dbgPlanSbora.Font.Size:=Round(Self.dbgPlanSbora.Width / 115);
   Self.dbgPlanOtgruz.Font.Size:=Round(Self.dbgPlanOtgruz.Width / 115);
   Self.dbgPlanSbora.TitleFont.Size:=Self.dbgPlanSbora.Font.Size;
   Self.dbgPlanOtgruz.TitleFont.Size:=Self.dbgPlanOtgruz.Font.Size;
   ScreenNumber(Self.ScrNumber);
   case Self.ScrNumber of
   // ����� � ������
   1: try
         Self.DoQuerySbor; // ��������� ������
         Self.adoqReport_Warehouse.Active:= true; // ��������� ������
         GridColumnFit(Self.dbgPlanSbora); // ���������� ������ ��������, ��� ������ ������� ��������� ������������
         Self.gbPlanSbor.Visible:= true; // ���������� ����� �� �����
         Self.gbPlanOtgruz.Visible:= false; // ���������� ����� ��������
         Self.adoqPlanFact.Active:= false;  // ���������� ������ �������
         Self.gbGraph.Visible:= false;
      except
         ShowMessage('�������� ������ ��� ����������� � ����' + #13 +
         '���������� ������ ����������' + #13 +
         '������� �� ��� ������');
         Self.Close;
      end;

   // ����� � ���������
   2: try
         Self.DoQueryOtgr; // ��������� ������
         Self.adoqPlanFact.Active := true; // ���������� ������
         GridColumnFit(Self.dbgPlanOtgruz); // ���������� ������ ��������
         Self.gbPlanOtgruz.Visible := true; // ���������� ����� �� �����
         Self.gbPlanSbor.Visible := false; // � ������� � �����
         Self.adoqReport_Warehouse.Active := false; // ������ ������ ������������
         Self.gbGraph.Visible:= false;
      except
         ShowMessage('�������� ������ ��� ����������� � ����' + #13 +
         '���������� ������ ����������' + #13 +
         '������� �� ��� ������');
         Self.Close;
      end;

   // ����� � ���������
   3: try
         Self.gbGraph.Visible:= true;
         DrawGraph(Self.Image1, byDay, byMonth, byYear);
      except
         ShowMessage('�������� ������ ��� ����������� � ����' + #13 +
         '���������� ������ ����������' + #13 +
         '������� �� ��� ������');
         Self.Close;
      end;
   end;
end;

//------------------------- ������������ ������� �� ���� ������ ----------------
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

//-------------------- ������������ ������� �� �������� ------------------------
procedure TMainForm.DoQueryOtgr;
begin
   Self.adoqPlanFact.SQL.Clear;
   Self.adoqPlanFact.SQL.Add
   ('SELECT Number, Drivers, Forwarder, SUM(CAST(Documents AS INT)) AS DocSum, ROUND(SUM(CAST(Mass AS REAL)),3) AS Mass, ROUND(SUM(CAST(Volume AS REAL)),3) AS Volume, Date_Plans, Status, DOC, Date_Delivery ' +
   'FROM Reports_Warehouse_fact ');
   Self.adoqPlanFact.SQL.Add
   ('WHERE CAST(Date_Plans AS DATE) BETWEEN CAST(''' + FirstDate + ''' AS DATE) ' +
   'AND CAST(''' + SecondDate + ''' AS DATE) AND Status NOT IN (''�����'', ''�����'') ');
   Self.adoqPlanFact.SQL.Add
   ('GROUP BY Number, Drivers, Forwarder, Date_Plans, Status, DOC, Date_Delivery');
end;

//------------------------ ��������� ������������� � WMS -----------------------
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
      ShowMessage('�������� ������ ��� �������� ��������' + #13 +
      '���������� ������ ����������' + #13 +
      '������� �� ��� ������');
      Self.Close;
   end;
end;

//---------- ������� �������� ������� ��������� � ���������� ���� --------------
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

//--------------------- ��������� ��������� �������� ---------------------------
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

//--------------------- ��������� ��������������� ����� ------------------------
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

//------------------------- ��������� ����������� ����� ------------------------
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
