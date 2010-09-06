unit mainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Menus, ComCtrls,
  ExtCtrls, StdCtrls, YMsgCore, YBuddyList, YMsgConst;

type
  { TfrmMain }

  TfrmMain = class(TForm)
    btnLogin: TButton;
    edtYID: TEdit;
    edtPWD: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Notebook1: TNotebook;
    Page1: TPage;
    Page2: TPage;
    StatusBar1: TStatusBar;
    TreeBuddies: TTreeView;
    procedure btnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    fLogin:Boolean;
    ym:TYMSG;
    procedure OnError(Sender:TObject;Value:string);
    procedure OnStatus(Sender:TObject;Status:TYMsgCoreState);
    procedure OnBuddyList(Sender:TObject; Buddies:TYBuddyGroupList);
    procedure OnBuddyStatusUpdate(Sender:TObject;Buddy:TYBuddy);
    procedure OnBuddySignedOut(Sender:TObject;Buddy:TYBuddy);
    procedure OnReceiveMessage(Sender: TObject; From: TYBuddy;
        BuddyID, MsgTxt: String; IsOffline: Boolean);
  public
  end; 

var
  frmMain: TfrmMain;

implementation

{ TfrmMain }

procedure TfrmMain.MenuItem4Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.OnError(Sender: TObject; Value: string);
begin
  StatusBar1.SimpleText:= Value;
end;

procedure TfrmMain.OnStatus(Sender: TObject; Status: TYMsgCoreState);
var s:string;
begin
  case Status of
  ymsSignedIn:
    begin
      fLogin := True;
      s := 'Logged in';
      NoteBook1.ActivePage := 'Page2';
    end;
  ymsSignedOut:
    begin
      fLogin := False;
      s := 'Logged out';
      MenuItem2.Caption := '&Logout';
      NoteBook1.ActivePage:= 'Page1';
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

procedure TfrmMain.OnBuddyList(Sender: TObject; Buddies: TYBuddyGroupList);
var
  i,j:integer;
  node:TTreeNode;
  g:TYBuddyGroup;
begin
  NoteBook1.ActivePage:= 'Page2';
  for i:=0 to Buddies.Count-1 do begin
    g := Buddies.Groups[i];
    node := TreeBuddies.Items.Add(nil,g.GroupName);
    for j:=0 to g.Buddies.Count-1 do
      TreeBuddies.Items.AddChild(node,g.Buddies.Items[j].YID);
  end;
end;

procedure TfrmMain.OnBuddyStatusUpdate(Sender: TObject; Buddy: TYBuddy);
begin

end;

procedure TfrmMain.OnBuddySignedOut(Sender: TObject; Buddy: TYBuddy);
begin

end;

procedure TfrmMain.OnReceiveMessage(Sender: TObject; From: TYBuddy; BuddyID,
  MsgTxt: String; IsOffline: Boolean);
begin

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  fLogin := False;
  ym := TYMSG.Create;
  ym.OnError := @OnError;
  ym.OnStatus := @OnStatus;
  ym.OnBuddyStatusUpdate := @OnBuddyStatusUpdate;
  ym.OnBuddySignedOut := @OnBuddySignedOut;
  ym.OnReceiveIMessage := @OnReceiveMessage;
  ym.OnBuddyList:= @OnBuddyList;

  Notebook1.ActivePage:= 'Page1';
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ym.Free;
end;

procedure TfrmMain.btnLoginClick(Sender: TObject);
begin
  if not fLogin then
  begin
    if (edtYID.Text='') or (edtPWD.Text='') then
      Exit;
    MenuItem2.Caption := '&Logout';
    ym.YahooID := edtYID.Text;
    ym.Password:= edtPWD.Text;
    ym.Login;
  end else
  begin
    ym.Logout;
    MenuItem2.Caption := '&Login';
  end;
end;


initialization
  {$I mainunit.lrs}

end.

