unit uchat;

interface

uses
  SysUtils, Classes, Controls, Forms, ExtCtrls, StdCtrls, ComCtrls,
  PageExtControl;

type
  TfrmChat = class(TForm)
    PageExtControl1: TPageExtControl;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
  public
  end;

var
  frmChat:TfrmChat;  

implementation

uses mainunit;

{$R *.dfm}

procedure TfrmChat.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
  for i:=(PageExtControl1.PageCount-1) downto 0 do
    PageExtControl1.Pages[i].Free;
end;

procedure TfrmChat.FormShow(Sender: TObject);
begin
  Left := (Screen.Width - Width) div 2;
  Top  := (Screen.Height - Height) div 2;
end;

end.
