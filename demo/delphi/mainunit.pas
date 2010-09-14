unit mainunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, StdCtrls,
  ComCtrls, ExtCtrls, Menus, YMsgCore, YBuddyList, YMsgConst, libxmlparser,
  YmsgPckt, YChatList;

type
  TElementNode=class
    Content : string;
    Attr    : TStringList;
    constructor Create(TheContent: string; TheAttr: TNvpList);
    destructor Destroy; override;
  end;
  
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
    N2: TMenuItem;
    ChatRooms1: TMenuItem;
    TabSheet3: TTabSheet;
    Memo1: TMemo;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure TreeBuddiesDblClick(Sender: TObject);
    procedure ChatRooms1Click(Sender: TObject);
  private
    procedure OnError(Sender:TObject;Value:string);
    procedure OnStatus(Sender:TObject;Status:TYMsgCoreState);
    procedure OnBuddyList(Sender:TObject; Buddies:TYBuddyGroupList);
    procedure OnBuddyStatusUpdate(Sender:TObject;Buddy:TYBuddy);
    procedure OnBuddySignedOut(Sender:TObject;Buddy:TYBuddy);
    procedure OnReceiveMessage(Sender: TObject; From: TYBuddy;
        BuddyID, MsgTxt: String; TimeStamp: TDateTime; MsgStatus:TYMessageStatus);

    procedure CreateFormChat(YID:string;ChatMessage:string);

    procedure OnLogPacket(Sender: TObject; DataPacket: TYMsgPacket);
    
    // chat rooms
    procedure ScanChatCategories(XMLParser: TXmlParser; ATree: TTreeview;
      AParent: TTreeNode);
    procedure ScanChatRooms(XMLParser: TXmlParser; ATree: TTreeview;
      AParent: TTreeNode);    
    procedure OnChatCategories(Sender: TObject; Value: string); // xml
    procedure OnChatRooms(Sender: TObject; Value: string); // xml

    procedure OnChatJoin(Sender: TObject;  Room, Topic: string; Chatters:TYChatList);
    procedure OnChatMessage(Sender: TObject; Who, Room, AMessage:string; MsgType:integer);
    procedure OnChatUserJoin(Sender: TObject; Room, Topic: string; Who: TYChat);
    procedure OnChatUserLeave(Sender: TObject; Room, Who: string);
    procedure OnChatLogout(Sender: TObject);

  public
    ym:TYMSG;
    fLogin:Boolean;
  end;

var
  frmMain: TfrmMain;

implementation

uses uchat, uMsg, PageExtControl, urooms;

{$R *.dfm}

constructor TElementNode.Create(TheContent: string; TheAttr: TNvpList);
var
  i: integer;
begin
  inherited Create;
  Content := TheContent;
  Attr    := TStringList.Create;
  if (TheAttr<>nil) then
    for i:=0 to TheAttr.Count-1 do
      Attr.Add (TNvpNode (TheAttr [I]).Name + '=' + TNvpNode (TheAttr [I]).Value);
end;

destructor TElementNode.Destroy;
begin
  Attr.Free;
  inherited Destroy;
end;

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

  ym.OnChatCategories := OnChatCategories;
  ym.OnChatRooms := OnChatRooms;

  ym.OnChatJoin := OnChatJoin;
  ym.OnChatUserJoin := OnChatUserJoin;
  ym.OnChatMessage := OnChatMessage;
  ym.OnChatUserLeave := OnChatUserLeave;
  ym.OnChatLogout := OnChatLogout;

//  ym.OnLogPacket := OnLogPacket;

//  for i:=0 to PageControl1.PageCount-1 do
//    PageControl1.Pages[i].TabVisible := False;

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
  CreateFormChat(BuddyID,'Status: '+ s + ', TimeStamp: '+ DateTimeToStr(TimeStamp) + ' => ' + MsgTxt);
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
    ym.Login(ysInvisible);
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

procedure TfrmMain.ScanChatCategories(XMLParser: TXmlParser;
  ATree: TTreeview; AParent: TTreeNode);
var
  Node : TTreeNode;
  EN   : TElementNode;
begin
  while XmlParser.Scan do begin
    case XmlParser.CurPartType of
      ptStartTag,
      ptEmptyTag:
        begin
          if (XMLParser.CurName<>'content') and
            (XMLParser.CurName<>'chatCategories') then
          begin
            Node := ATree.Items.AddChild(AParent, XMLParser.CurAttr.Value('name'));
            if XmlParser.CurAttr.Count > 0 then
            begin
              EN := TElementNode.Create ('', XmlParser.CurAttr);
              Node.Data := EN;
            end;

            if XmlParser.CurPartType = ptStartTag then   // Recursion
              ScanChatCategories(XMLParser,ATree,Node);
          end;
        end;
      ptEndTag: break;
    end;
  end;
end;

procedure TfrmMain.ScanChatRooms(XMLParser: TXmlParser; ATree: TTreeview;
  AParent: TTreeNode);
var
  Node : TTreeNode;
  S    : string;
  EN   : TElementNode;
begin
  while XmlParser.Scan do begin
    case XmlParser.CurPartType of
      ptStartTag,
      ptEmptyTag:
        begin
          if (XMLParser.CurName='room') then
          begin
            Node := ATree.Items.AddChild(AParent, XMLParser.CurAttr.Value('name'));
            if XmlParser.CurAttr.Count > 0 then
            begin
              EN := TElementNode.Create ('', XmlParser.CurAttr);
              Node.Data := EN;
            end;

            if XmlParser.CurPartType = ptStartTag then
              ScanChatRooms(XMLParser,ATree,Node);
          end else
          if (XMLParser.CurName='lobby') then
          begin
            with XMLParser.CurAttr do begin
              s := AParent.Text + ':' + Value('count');
              s := s + ' Users:' + Value('users');
              s := s + ' Voices:' + Value('voices');
              s := s + ' Webcams:' + Value('webcams');
            end;
            Node := ATree.Items.AddChild(AParent, s);
            if XmlParser.CurAttr.Count > 0 then
            begin
              EN := TElementNode.Create ('', XmlParser.CurAttr);
              Node.Data := EN;
            end;

            if XmlParser.CurPartType = ptStartTag then
              ScanChatRooms(XMLParser,ATree,Node);
          end;
        end;
      ptEndTag: break;
    end;
  end;
end;

procedure TfrmMain.OnChatCategories(Sender: TObject; Value: string);
var
  parser:TXmlParser;
begin
  if (frmRooms.Visible=False) then
    frmRooms.Visible := True
  else
    frmRooms.BringToFront;
    
  parser := TXmlParser.Create;
  try
    parser.LoadFromBuffer(PChar(Value));
    frmRooms.TreeCat.Items.BeginUpdate;
    frmRooms.TreeCat.Items.Clear;
    parser.Normalize := False;
    parser.StartScan;
    ScanChatCategories(parser,frmRooms.TreeCat,nil);
    frmRooms.TreeCat.Items.EndUpdate;
  finally
    parser.Free;
  end;
end;

procedure TfrmMain.OnChatRooms(Sender: TObject; Value: string);
var
  parser:TXmlParser;
begin
  if (frmRooms.Visible=False) then
    frmRooms.Visible := True
  else
    frmRooms.BringToFront;

  parser := TXmlParser.Create;
  try
    parser.LoadFromBuffer(PChar(Value));
    frmRooms.TreeRoom.Items.BeginUpdate;
    frmRooms.TreeRoom.Items.Clear;
    parser.Normalize := False;
    parser.StartScan;
    ScanChatRooms(parser,frmRooms.TreeRoom,nil);
    frmRooms.TreeRoom.Items.EndUpdate;
  finally
    parser.Free;
  end;
end;

procedure TfrmMain.ChatRooms1Click(Sender: TObject);
begin
  if not fLogin then
    Exit;
  ym.GetChatRooms;
end;

procedure TfrmMain.OnChatJoin(Sender: TObject; Room, Topic: string;
  Chatters: TYChatList);
var i:integer;
    s:string;
begin
  for i:=0 to Chatters.ChatterCount-1 do
    s := s + ',' + Chatters.Chatter[i].YID;

  Memo1.Lines.Add('JOINED ROOM: '+Room+' - '+Topic+ ' => ' +s);
end;

procedure TfrmMain.OnChatMessage(Sender: TObject; Who, Room, AMessage: string;
  MsgType: integer);
begin
  Memo1.Lines.Add('RoomMessage: '+Room+' - '+Who+' => '+AMessage);
end;

procedure TfrmMain.OnChatUserJoin(Sender: TObject; Room, Topic: string; Who: TYChat);
begin
  Memo1.Lines.Add('Room: ' + Room + ' - ' + Topic + ' USER JOIN: '+ Who.YID);
end;


procedure TfrmMain.OnChatUserLeave(Sender: TObject; Room, Who: string);
begin
  Memo1.Lines.Add('USER LEAVE '+Room+ ':' +Who);
end;

procedure TfrmMain.OnChatLogout(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfrmMain.OnLogPacket(Sender: TObject; DataPacket: TYMsgPacket);
var i,k:integer;
    v:string;
begin
  Memo1.Lines.Add(#13#10); // line feed
  with DataPacket do begin
    for i:=0 to DataCount-1 do begin
      k := Datas[i].Key;
      v := Datas[i].Value;
      Memo1.Lines.Add(IntToStr(k) + '=>' + v);
    end;
  end;
end;


end.


