{
  Original code: TYMsgCore - http://sourceforge.net/projects/tymsgcore
  Author: Hamid_PaK [PRAISER] - praiser_man@yahoo.com

  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YMsgCore;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

// uncomment this line if you want vcl
//{$DEFINE KOMPONEN}

interface

uses
  SysUtils, Classes, ExtCtrls, httpsynapse,
  YMsgSock, YMsgConst, YMsgPckt, YBuddyList;

type
  TYMSGStatusEvent = type TTCPEvent;
  TOnBuddyStatusUpdate = procedure(Sender: TObject; Buddy: TYBuddy) of object;
  TOnBuddySignedOut = procedure(Sender: TObject; Buddy: TYBuddy) of object;
  TOnInstantMessage = procedure(Sender: TObject; From: TYBuddy;
      BuddyID, MsgTxt: String; IsOffline: Boolean) of object;
  TOnAddRequest = procedure(Sender: TObject; From: String; var MsgTxt: String;
      var Accept: Boolean) of object;
  TOnNewEmail = procedure(Sender: TObject; EmailCount: Integer) of object;
  TOnBuddyPicture = procedure(Sender: TObject; Buddy: TYBuddy;
      BuddyID, ImageUrl: String; ImageType: TYBImage) of object;
  TOnDataPacketParsed = procedure(Sender: TObject; DataPacket: TYMsgPacket) of object;
  TOnBuddyList = procedure(Sender: TObject; Buddies: TYBuddyGroupList) of object;
  TOnStatus = procedure(Sender: TObject; State: TYMsgCoreState) of object;
  TOnBuddyTyping = procedure(Sender: TObject; From: string; Stop: Boolean) of object;

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
    FOnReceiveIMessage: TOnInstantMessage;
    FOnAddRequest: TOnAddRequest;
    FOnNewEmail: TOnNewEmail;
    FOnBuddyPicture: TOnBuddyPicture;
    FOnDataPacketParsed: TOnDataPacketParsed;
    FOnBuddyList: TOnBuddyList;
    FOnTyping: TOnBuddyTyping;

    procedure SockError(Sender:TObject;Value:string);
    procedure SockConnected(Sender:TObject);
    procedure SockDisconnected(Sender:TObject);
    procedure SockData(Sender:TObject;Buffer:TMemory;Len:integer);

    procedure HTTPError(Sender:TObject;ErrMsg:string;ErrorCode:integer);
    procedure HTTPContent(Sender:TObject;Header,Document:string;ResulCode:integer);

    procedure DoError(ErrorMsg:string);
    procedure DoStatus(AState:TYMsgCoreState);

    function  SplitePacket(Buffer: PChar; Len: Integer): Integer;
    procedure ParseData(DataPacket: TYMsgPacket);
    procedure DoInitAuthentication(ADataPacket: TYMsgPacket);
    procedure DoInitLogin(ADataPacket: TYMsgPacket);
    procedure DoParseList(ADataPacket: TYMsgPacket);
    procedure DoStatusY7(ADataPacket: TYMsgPacket);
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
  public
    constructor Create{$IFDEF KOMPONEN}(AOwner: TComponent);override{$ENDIF};
    destructor Destroy;override;
    procedure Login;
    procedure Logout;

    procedure AddBuddy(ABuddyID, AddToGroup: String; RequestMessage: String = '');
    procedure RemoveBuddy(ABuddy, AddToGroup: String);
    procedure SendInstantMessage(ToUser, AMessage: String);
    procedure SendTyping(ToUser: String; Stop: Boolean = False);
    procedure SetStatus(AStatus: TYStatus;
      CustomMsg: String = ''; CustomBusy: Boolean = False);
    procedure IgnoreBuddy(ABuddyID:string);
    procedure UnignoreBuddy(ABuddyID:string);

    procedure SendPacket(ADataPacket: TYMsgPacket);

  published
    property Host:string read FHost write FHost;
    property Port:string read FPort write FPort;
    property YahooID:string read FYID write FYID;
    property Password:string read FPWD write FPWD;

    property OnStatus: TOnStatus read FOnStatus write FOnStatus;
    property OnError: TYMSGStatusEvent read FOnError write FOnError;
    property OnBuddyStatusUpdate: TOnBuddyStatusUpdate read FOnBuddyStatusUpdate write FOnBuddyStatusUpdate;
    property OnBuddySignedOut:  TOnBuddySignedOut read FOnBuddySignedOut write FOnBuddySignedOut;
    property OnReceiveIMessage: TOnInstantMessage read FOnReceiveIMessage write FOnReceiveIMessage;
    property OnAddRequest: TOnAddRequest read FOnAddRequest write FOnAddRequest;
    property OnNewEmail: TOnNewEmail read FOnNewEmail write FOnNewEmail;
    property OnDataPacketParsed: TOnDataPacketParsed read FOnDataPacketParsed write FOnDataPacketParsed;
    property OnBuddyList: TOnBuddyList read FOnBuddyList write FOnBuddyList;
    property OnBuddyTyping: TOnBuddyTyping read FOnTyping write FOnTyping;
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

  FHost := 'scs.msg.yahoo.com';
  FPort := '5050';

  FState := ymsSignedOut;
  FPSend := TYMsgPacket.Create;
  FPRecv := TYMsgPacket.Create;
  FBuddies := TYBuddyGroupList.Create(TYBuddyGroup);

  FPing := TTimer.Create(nil);
  FPing.OnTimer := DoPing;
  FPing.Interval := 100000;

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

procedure TYMSG.Login;
begin
  if sock.IsConnected or
    (FState<>ymsSignedOut) then
    Exit;

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
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_LOGOFF;
    Header.Status := YAHOO_STATUS_AVAILABLE;
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
    //if Assigned(FOnDataParse) then
      //FOnDataParse(Self, p, parsed);
    if (not parsed) then begin
      case DataPacket.Header.Service of
        YAHOO_SERVICE_VERIFY: DoInitAuthentication(DataPacket);
        YAHOO_SERVICE_AUTH: DoInitLogin(DataPacket);
        YAHOO_SERVICE_AUTHRESP: DoInitLogin(DataPacket);
        YAHOO_SERVICE_LIST: DoStatus(ymsSignedIn);
        YAHOO_SERVICE_Y7LIST: DoParseList(DataPacket);
        YAHOO_SERVICE_LOGON,YAHOO_SERVICE_Y7LOGON: DoStatusY7(DataPacket);
        YAHOO_SERVICE_LOGOFF: DoLogOff(DataPacket);
        YAHOO_SERVICE_MESSAGE: DoReceiveMessage(DataPacket);
        YAHOO_SERVICE_ADDBUDDY: DoAddBuddy(DataPacket);
        YAHOO_SERVICE_REMBUDDY: DoRemBuddy(DataPacket);
        YAHOO_SERVICE_NEWMAIL: DoNewEmail(DataPacket);
        YAHOO_SERVICE_Y7BUDDYAUTH: DoAddRequest(DataPacket);
	      YAHOO_SERVICE_USERSTAT,
	      //YAHOO_SERVICE_LOGOFF,
	      YAHOO_SERVICE_ISAWAY,
	      YAHOO_SERVICE_ISBACK,
	      YAHOO_SERVICE_GAMELOGON,
	      YAHOO_SERVICE_GAMELOGOFF,
	      YAHOO_SERVICE_IDACT,
	      YAHOO_SERVICE_IDDEACT,
	      YAHOO_SERVICE_Y6STATUS: DoProcessStatus(DataPacket);

        YAHOO_SERVICE_NOTIFY: DoProcessNotify(DataPacket);

        YAHOO_SERVICE_PICTURE: DoPicture(DataPacket);

      end;
      if Assigned(FOnDataPacketParsed) then
        FOnDataPacketParsed(Self, DataPacket);
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
    // is this work ?
    idx := YAHOO_LOGIN_SERVER;
    if (IndexOf(66) >= 0) then
      idx := StrToIntDef(Datas[IndexOf(66)].Value, 1);
    case idx of
      YAHOO_LOGIN_OK: yid := 'Accout is OK';
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
        Add(135,'9.0.0.2162');
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

procedure TYMSG.DoParseList(ADataPacket: TYMsgPacket);
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

procedure TYMSG.DoStatusY7(ADataPacket: TYMsgPacket);
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
    if Assigned(FOnBuddyStatusUpdate) then
      FOnBuddyStatusUpdate(Self, budd);
end;

procedure TYMSG.DoLogOff(ADataPacket: TYMsgPacket);
var
  bud: TYBuddy;
begin
  if Assigned(FOnBuddySignedOut) then
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
  i, x: Integer;
  txt: String;
  bud: TYBuddy;
begin
  if Assigned(FOnReceiveIMessage) then
  with ADataPacket do begin
    if
      (Header.Status = YAHOO_MESSAGE_UNKNOWN) or
      (Header.Status = YAHOO_MESSAGE_AWAY)
    then Exit;

    if
      (IndexOf(4) >= 0) and
      (IndexOf(14) >= 0)
    then
    repeat
      i := IndexOf(14);
      bud := nil;
      txt := UTF8Decode(Datas[i].Value);
      if (FBuddies.FindYID(Datas[IndexOf(4)].Value, bud)) then
        FOnReceiveIMessage(Self, bud, Datas[IndexOf(4)].Value, txt, Header.Status = YAHOO_MESSAGE_OFFLINE) else
        FOnReceiveIMessage(Self, nil, Datas[IndexOf(4)].Value, txt, Header.Status = YAHOO_MESSAGE_OFFLINE);
      for x := i downto 0 do Delete(x);
    until (IndexOf(14) < 0);
  end;
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

      if Assigned(FOnAddRequest) then
        FOnAddRequest(Self, from, msg, accpet);

      pckt := TYMsgPacket.Create;
      with pckt do
      try
        Header.Service := YAHOO_SERVICE_Y7BUDDYAUTH;
        Header.Status := YAHOO_STATUS_AVAILABLE;
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
  if Assigned(FOnNewEmail) then
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
  if Assigned(FOnBuddyPicture) then
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
        FPSend.Header.Status := YAHOO_STATUS_AVAILABLE;
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
    pckt.Header.Status := YAHOO_STATUS_AVAILABLE;
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
    Header.Status := YAHOO_STATUS_AVAILABLE;
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
    Header.Status := YAHOO_STATUS_AVAILABLE;
    Clear;
    Add(1, FYID);
    Add(7, ABuddy);
    Add(65, AddToGroup);
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.SendInstantMessage(ToUser, AMessage: String);
var
  bud: TYBuddy;
begin
  if (FState<>ymsSignedIn) or (ToUser='') or (AMessage='') then
    Exit;

  with FPSend do begin
    Header.Service := YAHOO_SERVICE_MESSAGE;
    if (FBuddies.FindYID(ToUser, bud)) then begin
      if (bud.State = ysOffline) then
        Header.Status := YAHOO_STATUS_OFFLINE else
        Header.Status := YAHOO_STATUS_AVAILABLE;
    end else
      Header.Status := YAHOO_STATUS_WEBLOGIN;
    Clear;
    Add(0, FYID);
    Add(1, FYID);
    Add(5, ToUser);
    Add(14, UTF8Encode(AMessage));
    Add(97, '1');
    Add(63, ';0');
    Add(64, '0');
  end;
  SendPacket(FPSend);

end;

procedure TYMSG.SendTyping(ToUser: String; Stop: Boolean);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_NOTIFY;
    Header.Status := YAHOO_STATUS_TYPING;
    Clear;
    Add(49, 'TYPING');
    Add(1, FYID);
    Add(14, ' ');
    Add(13, IntToStr(Integer((not Stop))));
    Add(5, ToUser);                        
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.SetStatus(AStatus: TYStatus; CustomMsg: String;
  CustomBusy: Boolean);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_ISAWAY;
    Header.Status := Integer(AStatus);
    Clear;
    Add(10, IntToStr(Integer(AStatus)));
    if (AStatus = ysCustom) and (Length(CustomMsg) > 0) then begin
      Add(19, UTF8Encode(CustomMsg));
      Add(47, IntToStr(Integer(CustomBusy)));
    end;
  end;
  SendPacket(FPSend);
end;

procedure TYMSG.IgnoreBuddy(ABuddyID: string);
begin
  if (FState<>ymsSignedIn) then
    Exit;
  with FPSend do begin
    Header.Service := YAHOO_SERVICE_IGNORECONTACT;
    Header.Status := YAHOO_STATUS_AVAILABLE;
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
    Header.Status := YAHOO_STATUS_AVAILABLE;
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
  pair:TYMsgPacketData;
begin
  with ADataPacket do begin
    if (IndexOf(16)>0) or
      (Datas[IndexOf(49)].Value='') then
      Exit;
    
    aFrom := Datas[IndexOf(4)].Value;
    aTo   := Datas[IndexOf(5)].Value;
    aMsg  := Datas[IndexOf(49)].Value;
    stat  := StrToBoolDef(Datas[13].Value,False);    
    aInd  := Datas[IndexOf(14)].Value;
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

end.