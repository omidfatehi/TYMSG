unit mainunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, StdCtrls,
  ComCtrls, ExtCtrls, Menus, YMsgCore, YBuddyList, YMsgConst;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    YMsgPas1: TMenuItem;
    Login1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtYID: TEdit;
    edtPWD: TEdit;
    Label2: TLabel;
    btnLogin: TButton;
    TreeBuddies: TTreeView;
    Button1: TButton;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure TreeBuddiesDblClick(Sender: TObject);
  private
    fLogin:Boolean;
    procedure OnError(Sender:TObject;Value:string);
    procedure OnStatus(Sender:TObject;Status:TYMsgCoreState);
    procedure OnBuddyList(Sender:TObject; Buddies:TYBuddyGroupList);
    procedure OnBuddyStatusUpdate(Sender:TObject;Buddy:TYBuddy);
    procedure OnBuddySignedOut(Sender:TObject;Buddy:TYBuddy);
    procedure OnReceiveMessage(Sender: TObject; From: TYBuddy;
        BuddyID, MsgTxt: String; TimeStamp: TDateTime; MsgStatus:TYMessageStatus);

    procedure CreateFormChat(YID:string;ChatMessage:string);
  public
    ym:TYMSG;
  end;

var
  frmMain: TfrmMain;

implementation

uses uchat, uMsg, PageExtControl;

{$R *.dfm}

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var i:integer;
begin
  fLogin := False;
  ym := TYMSG.Create;
  ym.OnError := OnError;
  ym.OnStatus := OnStatus;
  ym.OnBuddyStatusUpdate := OnBuddyStatusUpdate;
  ym.OnBuddySignedOut := OnBuddySignedOut;
  ym.OnReceiveMessage := OnReceiveMessage;
  ym.OnBuddyList:= OnBuddyList;

  for i:=0 to PageControl1.PageCount-1 do
    PageControl1.Pages[i].TabVisible := False;
    
  PageControl1.ActivePageIndex := 0;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ym.Free;
end;

procedure TfrmMain.OnBuddyList(Sender: TObject; Buddies: TYBuddyGroupList);
var
  i,j:integer;
  node:TTreeNode;
  g:TYBuddyGroup;
begin
  TreeBuddies.Items.Clear;
  PageControl1.ActivePageIndex:= 1;
  for i:=0 to Buddies.Count-1 do begin
    g := Buddies.Groups[i];
    node := TreeBuddies.Items.Add(nil,g.GroupName);
    for j:=0 to g.Buddies.Count-1 do
      TreeBuddies.Items.AddChild(node,g.Buddies.Items[j].YID);
  end;
end;

procedure TfrmMain.OnBuddySignedOut(Sender: TObject; Buddy: TYBuddy);
begin
  // TODO: iconify
end;

procedure TfrmMain.OnBuddyStatusUpdate(Sender: TObject; Buddy: TYBuddy);
begin
  // TODO: iconify 
end;

procedure TfrmMain.OnError(Sender: TObject; Value: string);
begin
  StatusBar1.SimpleText:= Value;
end;

procedure TfrmMain.OnReceiveMessage(Sender: TObject; From: TYBuddy;
  BuddyID, MsgTxt: String; TimeStamp: TDateTime; MsgStatus: TYMessageStatus);
var s: string;
begin
  case MsgStatus of
    ymNormal: s := 'OK';
    ymError: s := 'Error sending message';
    ymOffline: s := 'Offline message';
  end;
  CreateFormChat(BuddyID,'Status: '+ s + ', waktu: '+ DateTimeToStr(TimeStamp) + ' => ' + MsgTxt);
end;

procedure TfrmMain.OnStatus(Sender: TObject; Status: TYMsgCoreState);
var s:string;
begin
  case Status of
  ymsSignedIn:
    begin
      fLogin := True;
      s := 'Logged in';
      PageControl1.ActivePageIndex := 1;
    end;
  ymsSignedOut:
    begin
      fLogin := False;
      s := 'Logged out';
      Login1.Caption := '&Logout';
      PageControl1.ActivePageIndex:= 0;
      edtPWD.Clear;
    end;
  ymsConnecting: s := 'Connecting';
  ymsVerify: s := 'Verifying';
  ymsAuthentication: s := 'Authenticating';
  ymsLoggingIn: s := 'Logging in';
  ymsGetToken: s := 'Trying to get Yahoo! token';
  ymsGetCrumb: s := 'Trying to get Yahoo! crumb';
  end;
  StatusBar1.SimpleText := s;
end;

procedure TfrmMain.btnLoginClick(Sender: TObject);
begin
  if not fLogin then
  begin
    if (edtYID.Text='') or (edtPWD.Text='') then
      Exit;
    Login1.Caption := '&Logout';
    ym.YahooID := edtYID.Text;
    ym.Password:= edtPWD.Text;
    ym.Login(ysCustom, 'test status');
  end else
  begin
    ym.Logout;
    Login1.Caption := '&Login';
  end;
end;

procedure TfrmMain.CreateFormChat(YID, ChatMessage: string);
var
  aForm:TfrmMessage;
  aTab:TTabExtSheet;
  i,j:integer;
  found:Boolean;
begin
  if (YID='') then Exit;
  if not frmChat.Visible then
    frmChat.Show
  else
    frmChat.BringToFront;

  aTab := nil;
  found := False;
  with frmChat do begin
    for i:=0 to PageExtControl1.PageCount-1 do
    begin
      aTab := PageExtControl1.Pages[i];  
      if (aTab.Caption=(YID+StringOfChar(#32,10))) then
      begin
        found := True;
        for j:=0 to aTab.ComponentCount-1 do begin
          if (aTab.Components[j] is TfrmMessage) then
          begin
            aForm := TfrmMessage(aTab.Components[j]);
            if (ChatMessage<>'') then begin
              aForm.MemoChat.SelStart := 0;
              aForm.MemoChat.Lines.Add(YID + ': '+ ChatMessage);
              SendMessage(aForm.MemoChat.Handle, EM_SCROLLCARET, 0, 0);
            end;
            Break;
          end;
        end;
        Break;
      end;
    end;   

    if not found then begin
      aTab := TTabExtSheet.Create(PageExtControl1) ;
      aTab.PageExtControl := PageExtControl1;

      aForm := TfrmMessage.Create(aTab) ;
      aForm.Parent := aTab;
      aForm.Caption := YID;
      aForm.Align := alClient;
      aForm.BorderStyle := bsNone;
      aForm.Visible := true;
      if (ChatMessage<>'') then
        aForm.MemoChat.Lines.Add(YID+': '+ChatMessage);

      aTab.Caption := YID;
    end;

    if aTab<>nil then
      PageExtControl1.ActivePage := aTab;

  end;
end;

procedure TfrmMain.TreeBuddiesDblClick(Sender: TObject);
var
  node:TTreeNode;
begin
  node := TreeBuddies.Selected;
  if (node=nil) or (node.Level=0) then
    Exit;
  CreateFormChat(node.Text,'');
end;

end.
