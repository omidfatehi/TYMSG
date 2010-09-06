unit jsURLParser;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
//Basis in http://www.jazarsoft.com/product.php?pid=0030040014
//Viele Bugfixes und Erweiterungen 2005 Theo Lustenberger

interface
uses
{$IFDEF LINUX}
  SysUtils, Classes, Types {, QDialogs};
{$ELSE}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;
{$ENDIF}

const StandardHTMLExtensions: array[0..4] of ShortString =
  ('htm', 'html', 'asp', 'php', 'cfm');
const StandardImageExtensions: array[0..4] of ShortString =
  ('gif', 'jpg', 'jpeg', 'png', 'bmp');

type
  TjsURLParser = class(TObject)

  protected
    function ParseURL(URL: string):Boolean;
    procedure ParsePath;
  public
    { Parse URL stuff }
    Mail: Boolean;
    Address: string;

    JavaScript:Boolean;

    RelativeURL: Boolean;
    LocalFile: Boolean; { those with file:// }

    Protocol,
      Username,
      Password,
      Hostname,
      Port,
      URLPath: string;

    { Parse Path stuff }
    RootDir: Boolean;
    GoToUpper: Integer;
    Directory: string;

    Filename: string;
    Query: string;
    Bookmark: string;

    OrigURL: string;

    procedure Parse(URL: string);

    function GetBaseURL: string; // Only Available Parse(URL:String) calling
    function GetFileExt: string;
    function GetIsHTMLFile: boolean;
    function GetIsImageFile: boolean;
    function CombineURL(BaseURL: string): string;
  end;


implementation

function CopyBuffer(StartIndex: PChar; Length: Integer): string;
var
  S: string;
begin
  SetLength(S, Length);
  StrLCopy(@S[1], StartIndex, Length);
  Result := S;
end;

function ReplaceAllChars(S: string; find, replace: Char): string; //Theo
var
  i, leno: integer;
begin
  leno := length(S);
  for i := 1 to leno do
    if S[i] = find then S[i] := replace;
  result := S;
end;

{ Syntax of an URL: protocol://[user[:password]@]server[:port]/path         }

function TjsURLParser.ParseURL(URL: string):Boolean;
var
  I,
    Start,
    P: Pchar;
    Temp:Pchar; //Theo
  Ln,
    L: DWORD;

begin
  Result:=True;
  //Theo
  OrigURL := URL;

  if Length(URL) > 1 then
    if (URL[1] = '.') and (URL[2] = '/') then
    begin
      URL := Copy(URL, 3, Length(URL));
    end;

  Protocol := '';
  Username := '';
  Password := '';
  Hostname := '';
  Port := '';
  URLPath := '';
  Address := '';

  Mail := False;
  JavaScript:=False;
  RelativeURL := False;
  LocalFile := False;

  P := Pchar(URL);
  L := StrLen(P);
  if L = 0 then exit;

  { Get the Protocol }
  I := StrPos(P, '://');
  if I <> nil then
  begin
    { contains protocol:// }
    Protocol := CopyBuffer(P, I - P);
    if Lowercase(Protocol) = 'file' then
      LocalFile := True;

    P := I + 3;
  end else
  begin
    if Lowercase(CopyBuffer(P, 7)) = 'mailto:' then
    begin
      { mailto:someone@somwhere.com }
      Mail := True;
      Protocol := 'mailto';
      Inc(P, 7);
      Address := CopyBuffer(P, L - 7);
      Result:=false;
      exit;
    end else



    if Lowercase(CopyBuffer(P, 11)) = 'javascript:' then
    begin
      { javascript:openWin('test') }
      JavaScript := True;
      Protocol := 'javascript';
      //Inc(P, 11);
      //Address := CopyBuffer(P, L - 11);
      Result:=false;
      exit;
    end else

      if P^ = '/' then
      begin
        { Relative path to root directory, no protocol }
        Protocol := 'http';
        URLPath := CopyBuffer(P, L);
        RelativeURL := True;
        exit; { Done here }
      end else

      begin
        { Relative to current directory, no protocol ( ../a/b/c.gif or a/b/c.gif ) }
        Protocol := 'http';
        RelativeURL := True;
        URLPath := CopyBuffer(P, L);
        exit; { Done here }
      end;
  end;

  if not LocalFile then
  begin
    { Get Username, Password, Server & Port }
    I := StrPos(P, '@');
    Temp:= StrPos(P,'/');

    //theo: for http://www.admin.ch/cp/d/42414bbc_1@fwsrvg.html
    if (I <> nil) and ((Temp <> nil) and (Temp > I)) then  //theo
    begin
      { Username & Password supplied }
      Start := P;
      while not (P^ in [':', #0]) do Inc(P);
      Ln := P - Start;
      if Ln > 0 then
        Username := CopyBuffer(Start, Ln);
      Inc(P); { Skip ':' }

      Start := P;
      while not (P^ in ['@', #0]) do Inc(P);
      Ln := P - Start;
      if Ln > 0 then
        Password := CopyBuffer(Start, Ln);
      Inc(P); { Skip '@' }
    end;

    Start := P;
    while not (P^ in [':', '/', #0]) do Inc(P);
    Ln := P - Start;
    if Ln > 0 then
      Hostname := ReplaceAllChars(CopyBuffer(Start, Ln), ',', '.');

    if P^ = ':' then
    begin
      { Port supplied }
      Inc(P); { Skip ':' }
      Start := P;
      while not (P^ in ['/', #0]) do Inc(P);
      Ln := P - Start;
      if Ln > 0 then
        Port := CopyBuffer(Start, Ln);
    end;

  end;

  { Get Path }
  Start := P;
  while not (P^ in [#0]) do Inc(P);
  Ln := P - Start;
  if Ln > 0 then
    URLPath := CopyBuffer(Start, Ln);
end;

procedure TjsURLParser.ParsePath;
var
  Start,
    P,
    I: Pchar;
  Ln,
    L: DWORD;
begin
  P := Pchar(URLPath);
  L := StrLen(P);

  Directory := '';
  Query := '';
  Bookmark := '';
  Filename := '';
  GoToUpper := 0;
  if (L <= 1) then
  begin
    { Root directory }
    RootDir := True;
    Directory := '';
    Exit;
  end else
    if (StrPos(P, '/') <> nil) then
    begin
      while (CopyBuffer(P, 2) = '..') do
      begin
        Inc(GoToUpper); Inc(P, 3);
      end;

      { Get Directory Name }
      I := StrRScan(P, '/');
      Start := P;

      if i = nil then
      begin
        i := P;
      end;

      Ln := I - Start;
      if Ln > 0 then
        Directory := CopyBuffer(Start, Ln);
      P := I;

      if P^ = '/' then
        Inc(P); { Skip '/' }

      { Get the filename }
      Start := P;
      while not (P^ in ['?', '#', #0]) do Inc(P);
      Ln := P - Start;
      if Ln > 0 then
        Filename := CopyBuffer(Start, Ln);

      if P^ = '?' then
      begin
        { Query supplied }
        Inc(P); { Skip '?' }

        Start := P;
        while not (P^ in ['#', #0]) do Inc(P);
        Ln := P - Start;
        if Ln > 0 then
          Query := CopyBuffer(Start, Ln);
      end;

      if P^ = '#' then
      begin
        Inc(P);
        Start := P;
        while not (P^ in ['#', #0]) do Inc(P);
        Ln := P - Start;
        if Ln > 0 then
          Bookmark := CopyBuffer(Start, Ln);
      end;

    end else
      { No directory, just the filename [+query] }
      if (StrPos(P, '/') = nil) then
      begin
        { Get the filename }
        Start := P;
        while not (P^ in ['?', '#', #0]) do Inc(P);
        Ln := P - Start;
        if Ln > 0 then
          Filename := CopyBuffer(Start, Ln);

        if P^ = '?' then
        begin
          { Query supplied }
          Inc(P); { Skip '?' }

          Start := P;
          while not (P^ in ['#', #0]) do Inc(P);
          Ln := P - Start;
          if Ln > 0 then
            Query := CopyBuffer(Start, Ln);
        end;

        if P^ = '#' then
        begin
          Inc(P);
          Start := P;
          while not (P^ in ['#', #0]) do Inc(P);
          Ln := P - Start;
          if Ln > 0 then
            Bookmark := CopyBuffer(Start, Ln);
        end;

      end;

end;

function TjsURLParser.GetBaseURL: string;
var
  BaseURL: string;
begin
  { Build Base URL }
  BaseURL := Protocol + '://';
  if (Username <> '') and (Password <> '') then
    BaseURL := BaseURL + Username + ':' + Password + '@';

  if not LocalFile then
  begin
    if HostName = '' then
    begin
      Result := '';
      Exit; //Theo
    end;
    BaseURL := BaseURL + Hostname;
  end;

  if (Port <> '') then
    BaseURL := BaseURL + ':' + Port;

  if (Directory = '') then
  begin
    BaseURL := BaseURL + '/';
  end else
  begin
    if (Directory[1] = '/') then
      BaseURL := BaseURL + Directory + '/' else
      BaseURL := BaseURL + '/' + Directory;
  end;
  Result := BaseURL; //Theo
end;

function TjsURLParser.CombineURL(BaseURL: string): string;
var
  P,
    I: Pchar;
  C: DWORD;
begin
  IF BaseURL<>'' then  //theo
  begin
  P := Pchar(BaseURL);

  if GoToUpper <> 0 then
  begin
    I := StrEnd(P);
    Dec(I); { Skip NULL Teriminator }
    if I^ = '/' then Dec(I);

    C := GoToUpper;

    while C > 0 do
    begin
      while not (I^ in ['/']) do Dec(I);
      Dec(C);
      {
        Scenario: "../../../../test.zip" combined to "http://www.acme.com/a/b"
        Returns : "http://www.acme/test.zip"
      }
      if ((I - P) < 8) then { only left, 'http://', (error?), try to find hostname end }
      begin
        Inc(I); while not (I^ in ['/']) do Inc(I);
        Break;
      end;
      if C > 0 then Dec(I); { Skip '/' }

    end;
    if Directory <> '' then //theo
      Result := CopyBuffer(P, I - P) + '/' + Directory else
      Result := CopyBuffer(P, I - P);
  end else
  begin
    if ((Directory <> '') and (Directory[1] = '/')) or ((OrigURL[1] = '/') and (Directory = '')) then
    begin
      { Relative to root directory e.g : /haha/hihi.txt }
      I := StrPos(P, '://');
      Inc(I, 3);
      while not (I^ in ['/', #0]) do Inc(I);
      Result := CopyBuffer(P, I - P) + Directory;
    end else
      if (Directory <> '') and (Directory[1] <> '/') then
      begin
        { Relative to current directory }
        Result := BaseURL + Directory;
      end else
        if (Directory = '') then
        begin
          Result := BaseURL;
          if Result[Length(Result)] = '/' then
            Delete(Result, Length(Result), 1);
        end;

  end;

  if Filename <> '' then
    Result := Result + '/' + Filename;
  if Query <> '' then
    Result := Result + '?' + Query;
  if Bookmark <> '' then
    Result := Result + '#' + Bookmark;
  end else Result:='';  
end;

function TjsURLParser.GetFileExt: string;
begin
  if FileName <> '' then Result := ExtractFileExt(FileName) else Result := '';
end;

function TjsURLParser.GetIsHTMLFile: boolean;
var FE: string;
  i: integer;
begin
  FE := LowerCase(GetFileExt);
  if (FE <> '') and (FE[1] = '.') then FE := Copy(FE, 2, Length(FE));
  Result := False;

  for i := 0 to High(StandardHTMLExtensions) do
    if FE = StandardHTMLExtensions[i] then
    begin
      Result := True;
      Exit;
    end;
end;

function TjsURLParser.GetIsImageFile: boolean;
var FE: string;
  i: integer;
begin
  FE := LowerCase(GetFileExt);
  if (FE <> '') and (FE[1] = '.') then FE := Copy(FE, 2, Length(FE));
  Result := False;

  for i := 0 to High(StandardImageExtensions) do
    if FE = StandardImageExtensions[i] then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TjsURLParser.Parse(URL: string);
begin
if ParseURL(URL) then ParsePath;
end;

end.
