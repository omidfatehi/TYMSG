{
  Original code: TYMsgCore - http://sourceforge.net/projects/tymsgcore
  Author: Hamid_PaK [PRAISER] - praiser_man@yahoo.com

  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YMsgPckt;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Classes, Sysutils, YMsgConst;

type
  TYPacketHead = array[0..3] of Char;

  TYMsgPacketHeader = class(TPersistent)
  private
    FName: TYPacketHead;
    FVersion: DWord;
    FLength: Word;
    FService: Word;
    FStatus: DWord;
    FSessionID: DWord;
  public
    constructor Create;

    property Name: TYPacketHead read FName;
    property Version: DWORD read FVersion write FVersion;
    property Length: Word read FLength write FLength;
    property Service: Word read FService write FService;
    property Status: DWORD read FStatus write FStatus;
    property SessionID: DWORD read FSessionID write FSessionID;
  end;

  TYMsgPacketData = class(TPersistent)
  private
    FKey: Word;
    FValue: String;
  public
    property Key: Word read FKey write FKey;
    property Value: String read FValue write FValue;
  end;

  TYMsgPacket = class(TPersistent)
  private
    FHead: TYMsgPacketHeader;
    FPckts: TList;
    function GetCount: Integer;
    function GetItem(Idx: Integer): TYMsgPacketData;
    function Reverse(Value: DWORD; Len: Integer): DWORD;  
    function DataEncode(Buffer: PChar): Integer;
    function DataDecode(Data: PChar; Len: Integer): Integer;
    procedure SetItem(Idx: Integer; Value: TYMsgPacketData);
  public
    constructor Create;
    destructor Destroy; override;

    property Header: TYMsgPacketHeader read FHead write FHead;
    property Datas[Index: Integer]: TYMsgPacketData read GetItem write SetItem;
    property DataCount: Integer read GetCount;

    function Add: TYMsgPacketData; overload;
    function Read(Buffer: PChar): Integer;
    function Write(DataPacket: PChar; DataLen: Integer): Integer;
    function IndexOf(AKey: Word): Integer;
    procedure Add(AKey: Word; AValue: String); overload;
    procedure Clear;
    procedure Delete(Idx: Integer);
    procedure Assign(Source: TPersistent); override;
    procedure AddDatas(Packet: TYMsgPacket);
    procedure CopyHead(AHead: TYMsgPacketHeader);
  end;

implementation

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: DWORD);
begin
  Move(Source^, Destination^, Length);
end;

function HexToInt(value: String): Integer;
var
  I : Integer;
begin
  Result := 0;
  I := 1;
  if Value = '' then Exit;
  if Value[ 1 ] = '$' then Inc( I );
  while I <= Length( Value ) do
  begin
    if Value[ I ] in [ '0'..'9' ] then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('0'))
    else
    if Value[ I ] in [ 'A'..'F' ] then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('A') + 10)
    else
    if Value[ I ] in [ 'a'..'f' ] then
       Result := (Result shl 4) or (Ord(Value[I]) - Ord('a') + 10)
    else
      break;
    Inc( I );
  end;
end;

constructor TYMsgPacketHeader.Create;
begin
  inherited Create;
  FName := YAHOO_PROTOCOL_SIGN;
  FVersion := YAHOO_PROTO_VERSION;
  FSessionID := $00000000;
end;

function TYMsgPacket.Add: TYMsgPacketData;
var
  idx: Integer;
begin
  idx := FPckts.Add( Pointer( TYMsgPacketData.Create ));
  Result := TYMsgPacketData( FPckts[ idx ]);
end;

procedure TYMsgPacket.Add(AKey: Word; AValue: String);
begin
  with Add do begin
    Key := AKey;
    Value := AValue;
  end;
end;

procedure TYMsgPacket.Clear;
begin
  FPckts.Clear;
end;

constructor TYMsgPacket.Create;
begin
  inherited Create;
  FHead := TYMsgPacketHeader.Create;
  FPckts := TList.Create;
end;

destructor TYMsgPacket.Destroy;
begin
  FPckts.Free;
  FHead.Free;
  inherited Destroy;
end;

function TYMsgPacket.GetCount: Integer;
begin
  Result := FPckts.Count;
end;

function TYMsgPacket.GetItem(Idx: Integer): TYMsgPacketData;
begin
  Result := TYMsgPacketData( FPckts.Items[ Idx ] );
end;

procedure TYMsgPacket.Delete(Idx: Integer);
begin
  FPckts.Delete( idx );
end;

procedure TYMsgPacket.SetItem(Idx: Integer; Value: TYMsgPacketData);
begin
  FPckts[ Idx ] := Pointer( Value );
end;

function TYMsgPacket.Read(Buffer: PChar): Integer;
var
  h: TYMsgPHRec;
begin
  FillChar(h, SizeOf(h), 0);
  Result := DataEncode(Buffer +SizeOf(h));

  h.Name := YAHOO_PROTOCOL_SIGN;
  h.Version := Reverse(YAHOO_PROTO_VERSION, 4);
  h.Length := Reverse(Result, 4);
  h.Service := Reverse(FHead.Service, 4);
  h.Status := Reverse(FHead.Status, 8);
  h.SessionID := Reverse(FHead.SessionID, 8);
  
  CopyMemory(Buffer, @h, SizeOf(h));
  Inc(Result, SizeOf(h));
end;

function TYMsgPacket.Write(DataPacket: PChar; DataLen: Integer): Integer;
var
  h: TYMsgPHRec;
begin
  Result := 0;
  CopyMemory(@h, DataPacket, SizeOf(TYMsgPHRec));

  if (h.Name <> YAHOO_PROTOCOL_SIGN) then begin
    Result := -1;
    Exit;
  end;

  FHead.Version := Reverse(h.Version, 4);
  FHead.Length := Reverse(h.Length, 4);
  FHead.Service := Reverse(h.Service, 4);
  FHead.Status := Reverse(h.Status, 8);
  FHead.SessionID := Reverse(h.SessionID, 8);
  Inc(DataPacket, SizeOf(TYMsgPHRec));
  Inc(Result, SizeOf(TYMsgPHRec));
  if (FHead.Length > 0) then
    Inc(Result, DataDecode(DataPacket, DataLen)) else Clear;
end;

function TYMsgPacket.Reverse(Value: DWord; Len: Integer): DWord;
var
  i: Integer;
  c, d, h: String;
begin
  c := IntToHex(Value, Len);
  i := Length( c );
  h := '';
  repeat
    Dec(i, 2);
    d := Copy(c, i +1, 2);
    h := h +d;
  until (i <= 0);
  Result := HexToInt( h );
end;

function TYMsgPacket.DataDecode(Data: PChar; Len: Integer): Integer;
var
  k: Integer;
  s: String;
  p, start: PChar;
begin
  Clear;
  p := Data;
  if (Len > 0) then
  repeat
    start := Data;
    while (Data[0]+Data[1] <> YAHOO_C080) do begin
      Inc(Data);
      if (Data^ = #0) or (Data -p >= Len) then Break;
    end;
    SetString(s, start, Data -start);
    if (Data^ = #0) or (s = '') then Break;
    k := StrToIntDef(s, 0);
    Inc( Data, 2 );

    start := Data;
    while (Data[0]+Data[1] <> YAHOO_C080) do begin
      Inc(Data);
      if (Data^ = #0) or (Data -p >= Len) then Break;
    end;
    SetString(s, start, Data -start);
    Inc( Data, 2 );

    Add(k, s);
  until (Data^ = #0) or (Data -p >= Len);
  Result := Data -p;
end;

function TYMsgPacket.DataEncode(Buffer: PChar): Integer;
var
  i: Integer;
  s: String;
begin
  Result := 0;
  for i := 0 to DataCount -1 do
  with Datas[ i ] do begin
    s := IntToStr( Key ) +YAHOO_C080+ Value +YAHOO_C080;
    StrCat(Buffer, PChar( s ));
    Inc(Result, Length(s));
  end;
end;

function TYMsgPacket.IndexOf(AKey: Word): Integer;
begin
  for Result := 0 to DataCount -1 do
  if Datas[ Result ].Key = AKey then Exit;
  Result := -1;
end;

procedure TYMsgPacket.Assign(Source: TPersistent);
begin
  if Source is TYMsgPacket then begin
    try
      CopyHead(TYMsgPacket(Source).FHead);
      AddDatas(TYMsgPacket(Source));
    finally
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TYMsgPacket.CopyHead(AHead: TYMsgPacketHeader);
begin
  Self.FHead.FName := AHead.FName;
  Self.FHead.FVersion := AHead.FVersion;
  Self.FHead.FLength := AHead.FLength;
  Self.FHead.FService := AHead.FService;
  Self.FHead.FStatus := AHead.FStatus;
  Self.FHead.FSessionID := AHead.FSessionID;
end;

procedure TYMsgPacket.AddDatas(Packet: TYMsgPacket);
var
  i: Integer;
begin
  for i := 0 to Packet.DataCount -1 do
    with Self.Add do begin
      FKey := Packet.Datas[ i ].FKey;
      FValue := Packet.Datas[ i ].FValue;
    end;
end;

end.
