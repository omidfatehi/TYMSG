//
// Original code httpsendthread.pas by Theo Lustenberger
//
// Contacts: devi[dot]mandiri[at]gmail[dot]com

{
  saat menggunakan 'https' sering muncul pesan
  'SSL/TLS support is not compiled!' di LastErrorDesc

  sedikit modifikasi di unit httpsend.pas untuk menghindari pesan tersebut

  constructor THTTPSend.Create;
  begin
  inherited Create;
  ...
  FSock := TTCPBlockSocket.Create;
  ...
  ...

  ganti dengan
  FSock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);

}

unit httpsynapse;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes, blcksock, httpsend, synautil, jsURLParser;

const
  //HTTP Response codes

  HTTPRESP_NORESP = -1;
  //2**  Success
  HTTPRESP_OK = 200;
  HTTPRESP_Created = 201;
  HTTPRESP_Accepted = 202;
  HTTPRESP_Partial_Information = 203;
  HTTPRESP_No_Response = 204;

  //3**   Redirection
  HTTPRESP_Moved = 301;
  HTTPRESP_Found = 302;
  HTTPRESP_Method = 303;
  HTTPRESP_Not_Modified = 304;

  //4**   Client Error
  HTTPRESP_Bad_Request = 400;
  HTTPRESP_Unauthorized = 401;
  HTTPRESP_Payment_Required = 402;
  HTTPRESP_Forbidden = 403;
  HTTPRESP_Not_found = 404;
  HTTPRESP_No_such_group = 411;

  //5**   Server Error
  HTTPRESP_Internal_Error = 500;
  HTTPRESP_Not_implemented = 501;
  HTTPRESP_Timed_out = 502;

  //METHOD STRINGS
  HTTPMETHOD_GET = 'GET';
  //HTTPMETHOD_HEAD = 'HEAD';
  HTTPMETHOD_POST = 'POST';

{
  SocketReasonStrings: array[0..13] of string = ('ResolvingBegin',
    'ResolvingEnd', 'SocketCreate', 'SocketClose',
    'Bind', 'Connect', 'CanRead', 'CanWrite', 'Listen',
    'Accept', 'ReadCount', 'WriteCount', 'Wait', 'Error');
}
type
  THTTPClient=class;

  THTTPRedirectEvent = procedure(Sender: TObject; URL: string) of object;

  TCustomHTTPSend=class(THTTPSend)
  private
    fRedirectMax: integer;
    fOnRedirect: THTTPRedirectEvent;
    fOnStatus: THookSocketStatus;
    fTotallyRead: integer;
    fHeaderSize: integer;
    fConnected:Boolean;
    procedure DoAfterConnect(Sender:TObject);
  public
    constructor Create;
    destructor Destroy; override;
    function HTTPMethod(const Method, URL: string): Boolean;
    procedure Status(Sender: TObject; Reason: THookSocketReason; const Value: string);
  published
    property RedirectMax: integer read fRedirectMax write fRedirectMax;
    property OnRedirect: THTTPRedirectEvent read fOnRedirect write fOnRedirect;
    property OnStatus: THookSocketStatus read FOnStatus write FOnStatus;
    property Connected: Boolean read fConnected write fConnected;
  end;

  THTTPThread=class(TThread)
  private
    fOwner:THTTPClient;
    fHTTP: TCustomHTTPSend;
    fMethod,
    fHeader,
    fContent,
    fURL,
    fURLData,
    fErrorMsg,
    fRedirect:string;

    // progress
    fCurrent,fTotal,
    fPosition:integer;

    fResultCode:integer;
    fStreamData:TStream;
  protected
    procedure Execute;override;
    procedure Status(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure Redirected(Sender: TObject; URL: string);
    procedure SyncAfterDisconnect;
    procedure SyncOnError;
    procedure SyncOnContent;
    procedure SyncOnBinary;
    procedure SyncOnRedirect;
    procedure SyncOnProgress;
  public
    constructor Create(AOwner:THTTPClient);
    destructor Destroy;override;
    procedure SoftAbort;
    procedure HardAbort;
    property URL: string read fURL write fURL;
    property URLMethod:string read fMethod write fMethod;
    property URLData:string read fURLData write fURLData;
  end;

  THTTPErrorEvent = procedure(Sender:TObject; ErrorMsg:string;
      ErrorCode:integer) of object;
  THTTPContentEvent = procedure(Sender:TObject;Header:string;
      Document:string; ResultCode:integer) of object;
  THTTPBinaryEvent = procedure(Sender:TObject; BinaryData:TStream;
      ResultCode:integer) of object;
  THTTPProgressEvent = procedure(Sender:TObject; CurrentSize:integer;
      TotalSize:integer; Position:integer) of object;

  THTTPClient=class
  private
    fHTTP:THTTPThread;
    fOnError:THTTPErrorEvent;
    fOnContent:THTTPContentEvent;
    fOnBinary:THTTPBinaryEvent;
    fOnRedirect:THTTPRedirectEvent;
    fOnProgress:THTTPProgressEvent;
    procedure ThreadTerminated(Sender: TObject);
  public
    constructor Create;
    destructor Destroy;override;    
    procedure HTTPGet(URL:string);
    procedure HTTPPost(URL:string;URLData:string); // not tested yet :)
    procedure HTTPAbort;

    property OnError:THTTPErrorEvent read fOnError write fOnError;
    property OnContent:THTTPContentEvent read fOnContent write fOnContent;
    property OnBinaryData:THTTPBinaryEvent read fOnBinary write fOnBinary;
    property OnRedirect:THTTPRedirectEvent read fOnRedirect write fOnRedirect;
    property OnProgress:THTTPProgressEvent read fOnProgress write fOnProgress;
  end;

function FormatByteSize(const bytes: Longint): string;
  
implementation

uses Math;

//Format file byte size
function FormatByteSize(const bytes: Longint): string;
const
  B = 1; //byte
  KB = 1024 * B; //kilobyte
  MB = 1024 * KB; //megabyte
  GB = 1024 * MB; //gigabyte
begin
  if bytes > GB then
    result := FormatFloat('#.## GB', bytes / GB)
  else
    if bytes > MB then
      result := FormatFloat('#.## MB', bytes / MB)
    else
      if bytes > KB then
        result := FormatFloat('#.## KB', bytes / KB)
      else
        result := FormatFloat('#.## bytes', bytes) ;
end;

{ TCustomHTTPSend }

constructor TCustomHTTPSend.Create;
begin
  inherited;
  fRedirectMax := 10;
  fConnected := False;
  Sock.OnStatus := Status;
  Sock.OnAfterConnect := DoAfterConnect;
end;

destructor TCustomHTTPSend.Destroy;
begin
  inherited;
end;

procedure TCustomHTTPSend.DoAfterConnect(Sender: TObject);
begin
  fConnected := True;
end;

function TCustomHTTPSend.HTTPMethod(const Method,
  URL: string): Boolean;
var i: integer;
  RedirURL, BaseURL: string;
  URLParser: TjsURLParser;
begin
  fHeaderSize := 0;
  fTotallyRead := 0;

  //We need this for relative URLs later
  URLParser := TjsURLParser.Create;
  URLParser.Parse(URL);
  BaseURL := URLParser.GetBaseURL;
  URLParser.free;

  Result := inherited HTTPMethod(Method, URL);
  if Result then
    for i := 0 to FRedirectMax do
    begin
      if (ResultCode < HTTPRESP_Moved) or (ResultCode > HTTPRESP_Method) and
        (ResultCode <> HTTPRESP_No_such_group) then break else
      begin
        //we have a redirect
        HeadersToList(Headers);
        RedirURL := Trim(Headers.Values['location']);
        if RedirURL = '' then
        begin
          Result := false;
          break;
        end;

        URLParser := TjsURLParser.Create;
        URLParser.Parse(RedirURL);
        if URLParser.RelativeURL then //we have a relative URL for redirection
          RedirURL := URLParser.CombineURL(BaseURL);
        URLParser.free;

        if Assigned(fOnRedirect) then fOnRedirect(Self, RedirURL);
        Clear;
        fHeaderSize := 0;
        fTotallyRead := 0;
        Result := inherited HTTPMethod(Method, RedirURL);

        URLParser := TjsURLParser.Create;
        URLParser.Parse(RedirURL);
        BaseURL := URLParser.GetBaseURL;
        URLParser.free;

        if i = FRedirectMax then result := false;
      end;
    end;
end;

procedure TCustomHTTPSend.Status(Sender: TObject;
  Reason: THookSocketReason; const Value: string);
var val: string;
begin
  if Reason = HR_ReadCount then
  begin
    inc(fTotallyRead, StrToIntDef(value, 0)); //sum up the readcounts
    val := Inttostr(fTotallyRead);
    if Headers.Count > 0 then //Assume the Header comes in one chunk
    begin
      if fHeaderSize = 0 then //now it's time to decrease fTotallyRead by Header Size:
      begin
        fHeaderSize := Length(AdjustLineBreaks(Headers.Text, tlbsCRLF));
        Dec(fTotallyRead, fHeaderSize);
        val := Inttostr(fTotallyRead);
      end;
    end else fHeaderSize := 0;
  end else val := Value;

  {if you want to see what's going on, uncomment the following line
   Make sure you have a console (Linker Tab in Delphi) }

  //writeln(SocketReasonStrings[Ord(Reason)],':',Value);

  if Assigned(fOnStatus) then OnStatus(Sender, Reason, Val);
end;


{ THTTPThread }

constructor THTTPThread.Create(AOwner: THTTPClient);
begin
  inherited Create(True);
  fOwner := AOwner;
  fHTTP := TCustomHTTPSend.Create;
  fHTTP.OnRedirect := Redirected;
  fHTTP.OnStatus := Status;
end;

destructor THTTPThread.Destroy;
begin
  {if fHTTP<>nil then }fHTTP.free;
  inherited;
end;

procedure THTTPThread.Execute;
var
  conttype,err: string;
  StriLi:TStringList;
begin
  if (fURL<>'') then
  begin
    if (fMethod=HTTPMETHOD_POST) then begin
      WriteStrToStream(fHTTP.Document,fURLData);
      fHTTP.MimeType := 'application/x-www-form-urlencoded';
    end;
    if fHTTP.HTTPMethod(fMethod, fURL) then
    begin
      HeadersToList(fHTTP.Headers);
      fHeader := fHTTP.Headers.Text;
      fResultCode := fHTTP.ResultCode;
      err := '';
      case fResultCode of
        HTTPRESP_Bad_Request: err := 'Bad request';
        HTTPRESP_Unauthorized: err := 'Unauthorized';
        HTTPRESP_Payment_Required: err := 'Payment required';
        HTTPRESP_Forbidden: err := 'Forbidden';
        HTTPRESP_Not_found: err := 'Not found';
        //HTTPRESP_No_such_group = 411;
        HTTPRESP_Internal_Error: err := 'Internal error';
        HTTPRESP_Not_implemented: err := 'Not implemented';
        HTTPRESP_Timed_out: err := 'Timed out';
      end;

      if (err<>'') then begin
        fErrorMsg := err;
        Synchronize(SyncOnError);
        //GUIMessage(mtError,fHTTP.Headers.Text,err,nil,fHTTP.ResultCode);
        Exit;
      end;

      conttype := LowerCase(Trim(fHTTP.Headers.Values['Content-Type']));
      if (pos('text/html', conttype) > 0) or (pos('text/plain', conttype) > 0) then
      begin
        StriLi:=TStringList.Create;
        try
          Strili.LoadFromStream(fHTTP.Document);
          fContent := StriLi.Text;
          Synchronize(SyncOnContent);
          //GUIMessage(mtContent, fHttp.Headers.Text, StriLi.text, nil, fHTTP.ResultCode);
        finally
          StriLi.free;
        end;
      end else begin
        fStreamData := fHTTP.Document;
        Synchronize(SyncOnBinary);
        //GUIMessage(mtBinary, fHttp.Headers.Text, 'Binary Data',
          //fHTTP.Document, fHTTP.ResultCode);
      end;
    end;
  end;
end;

procedure THTTPThread.Redirected(Sender: TObject; URL: string);
begin
  if not Terminated then
  begin
    fRedirect := URL;
    Synchronize(SyncOnRedirect);
    //GUIMessage(mtRedirected, '', URL, nil, 0);
  end;
end;

procedure THTTPThread.HardAbort;
begin
  SoftAbort;
  FreeAndNil(fHTTP);
end;

procedure THTTPThread.SoftAbort;
begin
  Terminate;
  fHTTP.Abort; //sets the stop flag
end;

procedure THTTPThread.Status(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
var
  val: integer;
  desc: string;
begin
  if not Terminated then
  begin
    case Reason of
      HR_ReadCount:
        begin
          fCurrent := StrToIntDef(Value,0);
          fTotal := fHTTP.DownloadSize;
          fPosition := 0;
          if fTotal>0 then
            fPosition := Min(100, Round(fCurrent * 100 / fTotal));
          Synchronize(SyncOnProgress);
          //GUIMessage(mtProgress, '', Value, nil, fHTTP.DownloadSize);
        end;
      HR_Error,HR_SocketClose:
        begin
          if fHTTP.Connected then
            Synchronize(SyncAfterDisconnect)
          else begin
            if Length(Value)>0 then begin
              val := StrToIntDef(SeparateLeft(Value, ','), 0);
              desc := SeparateRight(Value, ',');
              if val <> 104 then begin
                fErrorMsg := desc;
                fResultCode := val;
                Synchronize(SyncOnError);
                //GUIMessage(mtError, '', desc, nil, val);
              end;
            end;
          end;
        end;
    end;
  end;
end;

procedure THTTPThread.SyncAfterDisconnect;
begin
  fHTTP.Connected := False;
end;

procedure THTTPThread.SyncOnError;
begin
  if Assigned(fOwner.OnError) then
    fOwner.fOnError(fOwner,fErrorMsg,fResultCode);
end;

procedure THTTPThread.SyncOnContent;
begin
  if Assigned(fOwner.OnContent) then
    fOwner.fOnContent(fOwner,fHeader,fContent,fResultCode);
end;

procedure THTTPThread.SyncOnBinary;
begin
  if Assigned(fOwner.OnBinaryData) then
    fOwner.fOnBinary(fOwner,fStreamData,fResultCode);
end;

procedure THTTPThread.SyncOnRedirect;
begin
  if Assigned(fOwner.OnRedirect) then
    fOwner.fOnRedirect(fOwner,fRedirect);
end;

procedure THTTPThread.SyncOnProgress;
begin
  if Assigned(fOwner.OnProgress) then
    fOwner.fOnProgress(fOwner,fCurrent,fTotal,fPosition);
end;

{ THTTPClient }

constructor THTTPClient.Create;
begin
  inherited;
end;

destructor THTTPClient.Destroy;
begin
  HTTPAbort;
  inherited;
end;

procedure THTTPClient.HTTPAbort;
begin
  try
    if fHTTP <> nil then
    begin
      fHTTP.SoftAbort;
      Sleep(2000); //give SoftAbort a chance
    end;
    if fHTTP <> nil then fHTTP.HardAbort;
  except
  //
  end;
end;

procedure THTTPClient.HTTPGet(URL: string);
begin
  if (URL='') then Exit;
  fHTTP := THTTPThread.Create(Self);
  fHTTP.OnTerminate := ThreadTerminated;
  fHTTP.URLMethod := HTTPMETHOD_GET;
  fHTTP.URL := URL;
  fHTTP.FreeOnTerminate := true;
  fHTTP.Resume;
end;

procedure THTTPClient.HTTPPost(URL, URLData: string);
begin
  if (URL='') or (URLData='') then
    Exit;
  fHTTP := THTTPThread.Create(Self);
  fHTTP.OnTerminate := ThreadTerminated;
  fHTTP.URLMethod := HTTPMETHOD_POST;
  fHTTP.URL := URL;
  fHTTP.URLData := URLData;
  fHTTP.FreeOnTerminate := true;
  fHTTP.Resume;
end;

procedure THTTPClient.ThreadTerminated(Sender: TObject);
begin
  fHTTP := nil;
end;

end.
