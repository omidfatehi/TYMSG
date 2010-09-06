program ymsgpas;

{$mode objfpc}{$H+}
{$IFDEF UNIX}
{$DEFINE UseCThreads}
{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms
  { you can add units after this }, mainunit, LResources;

begin
  Application.Title:='YMsgPas - Yahoo! Messenger Client written with Pascal';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

