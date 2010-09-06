program ymsgpas;

uses
  Forms,
  mainunit in 'mainunit.pas' {frmMain},
  uchat in 'uchat.pas' {frmChat},
  uMsg in 'uMsg.pas' {frmMessage};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmChat, frmChat);
  Application.Run;
end.
