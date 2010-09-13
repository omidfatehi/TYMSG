{
  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YChatList;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Sysutils, Classes, YMsgConst;

type
  TYChat = class(TCollectionItem)
  private
    FYID: string;
    FAge: integer;
    FAttribs: integer;
    FAlias: string;
    FLocation: string;
  public
    property YID: String read FYID write FYID;
    property Age: Integer read FAge write FAge;
    property Attribs: integer read FAttribs write FAttribs;
    property Alias: string read FAlias write FAlias;
    property Location: string read FLocation write FLocation;
  end;

  TYChatList = class(TCollection)
  private
    FRName: String;
    function GetItem(Idx: Integer): TYChat;
    procedure SetItem(Idx: Integer; Value: TYChat);
  public
    property Items[Index: Integer]: TYChat read GetItem write SetItem;
    property RoomName: string read FRName write FRName;

    function Add: TYChat; overload;
    function Add(AYID: String): TYChat; overload;
    function Insert(Idx: Integer): TYChat;
    function FindYID(YahooID: String; var Rslt: TYChat): Boolean;
  end;

{
  TYChatRoom = class(TCollectionItem)
  private
    FRoomName: String;
    FChatList: TYChatList;
  public
    property Chatters: TYChatList read FChatList write FChatList;
    property RoomName: String read FRoomName;
  end;  

  TYChatRoomList = class(TCollection)
  private
    function GetItem(Idx: Integer): TYChatRoom;
    procedure SetItem(Idx: Integer; Value: TYChatRoom);
  public
    property Rooms[Index: Integer]: TYChatRoom read GetItem write SetItem;

    function Add(ARoomName: String): TYChatRoom;
    function Insert(Idx: Integer): TYChatRoom;
    function FindRoom(ARoomName: String): Integer;
    function FindYID(YahooID: String; var Rslt: TYChat): Boolean;
  end;
}
implementation

{ TYChatList }

function TYChatList.Add: TYChat;
begin
  Result := TYChat(inherited Add);
end;

function TYChatList.Add(AYID: String): TYChat;
begin
  Result := Add;
  with Result do begin
    FYID := AYID;
  end;
end;

function TYChatList.FindYID(YahooID: String; var Rslt: TYChat): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count -1 do begin
    if (LowerCase(Items[i].FYID) = LowerCase(YahooID)) then
    begin
      Rslt := Items[i];
      Result := True;
      Exit;
    end;
  end;
end;

function TYChatList.GetItem(Idx: Integer): TYChat;
begin
  Result := TYChat(inherited Items[Idx]);
end;

function TYChatList.Insert(Idx: Integer): TYChat;
begin
  Result := TYChat(inherited Insert(Idx));
end;

procedure TYChatList.SetItem(Idx: Integer; Value: TYChat);
begin
  inherited Items[Idx] := Value;
end;

{ TYChatRoomList }
{
function TYChatRoomList.Add(ARoomName: String): TYChatRoom;
begin
  Result := TYChatRoom(inherited Add);
  with Result do begin
    FChatList := TYChatList.Create(TYChat);
    FChatList.FRName := ARoomName;
    FRoomName := ARoomName;
  end;
end;

function TYChatRoomList.FindRoom(ARoomName: String): Integer;
begin
  for Result := 0 to Count -1 do
    if (Rooms[Result].FRoomName = ARoomName) then Exit;
  Result := -1;
end;

function TYChatRoomList.FindYID(YahooID: String;
  var Rslt: TYChat): Boolean;
var
  i,x: Integer;
begin
  Result := False;
  for i := 0 to Count -1 do begin
    for x := 0 to Rooms[i].Chatters.Count -1 do begin
      if (LowerCase(Rooms[i].Chatters.Items[x].FYID) = LowerCase(YahooID)) then begin
        Rslt := Rooms[i].Chatters.Items[x];
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TYChatRoomList.GetItem(Idx: Integer): TYChatRoom;
begin
  Result := TYChatRoom(inherited Items[idx]);
end;

function TYChatRoomList.Insert(Idx: Integer): TYChatRoom;
begin
  Result := TYChatRoom(inherited Insert(Idx));
end;

procedure TYChatRoomList.SetItem(Idx: Integer; Value: TYChatRoom);
begin
  inherited Items[Idx] := Value;
end;
}
end.
