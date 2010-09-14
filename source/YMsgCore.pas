{
  Original code: TYMsgCore - http://sourceforge.net/projects/tymsgcore
  Author: Hamid_PaK [PRAISER] - praiser_man@yahoo.com

  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YMsgCore;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

// uncomment this line if you want delphi vcl, never test :)
//{$DEFINE KOMPONEN}

interface

uses
  SysUtils, Classes, ExtCtrls, httpsynapse,
  YMsgSock, YMsgConst, YMsgPckt, YBuddyList, YChatList;

type
  TYMSGStatusEvent = type TTCPEvent;
  TOnBuddyStatusUpdate = procedure(Sender: TObject; Buddy: TYBuddy) of object;
  TOnBuddySignedOut = procedure(Sender: TObject; Buddy: TYBuddy) of object;

  TOnBuzz = procedure(Sender: TObject; From: string; DateTime: TDateTime) of object;
  TOnReceiveMessage = procedure(Sender: TObject; From: TYBuddy;
      BuddyID, MsgTxt: String; DateTime: TDateTime; MsgStatus: TYMessageStatus) of object;

  TOnAddRequest = procedure(Sender: TObject; From: String; var MsgTxt: String;
      var Accept: Boolean) of object;
  TOnNewEmail = procedure(Sender: TObject; EmailCount: Integer) of object;
  TOnBuddyPicture = procedure(Sender: TObject; Buddy: TYBuddy;
      BuddyID, ImageUrl: String; ImageType: TYBImage) of object;

  TOnLogPacket = procedure(Sender: TObject; DataPacket: TYMsgPacket) of object;

  TOnBuddyList = procedure(Sender: TObject; Buddies: TYBuddyGroupList) of object;
  TOnStatus = procedure(Sender: TObject; State: TYMsgCoreState) of object;
  TOnBuddyTyping = procedure(Sender: TObject; From: string; Stop: Boolean) of object;

  TOnChatJoin = procedure(Sender: TObject; Room, Topic: string; Chatters:TYChatList) of object;

  // Who => the user who has joined, Must be freed by the client ?
  TOnChatUserJoin = procedure(Sender: TObject; Room, Topic: string; Who: TYChat) of object;

  TOnChatUserLeave = procedure(Sender: TObject; Room, Who: string) of object;

  //msgtype  - 1 = Normal message, 2 = /me type message
  TOnChatMessage = procedure(Sender: TObject; Who, Room, AMessage: string; MsgType:integer) of object;

  TYMSG = class{$IFDEF KOMPONEN}(TComponent){$ENDIF}
  private
    sock:TTCPClient;
    http:THTTPClient;
    FPing:TTimer;
    FSession:DWORD;
    FHost,FPort,
    FYID,FPWD:string;
    FState:TYMsgCoreState;
    FPSend,FPRecv: TYMsgPacket;
    FOnError:TYMSGStatusEvent;
    FOnStatus: TOnStatus;

    FYSeed,FYCrumb,
    FYCookie,FTCookie,
    FBCookie,FYHash:string;
    FBuddies:TYBuddyGroupList;
    FOnBuddyStatusUpdate: TOnBuddyStatusUpdate;
    FOnBuddySignedOut:TOnBuddySignedOut;
    FOnReceiveMessage: TOnReceiveMessage;
    FOnAddRequest: TOnAddRequest;
    FOnNewEmail: TOnNewEmail;
    FOnBuddyPicture: TOnBuddyPicture;
    FOnLogPacket: TOnLogPacket;
    FOnBuddyList: TOnBuddyList;
    FOnTyping: TOnBuddyTyping;
    FOnBuzz: TOnBuzz;
    FStatus: TYStatus;
    FInitialText:string;

    FOnChatCat,
    FOnChatRoom:TYMSGStatusEvent;
    FChatters: TYChatList;
    FOnChatJoin: TOnChatJoin;
    FOnChatUserLeave: TOnChatUserLeave;
    FOnChatMessage: TOnChatMessage;
    FOnChatUserJoin: TOnChatUserJoin;
    FOnChatLogout: TNotifyEvent;

    procedure SockError(Sender:TObject;Value:string);
    procedure SockConnected(Sender:TObject);
    procedure SockDisconnected(Sender:TObject);
    procedure SockData(Sender:TObject;Buffer:TMemory;Len:integer);

    procedure HTTPError(Sender:TObject;ErrMsg:string;ErrorCode:integer);
    procedure HTTPContent(Sender:TObject;Header,Document:string;ResulCode:integer);
    procedure HTTPBinaryData(Sender:TObject; BinaryData:TStream;ResultCode:integer);

    procedure DoError(ErrorMsg:string);
    procedure DoStatus(AState:TYMsgCoreState);

    function  SplitePacket(Buffer: PChar; Len: Integer): Integer;
    procedure ParseData(DataPacket: TYMsgPacket);
    procedure DoInitAuthentication(ADataPacket: TYMsgPacket);
    procedure DoInitLogin(ADataPacket: TYMsgPacket);
    procedure DoParseList(ADataPacket: TYMsgPacket);
    procedure DoParseY8List(ADataPacket: TYMsgPacket);
    procedure DoStatusY8(ADataPacket: TYMsgPacket);
    procedure DoLogOff(ADataPacket:TYMsgPacket);
    procedure DoReceiveMessage(ADataPacket:TYMsgPacket);
    procedure DoAddBuddy(ADataPacket: TYMsgPacket);
    procedure DoRemBuddy(ADataPacket: TYMsgPacket);
    procedure DoPicture(ADataPacket: TYMsgPacket);
    procedure DoNewEmail(ADataPacket: TYMsgPacket);
    procedure DoAddRequest(ADataPacket: TYMsgPacket);
    procedure DoPing(Sender:TObject);
    procedure DoProcessNotify(ADataPacket: TYMsgPacket);
    procedure DoProcessStatus(ADataPacket: TYMsgPacket);

    procedure ProcessYMToken(Value:string);
    procedure ProcessYMCrumb(Header:string;Value:string);
    procedure ProcessChatCat(Value:TStream);
    procedure ProcessChatRoom(Value:TStream);
    procedure DoProcessChat(ADataPacket: TYMsgPacket);

  public
    constructor Create{$IFDEF KOMPONEN}(AOwner: TComponent);override{$ENDIF};
    destructor Destroy;override;
    procedure Login(Status: TYStatus = ysAvailable; CustomText: string = '');
    procedure Logout;

    procedure AddBuddy(ABuddyID, AddToGroup: String; RequestMessage: String = '');
    procedure RemoveBuddy(ABuddy, AddToGroup: String);
    procedure SendInstantMessage(ToUser, AMessage: String);
    procedure SendTyping(ToWho: String; Stop: Boolean = False);
    procedure SetStatus(AStatus: TYStatus; CustomText: String = '');
    procedure IgnoreBuddy(ABuddyID:string);
    procedure UnignoreBuddy(ABuddyID:string);

    procedure SendBuzz(ToWho: string);

    procedure SendPacket(ADataPacket: TYMsgPacket);
    procedure GetChatRooms(RoomID:integer=0); // result => xml

    // RoomName format => Room:Lobby
    // ex. Indonesia:1
    // TODO: scan chat rooms to get room id
    procedure JoinChatRoom(RoomName: string; RoomID: integer);

    procedure LeaveChatRoom;    


  published
    property Host:string read FHost write FHost;
    property Port:string read FPort write FPort;
    property YahooID:string read FYID write FYID;
    property Password:string read FPWD write FPWD;

    property OnStatus: TOnStatus read FOnStatus write FOnStatus;
    property OnError: TYMSGStatusEvent read FOnError write FOnError;
    property OnBuddyStatusUpdate: TOnBuddyStatusUpdate read FOnBuddyStatusUpdate write FOnBuddyStatusUpdate;
    property OnBuddySignedOut:  TOnBuddySignedOut read FOnBuddySignedOut write FOnBuddySignedOut;
    property OnReceiveMessage: TOnReceiveMessage read FOnReceiveMessage write FOnReceiveMessage;
    property OnAddRequest: TOnAddRequest read FOnAddRequest write FOnAddRequest;
    property OnNewEmail: TOnNewEmail read FOnNewEmail write FOnNewEmail;
    property OnLogPacket: TOnLogPacket read FOnLogPacket write FOnLogPacket;
    property OnBuddyList: TOnBuddyList read FOnBuddyList write FOnBuddyList;
    property OnBuddyTyping: TOnBuddyTyping read FOnTyping write FOnTyping;
    property OnBuzz: TOnBuzz read FOnBuzz write FOnBuzz;
    property OnBuddyPicture: TOnBuddyPicture read FOnBuddyPicture write FOnBuddyPicture;

    property OnChatCategories: TYMSGStatusEvent read FOnChatCat write FOnChatCat;
    property OnChatRooms: TYMSGStatusEvent read FOnChatRoom write FOnChatRoom;
    property OnChatJoin: TOnChatJoin read FOnChatJoin write FOnChatJoin;
    property OnChatUserLeave: TOnChatUserLeave read FOnChatUserLeave write FOnChatUserLeave;
    property OnChatMessage: TOnChatMessage read FOnChatMessage write FOnChatMessage;
    property OnChatUserJoin: TOnChatUserJoin read FOnChatUserJoin write FOnChatUserJoin;
    property OnChatLogout: TNotifyEvent read FOnChatLogout write FOnChatLogout;

  end;

{$IFDEF KOMPONEN}
procedure Register;
{$ENDIF}

implementation

uses synautil, synacode;

{$IFDEF KOMPONEN}
procedure Register;
begin
  RegisterComponents('YMSG',[TYMSG]);
end;
{$ENDIF}

function YahooBase64(const Value: AnsiString): AnsiString;
begin
  Result := EncodeBase64(Value);
  Result := ReplaceString(Result,'+','.');
  Result := ReplaceString(Result,'/','_');
  Result := ReplaceString(Result,'=','-');
end;

function UnixToDateTime(USec: Longint): TDateTime;
const
  // Sets UnixStartDate to TDateTime of 01/01/1970
  UnixStartDate: TDateTime = 25569;
begin
  Result := (Usec / 86400) + UnixStartDate;
end;

function GMTToLocalTime(GMTTime: TDateTime): TDateTime;
var s:string;
begin
  s := FormatDateTime('d mmm yy hh:mm:ss', GMTTime) + ' GMT';	
  Result := DecodeRfcDateTime(s);
end;

{ TYMSG }

constructor TYMSG.Create{$IFDEF KOMPONEN}(AOwner: TComponent){$ENDIF};
begin
  inherited {$IFDEF KOMPONEN}Create(AOwner){$ENDIF};
  sock := TTCPClient.Create;
  sock.OnError := SockError;
  sock.OnConnected := SockConnected;
  sock.OnDisconnected := SockDisconnected;
  sock.OnData := SockData;

  http := THTTPClient.Create;
  http.OnError := HTTPError;
  http.OnContent := HTTPContent;
  http.OnBinaryData := HTTPBinaryData;

  FHost := 'scs.msg.yahoo.com';
  FPort := '5050';

  FState := ymsSignedOut;
  FStatus := ysAvailable;
  FInitialText := '';
  
  FPSend := TYMsgPacket.Create;
  FPRecv := TYMsgPacket.Create;
  FBuddies := TYBuddyGroupList.Create(TYBuddyGroup);

  FPing := TTimer.Create(nil);
  FPing.OnTimer := DoPing;
  FPing.Interval := 100000;

  FChatters := TYChatList.Create;

end;

destructor TYMSG.Destroy;
begin
  if (FState<>ymsSignedOut) then
    Logout;
  FPing.Free;
  http.Free;
  sock.Free;
  FPSend.Free;
  FPRecv.Free;
  FBuddies.Free;
  FChatters.Free;
  inherited Destroy;
end;

procedure TYMSG.SockConnected(Sender: TObject);
begin
  DoStatus(ymsVerify);
  with FPSend do begin
    Clear;
    Add(1, FYID);
    Header.Service := YAHOO_SERVICE_AUTH;
  end;
  SendPacket(FPSend);
end;

function BufToStr(var buf; bufSize: integer) : string;
begin
  SetLength(result, bufSize);
  Move(buf, pointer(result)^, bufSize);
end;

procedure StrToBuf(var buf; str: string);
begin
  Move(pointer(str)^, buf, Length(str));
end;

procedure TYMSG.SockData(Sender: TObject; Buffer: TMemory; Len: integer);
var
  idx,i: Integer;
  buf: PChar;
begin
  idx := 0;
  buf := Buffer;
  if (len >= 20) then
  repeat
    i := len -idx;
    i := SplitePacket(buf +idx, i);
    if (FPRecv.Write(buf +idx, i) >= 20) then begin
      if (FSession <> FPRecv.Header.SessionID) then
        FSession := FPRecv.Header.SessionID;
     ParseData(FPRecv);
    end;
    Inc(idx, i);
  until (len <= idx);
end;

procedure TYMSG.SockDisconnected(Sender: TObject);
begin
  DoStatus(ymsSignedOut);
end;

procedure TYMSG.SockError(Sender: TObject; Value: string);
begin
  DoError('Socket Error: '+Value);
end;

procedure TYMSG.HTTPContent(Sender: TObject; Header, Document: string;
  ResulCode: integer);
begin
  case FState of
    ymsGetToken: ProcessYMToken(Document);
    ymsGetCrumb: ProcessYMCrumb(Header,Document);
  end;
end;

procedure TYMSG.HTTPError(Sender: TObject; ErrMsg: string;
  ErrorCode: integer);
begin
  DoError('HTTP Error: '+IntToStr(ErrorCode)+' '+ErrMsg);
end;           

procedure TYMSG.Login(Status: TYStatus = ysAvailable; CustomText: string = '');
begin
  if sock.IsConnected or
    (FState<>ymsSignedOut) then
    Exit;

  if (Status = ysOffline) then
  begin
    Logout;
    Exit;
  end;

  FStatus := Status;
  FInitialText := CustomText;

  DoStatus(ymsConnecting);
  sock.Host := FHost;
  sock.Port := FPort;
  sock.Connect;
end;

procedure TYMSG.Logout;
begin
  if (not sock.IsConnected) or
    (FState=ymsSignedOut) then
    Exit;

  LeaveChatRoom;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_LOGOFF;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
  end;
  SendPacket(FPSend);
  sock.Disconnect;
end;

procedure TYMSG.DoError(ErrorMsg: string);
begin
  if Assigned(OnError) then
    FOnError(Self,ErrorMsg);
end;

procedure TYMSG.SendPacket(ADataPacket: TYMsgPacket);
var pckt: PChar;
    len:integer;
    s:string;
begin
  if (not sock.IsConnected) then
    Exit;

  pckt := AllocMem(YAHOO_DATA_MAX);
  try
    ADataPacket.Header.SessionID := FSession;
    len := ADataPacket.Read(pckt);
    SetString(s,pckt,len);
    sock.SendData(s);
  finally
    FreeMem(pckt);
  end;

end;

function TYMSG.SplitePacket(Buffer: PChar; Len: Integer): Integer;
var
  p: PChar;
begin
  Result := 0;
  p := Buffer;
  repeat
    Inc(Buffer);
    if
      (Buffer[0] +Buffer[1] +Buffer[2] +Buffer[3] = YAHOO_PROTOCOL_SIGN)
    then Break;
  until (buffer -p >= len);
  Inc(Result, buffer -p);
end;

procedure TYMSG.ParseData(DataPacket: TYMsgPacket);
var
  p: TYMsgPacket;
  parsed: Boolean;
begin
  parsed := False;
  p := TYMsgPacket.Create;
  try
    p.Assign(DataPacket);
    //if Assigned(OnDataParse) then
      //FOnDataParse(Self, p, parsed);
    if (not parsed) then begin
      case DataPacket.Header.Service of
        YAHOO_SERVICE_VERIFY: DoInitAuthentication(DataPacket);
        YAHOO_SERVICE_AUTH: DoInitLogin(DataPacket);
        YAHOO_SERVICE_AUTHRESP: DoInitLogin(DataPacket);
        YAHOO_SERVICE_LIST: DoParseList(DataPacket);// identities + cookies
        YAHOO_SERVICE_Y8_LIST: DoParseY8List(DataPacket);
        YAHOO_SERVICE_LOGON,YAHOO_SERVICE_Y8_STATUS: DoStatusY8(DataPacket);
        YAHOO_SERVICE_LOGOFF: DoLogOff(DataPacket);
        YAHOO_SERVICE_MESSAGE: DoReceiveMessage(DataPacket);
        YAHOO_SERVICE_ADDBUDDY: DoAddBuddy(DataPacket);
        YAHOO_SERVICE_REMBUDDY: DoRemBuddy(DataPacket);
        YAHOO_SERVICE_NEWMAIL: DoNewEmail(DataPacket);
        YAHOO_SERVICE_Y7_AUTHORIZATION: DoAddRequest(DataPacket);
	      YAHOO_SERVICE_USERSTAT,
	      //YAHOO_SERVICE_LOGOFF,
	      YAHOO_SERVICE_ISAWAY,
	      YAHOO_SERVICE_ISBACK,
	      YAHOO_SERVICE_GAMELOGON,
	      YAHOO_SERVICE_GAMELOGOFF,
	      YAHOO_SERVICE_IDACT,
	      YAHOO_SERVICE_IDDEACT,
	      YAHOO_SERVICE_Y6_STATUS_UPDATE: DoProcessStatus(DataPacket);

        YAHOO_SERVICE_NOTIFY: DoProcessNotify(DataPacket);

        YAHOO_SERVICE_PICTURE: DoPicture(DataPacket);

        YAHOO_SERVICE_CHATONLINE,
        YAHOO_SERVICE_CHATGOTO,
        YAHOO_SERVICE_CHATJOIN,
        YAHOO_SERVICE_CHATLEAVE,
        YAHOO_SERVICE_CHATEXIT,
        YAHOO_SERVICE_CHATLOGOUT,
        YAHOO_SERVICE_CHATPING,
        YAHOO_SERVICE_COMMENT:DoProcessChat(DataPacket);
        //DoLogPacket(DataPacket);/;

      end;
      if Assigned(OnLogPacket) then
        FOnLogPacket(Self, DataPacket);
    end;
  finally
    p.Free;
  end;
end;

procedure TYMSG.DoInitAuthentication(ADataPacket: TYMsgPacket);
begin
  DoStatus(ymsAuthentication);
  with FPSend do begin
    Clear;
    Add(1, FYID);
    Header.Service := YAHOO_SERVICE_AUTH;
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.DoInitLogin(ADataPacket: TYMsgPacket);
var
  yid: String;
  idx: Integer;
begin
  with ADataPacket do
  if (Header.Status = YAHOO_STATUS_SERVERACT) then begin

    idx := ADataPacket.IndexOf(94);
    if (idx < 0) then
      raise Exception.Create('The Seed not found in packet!');

    FYSeed := ADataPacket.Datas[ idx ].Value;
    idx := ADataPacket.IndexOf(1);
    if (idx < 0) then
      raise Exception.Create('Yahoo ID not found!');

    yid := ADataPacket.Datas[ idx ].Value;

    DoStatus(ymsGetToken);
    http.HTTPGet(
      'https://login.yahoo.com/config/pwtoken_get?src=ymsgr&ts=&login=' + yid +
      '&passwd='+EncodeURLElement(FPWD)+
      '&chal='+EncodeURLElement(FYSeed)
    );

  end else begin
    idx := YAHOO_LOGIN_SERVER;
    if (IndexOf(66) >= 0) then
      idx := StrToIntDef(Datas[IndexOf(66)].Value, 1);
    case idx of
      YAHOO_LOGIN_OK: yid := 'Account is OK';
      YAHOO_LOGIN_SERVER: yid := 'Server Error';
      YAHOO_LOGIN_LOGOFF: yid := 'Account is Logoff';
      YAHOO_LOGIN_UNAME: yid := 'Invalid Username';
      YAHOO_LOGIN_PASSWD: yid := 'Invalid Pasword';
      YAHOO_LOGIN_LOCK: yid := 'Account is Lock';
      YAHOO_LOGIN_DUPL: yid := 'Account is Duplicate';
      YAHOO_LOGIN_SOCK: yid := 'Socket Error';
      else yid := 'Unknown Error';
    end;

    DoError('Response: '+yid);
  end;
end;

procedure TYMSG.ProcessYMToken(Value: string);
var
  st:TStringList;
  i:integer;
  found:Boolean;
  seed:string;
begin
  found := False;
  st := TStringList.Create;
  try
    st.Delimiter := '=';
    st.Text := Value;
    for i:=0 to st.Count-1 do begin
      if (st.Names[i]='ymsgr') then begin
        found := True;
        seed := st.ValueFromIndex[i];
        Break;
      end;
    end;
  finally
    st.Free;
  end;

  if found then begin
    DoStatus(ymsGetCrumb);
    http.HTTPGet(
      'https://login.yahoo.com/config/pwtoken_login?src=ymsgr&ts=&token='+
      EncodeURLElement(seed)
    );
  end else
  begin
    Logout;
    DoError('Authetication failed! Try again.');
  end;
end;

procedure TYMSG.ProcessYMCrumb(Header, Value: string);
var st:TStringList;
    i:integer;
    found:Boolean;
begin
  found := False;
  FBCookie := GetBetween('B=',';',Header);
  st := TStringList.Create;
  try
    st.Delimiter := '=';
    st.Text := Value;
    for i:=0 to st.Count-1 do begin
      if (st.Names[i]='crumb') then begin
        found := True;
        FYCrumb := st.ValueFromIndex[i];
        if (st.Names[i+1]='Y') then
          FYCookie := st.ValueFromIndex[i+1];
        if (st.Names[i+2]='T') then
          FTCookie := st.ValueFromIndex[i+2];
        Break;
      end;
    end;
  finally
    st.Free;
  end;

  if found then begin
    // recheck
    if (FYCrumb<>'') and (FYCookie<>'') and
      (FTCookie<>'') and (FBCookie<>'') then
    begin
      FYHash := YahooBase64(MD5(FYCrumb+FYSeed));
      FBCookie := #$42+#$09+FBCookie;    
      DoStatus(ymsLoggingIn);
      with FPSend do begin
        Header.Service := YAHOO_SERVICE_AUTHRESP;
        if (FStatus = ysInvisible) then
          Header.Status := YAHOO_STATUS_INVISIBLE
        else
          Header.Status := YAHOO_STATUS_WEBLOGIN;
        Clear;
        Add(1,FYID);
        Add(0,FYID);
        Add(277,FYCookie);
        Add(278,FTCookie);
        Add(307,FYHash);
        Add(244,'4194239');
        Add(2,FYID);
        Add(2,'1');
        Add(59,FBCookie);
        Add(98,'us');
        Add(135, YMSG_VERSION);
      end;
      SendPacket(FPSend);
      
    end else
      DoError('Authentication failed!. Try again');
  end else
    DoError('Authentication failed!. Try again');
end;        

procedure TYMSG.DoStatus(AState:TYMsgCoreState);
begin
  FState:= AState;
  if Assigned(OnStatus) then
    FOnStatus(Self,AState);
end;

procedure TYMSG.DoParseY8List(ADataPacket: TYMsgPacket);
var
  i,idx,j: Integer;
  grp,yid:string;
  bud:TYBuddy;
begin
  idx := 0;
  j:= 0;
  for i:=0 to ADataPacket.DataCount-1 do
  begin
    case ADataPacket.Datas[i].Key of
      302:
        begin
          if (ADataPacket.Datas[i].Value='320') then
          begin
          grp := 'Ignore list';
          idx := FBuddies.FindGroup(grp);
          if (idx<0) then
            with FBuddies.Add(grp) do
              idx := Index;
          end;
        end;
      300,301: ;//TODO;
      65:
        begin
          grp := ADataPacket.Datas[i].Value;
          idx := FBuddies.FindGroup(grp);
          if (idx<0) then
            with FBuddies.Add(grp) do
              idx := Index;
        end;
      7:
        begin
          yid := ADataPacket.Datas[i].Value;
          if not FBuddies.FindYID(yid,bud) then
            with FBuddies.Groups[idx].Buddies.Add(yid) do
            begin
              State := ysOffline;
              j := Index; 
            end;
        end;
      241:
        begin
          // another protocol user
          //if (bud<>nil) then
            //bud.protocol := null
        end;
      223:
        begin
          // Auth request pending
        end;
      59: ;
      317:
        begin
          // stealth settings
          FBuddies.Groups[idx].Buddies.Items[j].State := ysInvisible;
        end;
    end;

  end;

  if Assigned(OnBuddyList) then
    FOnBuddyList(Self,FBuddies);  

    {
  for i:=0 to FBuddies.Count-1 do begin
    DoError('+'+FBuddies.Groups[i].GroupName);
    for idx:=0 to FBuddies.Groups[i].Buddies.Count-1 do
      DoError(chr(9)+FBuddies.Groups[i].Buddies.Items[idx].YID);
  end;
     }
end;

procedure TYMSG.DoStatusY8(ADataPacket: TYMsgPacket);
var i,k:integer;
    v:string;
    budd,last:TYBuddy;
begin
  budd := nil;
  last := nil;
  for i:=0 to ADataPacket.DataCount-1 do
  begin
    k := ADataPacket.Datas[i].Key;
    v := ADataPacket.Datas[i].Value;
    //DoError(inttostr(k)+':'+v);
    case k of
      0: ; // do nothing
      1: ;
      7:  begin

            if (budd<>nil) then begin
              last := budd;
              if Assigned(OnBuddyStatusUpdate) then
                FOnBuddyStatusUpdate(Self,last);
            end;
            FBuddies.FindYID(v,budd);
          end; // ini yahoo id nya
      8: ;
      10: begin
            if (budd <> nil) then begin
              budd.State := TYStatus(StrToIntDef(v, 0 ));
              budd.Busy := (budd.State in [ysBeRightBack..ysSteppedOut]);
            end;
          end;
      11: ;
      13: ;// bitmask, bit 0 = pager, bit 1 = chat, bit 2 = game
      16: ;// custom error message
      17: ;// in chat?
      19: begin
            if (budd <> nil) then
              budd.Status := UTF8Decode(v);
          end;// custom status message
      24: ;// session timestamp
      47: begin
            if (budd <> nil) then
            if (budd.State = ysCustom) then
              budd.Busy := Boolean(StrToIntDef(v, 0));
          end;// is it an away message or not
      60: begin
            // SMS -> 1 MOBILE USER
      			// sometimes going offline makes this 2, but invisible never sends it
            // ex. I'm on mobile bla bla
          end;
      97: ;// utf8
      137: ;// Idle: seconds
      138: ;// Idle: Flag -> 0: Use the 137 key to see how long -> 1: not-idle
      192: ;// Pictures aka BuddyIcon
      197: ;// avatar base64 encodded
      213: ;// Pictures aka BuddyIcon  type 0-none, 1-avatar, 2-picture
      244: ;// client version number. Yahoo Client Detection
      241: ;// protocol
    end; // else unknown status
  end;
  if (last <> budd) and (budd <> nil) then
    if Assigned(OnBuddyStatusUpdate) then
      FOnBuddyStatusUpdate(Self, budd);
end;

procedure TYMSG.DoLogOff(ADataPacket: TYMsgPacket);
var
  bud: TYBuddy;
begin
  if Assigned(OnBuddySignedOut) then
  with ADataPacket do begin
    if (ADataPacket = nil) then begin
      FOnBuddySignedOut(Self, nil);
    end else
    if (Header.Status <> YAHOO_STATUS_SERVERACT) then begin
    end else
    if (IndexOf(7) >= 0) then begin
      if FBuddies.FindYID(Datas[IndexOf(7)].Value, bud) then begin
        with bud do begin
          State := ysOffline;
          Status := '';
        end;
        FOnBuddySignedOut(Self, bud);
      end;
    end;
  end;
end;

procedure TYMSG.DoReceiveMessage(ADataPacket: TYMsgPacket);
var 
  i,k:integer;
  tm: LongInt; 
  v,aFrom,aTo,aMsg,
  aGunk: string;
  bud: TYBuddy;
  d: TDateTime;
begin

  with ADataPacket do begin
    for i:=0 to DataCount-1 do begin
      k := Datas[i].Key;
      v := Datas[i].Value;
      case k of
        4: aFrom := v;
        5: aTo := v;
        15: TryStrToInt(v, tm);  // message timestamp
        97:  ; // whether the message is encoded as utf8 or not
        14,16: aMsg := UTF8Decode(v);
        31: ; //
        32: ; //
        241: ; // protocol
        429: aGunk := v;
      end; // case
    end; // for

    d := GMTToLocalTime(UnixToDateTime(tm));
    
    if (Header.Service = YAHOO_SERVICE_SYSMESSAGE) then
    begin
      if Assigned(OnReceiveMessage) then
        FOnReceiveMessage(Self, nil, aFrom, aMsg, d, ymNormal)
    end else begin
      if (Header.Status <= 2 ) or (Header.Status = 5) then
      begin
      // if we got the aGunk
        if (aGunk <> '') then begin
          with FPSend do begin
            Header.Service := YAHOO_SERVICE_MESSAGE_CONFIRM;
            Header.Status := YPACKET_STATUS_DEFAULT;
            Clear;
            Add(1, FYID);
            Add(5, aFrom);
            Add(302, '430');
            Add(430, aGunk);
            Add(303, '430');
            Add(450, '0');
          end;
          SendPacket(FPSend);
        end;

        bud := nil;
        // if we got buzz
        if (aMsg = '<ding>') then begin
          if Assigned(OnBuzz) then begin
              FOnBuzz(Self, aFrom, d);
          end;
        end else
        begin
          if Assigned(OnReceiveMessage) then begin
            if (FBuddies.FindYID(aFrom, bud)) then
              FOnReceiveMessage(Self, bud, aFrom, aMsg, d, TYMessageStatus(Header.Status))
          else
              FOnReceiveMessage(Self, nil, aFrom, aMsg, d, TYMessageStatus(Header.Status));
          end;
        end;

      end; // status <= 2 || status == 5
      
    end;
  end; // ADataPacket
end;

procedure TYMSG.DoAddBuddy(ADataPacket: TYMsgPacket);
var
  i: Integer;
begin
  with ADataPacket do begin
    if
      (IndexOf(7) < 0) and
      (IndexOf(65) < 0) and
      (IndexOf(66) < 0) and
      (Datas[IndexOf(66)].Value <> '0')
    then Exit;
    i := FBuddies.FindGroup(Datas[IndexOf(65)].Value);
    if (i < 0) then
      with FBuddies.Add(Datas[IndexOf(65)].Value) do i := Index;
    FBuddies.Groups[i].Buddies.Add(Datas[IndexOf(7)].Value);
  end;
end;

procedure TYMSG.DoAddRequest(ADataPacket: TYMsgPacket);
var
  from, msg, tmp: String;
  accpet: Boolean;
  pckt: TYMsgPacket;
begin
  accpet := False;
  with ADataPacket do begin
    if (IndexOf(4) >= 0) then begin
      if (IndexOf(13) >= 0) and (Datas[ IndexOf(13) ].Value <> '0') then Exit;

      from := Datas[IndexOf(4)].Value;
      msg := '';
      if (IndexOf(14) >= 0) then
        msg := Datas[IndexOf(14)].Value;
        tmp := msg;

      if Assigned(OnAddRequest) then
        FOnAddRequest(Self, from, msg, accpet);

      pckt := TYMsgPacket.Create;
      with pckt do
      try
        Header.Service := YAHOO_SERVICE_Y7_AUTHORIZATION;
        Header.Status := YPACKET_STATUS_DEFAULT;
        Add(1, FYID);
        Add(5, from);
        if (accpet) then
          Add(13, '1') else
          Add(13, '2');
        if (not accpet) and (tmp <> msg) then
          Add(14, UTF8Encode(msg));
        SendPacket(pckt);
      finally
        Free;
      end;
    end;
  end;
end;

procedure TYMSG.DoNewEmail(ADataPacket: TYMsgPacket);
var
  idx, cnt: Integer;
begin
  {
   9  = count
   18 = subject
   42 = email
   43 = who
  }
  if Assigned(OnNewEmail) then
  with ADataPacket do begin
    idx := IndexOf(9);
    cnt := StrToIntDef(Datas[ idx ].Value, 0);
    if (cnt > 0) then
      FOnNewEmail(Self, cnt);
  end;
end;

procedure TYMSG.DoPicture(ADataPacket: TYMsgPacket);
var
  typ: TYBImage;
  id: String;
  pic: String;
  bud: TYBuddy;
begin
  if Assigned(OnBuddyPicture) then
  with ADataPacket do begin
    if
      (IndexOf(4) < 0) or
      (IndexOf(13) < 0) or
      (IndexOf(20) < 0)
    then begin
      if
        (IndexOf(4) < 0) or
        (IndexOf(13) < 0)
      then begin
        FPSend.Header.Service := YAHOO_SERVICE_PICTURE;
        FPSend.Header.Status := YPACKET_STATUS_DEFAULT;
        FPSend.Clear;
        FPSend.Add(1, FYID);
        FPSend.Add(5, Datas[IndexOf(4)].Value);
        FPSend.Add(13, Datas[IndexOf(13)].Value);
        SendPacket(FPSend);
      end;
      Exit;
    end;

    id := Datas[IndexOf(4)].Value;
    pic := Datas[IndexOf(20)].Value;
    typ := TYBImage(StrToIntDef(Datas[IndexOf(13)].Value, 0));
    if (not FBuddies.FindYID(id, bud)) then bud := nil;
    FOnBuddyPicture(Self, bud, id, pic, typ);
  end;
end;

procedure TYMSG.DoRemBuddy(ADataPacket: TYMsgPacket);
var
  i: Integer;
  bud: TYBuddy;
begin
  with ADataPacket do begin
    if
      (IndexOf(7) < 0) and
      (IndexOf(65) < 0) and
      (IndexOf(66) < 0) and
      (Datas[IndexOf(66)].Value <> '0')
    then Exit;
    if (FBuddies.FindYID(Datas[IndexOf(7)].Value, bud)) then begin
      i := FBuddies.FindGroup(Datas[IndexOf(65)].Value);
      if (i < 0) then Exit;
      FBuddies.Groups[i].Buddies.Delete(bud.Index);
    end;
  end;
end;

procedure TYMSG.DoPing(Sender: TObject);
var
  pckt: TYMsgPacket;
begin
  if (FState <> ymsSignedIn) then Exit;
  FPing.Enabled := False;  
  pckt := TYMsgPacket.Create;
  try
    pckt.Header.Service := YAHOO_SERVICE_PING;
    pckt.Header.Status := YPACKET_STATUS_DEFAULT;
    SendPacket(pckt);
  finally
    pckt.Free;
  end;
  FPing.Enabled := True;
end;

procedure TYMSG.AddBuddy(ABuddyID, AddToGroup, RequestMessage: String);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_ADDBUDDY;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    if (Length(Trim(RequestMessage)) > 0) then
      Add(14, RequestMessage);
    Add(65, AddToGroup);
    Add(97, '1');
    Add(1, FYID);
    Add(302,'319');
    Add(300,'319');
    Add(7, ABuddyID);
    Add(301,'319');
    Add(303,'319');
    SendPacket(FPSend);
  end;
end;

procedure TYMSG.RemoveBuddy(ABuddy, AddToGroup: String);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_REMBUDDY;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(7, ABuddy);
    Add(65, AddToGroup);
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.SendInstantMessage(ToUser, AMessage: String);
//var
//  bud: TYBuddy;
begin
  if (FState<>ymsSignedIn) or (ToUser='') or (AMessage='') then
    Exit;

  with FPSend do begin
    Header.Service := YAHOO_SERVICE_MESSAGE;
   // if (FBuddies.FindYID(ToUser, bud)) then begin
   //   if (bud.State = ysOffline) then
   //     Header.Status := YPACKET_STATUS_OFFLINE else
   //     Header.Status := YPACKET_STATUS_DEFAULT;
   // end else
      Header.Status := YAHOO_STATUS_OFFLINE;
    Clear;
    if (ToUser = FYID) then 
      Add(0, FYID);
    Add(1, FYID);
    Add(5, ToUser);
    Add(14, AMessage);
    //Add(97, '1');
    Add(63, ';0');
    Add(64, '0');
    Add(206,'0');
    
  end;
  SendPacket(FPSend);

end;

procedure TYMSG.SendTyping(ToWho: String; Stop: Boolean);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_NOTIFY;
    Header.Status := YPACKET_STATUS_NOTIFY;
    Clear;
    Add(49, 'TYPING');
    Add(1, FYID);
    Add(14, ' ');
    Add(13, IntToStr(Integer((not Stop))));
    Add(5, ToWho);
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.SetStatus(AStatus: TYStatus; CustomText: String = '');
var oldstatus: TYStatus;
begin
  if (FState<>ymsSignedIn) then
    Exit;

  oldstatus := FStatus;

  if (CustomText <> '') then
    FStatus := ysCustom
  else
    FStatus := AStatus;

  if (FStatus = ysInvisible) then
  begin
    with FPSend do begin
      Header.Service := YAHOO_SERVICE_Y6_VISIBLE_TOGGLE;
      Header.Status := YPACKET_STATUS_DEFAULT;
      Clear;
      Add(13, '2');
    end;
    SendPacket(FPSend);
    Exit;
  end;

  with FPSend do begin
    Header.Service := YAHOO_SERVICE_Y6_STATUS_UPDATE;
    Header.Status := Integer(TYStatus(FStatus));
    Clear;
    Add(10, IntToStr(Integer(TYStatus(FStatus))));

    if (FStatus = ysCustom) then
    begin
      Add(19, CustomText);
      Add(97, '1');
      Add(47, '0'); // TODO: idle => yahoo_packet_hash(pkt, 47, (away == 2) ? "2" : (away) ? "1" : "0");
      Add(187, '0');
    end else
    begin
      Add(19, '');
      Add(97, '1');
    end;
  end;

  SendPacket(FPSend);

  if oldstatus = ysInvisible then begin
    with FPSend do begin
      Header.Service := YAHOO_SERVICE_Y6_VISIBLE_TOGGLE;
      Header.Status := YPACKET_STATUS_DEFAULT;
      Clear;
      Add(13, '1');
    end;
    SendPacket(FPSend);
  end;

end;

procedure TYMSG.IgnoreBuddy(ABuddyID: string);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_IGNORECONTACT;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(7, ABuddyID);
    Add(13,'1');
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.UnignoreBuddy(ABuddyID: string);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_IGNORECONTACT;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(7, ABuddyID);
    Add(13,'2');
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.DoProcessNotify(ADataPacket: TYMsgPacket);
var 
  i,k:integer; 
  v,aFrom,aTo,aMsg,aInd:string; 
  stat: Boolean; 
begin
  stat := false;
  with ADataPacket do begin
    for i:=0 to DataCount-1 do begin
      k := Datas[i].Key;
      v := Datas[i].Value;
      case k of
        4: aFrom := v;
        5: aTo := v;
        49: aMsg := v;
        13: stat := StrToBoolDef(v,True);
        14: aInd := v; // TODO 
        16: ; // TODO
      end;
    end;
  end;
  
  // recheck 
  if (aMsg='') then Exit; 

  if Pos('TYPING',aMsg)>0 then begin 
    if Assigned(OnBuddyTyping) then 
      FOnTyping(Self, aFrom, stat); 
  end;// else GAME, WEBCAMINVITE 
end;


procedure TYMSG.DoProcessStatus(ADataPacket: TYMsgPacket);
begin
  // TODO 
end;

procedure TYMSG.SendBuzz(ToWho: string);
begin
  SendInstantMessage(ToWho, '<ding>');  
end;

procedure TYMSG.GetChatRooms(RoomID: integer);
begin
  if (FState = ymsSignedOut) then
    Exit;
  if (RoomID=0) then begin
    FState := ymsChatCategories;
    http.HTTPGet('http://insider.msg.yahoo.com/ycontent/?chatcat=0');
  end else
  begin
    FState := ymsChatRooms;
    http.HTTPGet('http://insider.msg.yahoo.com/ycontent/?chatroom_'+IntToStr(RoomID)+'=0');
  end;
end;

procedure TYMSG.ProcessChatCat(Value: TStream);
begin
  if Assigned(OnChatCategories) then
    FOnChatCat(Self,ReadStrFromStream(Value,Value.Size));
end;

procedure TYMSG.ProcessChatRoom(Value: TStream);
begin
  if assigned(OnChatRooms) then
    FOnChatRoom(Self,ReadStrFromStream(Value,Value.Size));
end;

procedure TYMSG.JoinChatRoom(RoomName: string; RoomID: integer);
begin
  if FState = ymsSignedOut then
    Exit;
  FChatters.Clear;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_CHATONLINE;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(109, FYID);
    Add(6, 'abcde');
    Add(98, 'us');
    Add(445, 'en-us');
    Add(135, YMSG_VERSION);
  end;
  SendPacket(FPSend);

  with FPSend do begin
    Header.Service := YAHOO_SERVICE_CHATJOIN;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(104, RoomName);
    Add(129, IntToStr(RoomID));
    Add(62, '2');
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.DoParseList(ADataPacket: TYMsgPacket);
begin
  // TODO: identities, cookies

  if (FState <> ymsSignedIn) then begin
    DoStatus(ymsSignedIn);
    if (FStatus <> ysInvisible) then
      SetStatus(FStatus, FInitialText);
  end;
end;

procedure TYMSG.HTTPBinaryData(Sender: TObject; BinaryData: TStream;
  ResultCode: integer);
begin
  case FState of
    ymsChatCategories: ProcessChatCat(BinaryData);
    ymsChatRooms: ProcessChatRoom(BinaryData);    
  end;

end;

procedure TYMSG.DoProcessChat(ADataPacket: TYMsgPacket);
var i, k, membercount,msgtype,
    chaterr, firstjoin, verify_image:integer;
    v, id, who, room, topic, msg,
    verify_url: string;
    curmember: TYChat;
begin
  chaterr := -1;
  verify_image := 1;
  with ADataPacket do begin
    for i:=0 to DataCount-1 do begin
      k := Datas[i].Key;
      v := Datas[i].Value;
      case k of
        1: id := v; // my identity
        104: room := v; // room name
        105: topic := v; // room topic
        108: membercount := StrToIntDef(v,0); // Number of members in this packet
        109:
          begin
            who := v; // message sender
            if (Header.Service = YAHOO_SERVICE_CHATJOIN) then
            begin
              curmember := FChatters.Add;
              curmember.YID := who;
            end;
          end;
        110: if (Header.Service=YAHOO_SERVICE_CHATJOIN) then curmember.Age := StrToInt(v); // curmember age
        113: if (Header.Service=YAHOO_SERVICE_CHATJOIN) then curmember.Attribs := StrToInt(v); // curmember attribs
        141: if (Header.Service=YAHOO_SERVICE_CHATJOIN) then curmember.Alias := v; // curmember alias
        142: if (Header.Service=YAHOO_SERVICE_CHATJOIN) then curmember.Location := v; // location
        130: firstjoin := 1; // first join
        117: msg := v;
        124: msgtype := StrToInt(v);
        114: chaterr := StrToInt(v); //-1 means no session in room
      end; // case
    end;

    if (room = '') then begin
      if (Header.Service = YAHOO_SERVICE_CHATLOGOUT) then // yahoo originated chat logout
      begin
        FChatters.Clear;
        if Assigned(OnChatLogout) then
          FOnChatLogout(Self);
        Exit;
      end else
      if (Header.Service = YAHOO_SERVICE_COMMENT) and (chaterr = -1) then
      begin
        // TODO: yahoo error
        Exit;
      end;

      // We didn't get a room name, ignoring packet
      Exit;
    end;


    case Header.Service of
      YAHOO_SERVICE_CHATJOIN:
        begin
          if (FChatters.ChatterCount <> membercount) then begin
            //TODO: Count of members doesn't match No. of members we got
          end;          
          if ( (firstjoin = 1) and (FChatters.ChatterCount>0) )then begin
            if Assigned(OnChatJoin) then
              FOnChatJoin(Self, room, topic, FChatters);
          end else // firstjoin
          begin
            if (who <> '') then begin
               // TODO: display captcha image verification to client
               {
               if (verify_image = 1) then begin
                  verify_image := 0;
                  ...
                  send captcha code
                  ...
                  Exit;
               end;
               }
               for i:=0 to FChatters.ChatterCount-1 do
               begin
                  if Assigned(OnChatUserJoin) then
                  begin
                    FOnChatUserJoin(Self, room, topic, FChatters.Chatter[i]);
                  end;
               end;
            end; // who
          end; // firstjoin
        end;
      YAHOO_SERVICE_CHATEXIT:
        begin
          if Assigned(OnChatUserLeave) then
            FOnChatUserLeave(Self, room, who)
        end; 
      YAHOO_SERVICE_COMMENT:
        begin
          if Assigned(OnChatMessage) then
            FOnChatMessage(Self, who, room, msg, msgtype);
        end;

    end; // for


  end; // with


end;

procedure TYMSG.LeaveChatRoom;
begin
  if FState = ymsSignedOut then
    Exit;

  with FPSend do begin
    Header.Service := YAHOO_SERVICE_CHATLOGOUT;
    Header.Status := YPACKET_STATUS_DEFAULT;
    Clear;
    Add(1, FYID);
    Add(1005, '12345678');
  end;
  SendPacket(FPSend);
end;

end.
