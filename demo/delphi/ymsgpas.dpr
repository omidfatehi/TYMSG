program ymsgpas;

uses
  Forms,
  mainunit in 'mainunit.pas' {frmMain},
  uchat in 'uchat.pas' {frmChat},
  uMsg in 'uMsg.pas' {frmMessage},
  urooms in 'urooms.pas' {frmRooms};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmChat, frmChat);
  Application.CreateForm(TfrmRooms, frmRooms);
  Application.Run;
end.
