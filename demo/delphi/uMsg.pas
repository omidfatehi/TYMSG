unit uMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ExtCtrls, StdCtrls;

type
  TfrmMessage = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    MemoChat: TMemo;
    MemoSend: TMemo;
    btnSend: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSendClick(Sender: TObject);
    procedure MemoSendKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
  end;

implementation

uses mainunit;

{$R *.dfm}

procedure TfrmMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmMessage.btnSendClick(Sender: TObject);
var s:string;
begin
  s := Trim(MemoSend.Lines.Text);
  MemoChat.SelStart := 0;
  MemoChat.Lines.Add(frmMain.ym.YahooID + ': '+s);
  SendMessage(MemoChat.Handle, EM_SCROLLCARET, 0, 0);
  frmMain.ym.SendInstantMessage(Caption,s);
end;

procedure TfrmMessage.MemoSendKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=13 then
    btnSendClick(Self);
end;

end.

