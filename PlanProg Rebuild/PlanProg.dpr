program PlanProg;

uses
  Forms,
  General in 'General.pas' {MainForm},
  SettingForm in 'SettingForm.pas' {SetForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSetForm, SetForm);
  Application.Run;
end.
