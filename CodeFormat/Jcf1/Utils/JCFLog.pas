{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Log.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele. 

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations 
under the License.
------------------------------------------------------------------------------*)
{*)}

unit JCFLog;

{ Created AFS 2 Dec 1999

  Log file }

interface

uses
    { local } JCFSettings, SetLog;

type 
  TLog = class(TObject)
  private
    fSettings: TSettings;
    fOpen: boolean;

    { worker vars }
    fLog: TextFile;
    { worker procs }
    procedure OpenLog;

  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure LogMessage(const ps: string);
    procedure LogPriorityMessage(const ps: string);

    procedure LogWarning(const ps: string);
    procedure LogError(const ps: string);
    procedure EmptyLine;

    procedure CloseLog;

    property Settings: TSettings read fSettings write fSettings;

  end;

implementation

uses SysUtils;

{ TLog }


procedure TLog.CloseLog;
begin
  if fOpen then
  begin
    Flush(FLog);
    CloseFile(FLog);
    fOpen := False;
  end;
end;

constructor TLog.Create;
begin
  inherited;
  fOpen := False;
end;

destructor TLog.Destroy;
begin
  CloseLog;
  inherited;
end;

procedure TLog.EmptyLine;
begin
  OpenLog;
  WriteLn(Flog, '');
  // no need to flush now - if theprogram dies right here, no new info is lost
end;

{ !!! make this do additional work ?! }
procedure TLog.LogError(const ps: string);
begin
  OpenLog;

  WriteLn(Flog, 'Error: ' + ps);
  Flush(FLog);
end;

procedure TLog.LogMessage(const ps: string);
begin
  if Settings.Log.LogLevel = eLogErrorsOnly then
    exit;
  LogPriorityMessage(ps);
end;

// this one always gets through
procedure TLog.LogPriorityMessage(const ps: string);
begin
  OpenLog;
  WriteLn(Flog, ps);
  Flush(FLog);
end;

procedure TLog.LogWarning(const ps: string);
begin
  OpenLog;

  WriteLn(Flog, 'Warning: ' + ps);
  Flush(FLog);
end;

procedure TLog.OpenLog;
begin
  if not fOpen then
  begin
    Assert(Settings <> nil);
    AssignFile(FLog, Settings.Log.LogFileName);
    Rewrite(FLog);
    fOpen := True;

    { do this no matter what the logging level, unless a log = off level is introduced }
    WriteLn(Flog, 'Logging started at ' + FormatDateTime('dd mmm yyyy hh:mm:ss',
      Date + Time));
  end;
end;

end.
