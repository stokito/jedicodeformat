{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is Converter.pas, released April 2000.
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

unit Converter;

{ AFS 28 Nov 1999
  I don't want the controlling logic to be in a form
  so this class has it

  AFS 11 Jan 2K now a base class - file converter & editor converter are the
  real subclasses
}


interface

uses
    { delphi } Classes,
    { local } ConvertTypes, Reader, Writer, Tokeniser, JCFLog,
  TokenProcessPipeline, JCFSettings;

type

  TConverter = class(TObject)
  private
    fcTokeniser: TTokeniser;

    fcProcess: TTokenProcessPipeline;
    fcLog: TLog;

    { settings }
    fcSettings: TSettings;

    fbYesAll, fbGuiMessages: boolean;

    fOnStatusMessage: TStatusMessageProc;

    procedure SetSettings(const pcValue: TSettings);

  protected
    fbAbort: Boolean;
    fiCount: integer;

    // these are base class refs. this class's child will know what to insantiate
    fcReader: TCodeReader;
    fcWriter: TCodeWriter;

    procedure DoShowMessage(const psMessage: string);
    procedure SendStatusMessage(const ps: string);
    procedure OnFileStart;
    procedure OnFileEnd;
    procedure FinalSummary;
    procedure FlushConverter;

    procedure DoConvertUnit;

    function OriginalFileName: string; virtual;

    { abstract factories called in the constructor. override these }
    function CreateReader: TCodeReader; virtual;
    function CreateWriter: TCodeWriter; virtual;

    property Log: TLog read fcLog;
    property Process: TTokenProcessPipeline read fcProcess;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Convert; virtual;
    procedure Reset;
    procedure OnRunStart;

    property Settings: TSettings read fcSettings write SetSettings;

    property OnStatusMessage: TStatusMessageProc
      read fOnStatusMessage write fOnStatusMessage;

    property YesAll: Boolean read fbYesAll write fbYesAll;
    property GuiMessages: Boolean read fbGuiMessages write fbGuiMessages;
  end;

implementation

uses
    { delphi } Windows, SysUtils, Dialogs, Controls, 
    { local } SetLog;

{ TConverter }



constructor TConverter.Create;
begin
  inherited;

  { state }
  fbGuiMessages := True;
  fbYesAll := False;

  { create owned objects }
  fcReader    := CreateReader;
  Assert(fcReader <> nil);

  fcWriter    := CreateWriter;
  Assert(fcWriter <> nil);

  fcTokeniser := TTokeniser.Create;
  fcLog       := TLog.Create;

  fcProcess     := TTokenProcessPipeline.Create;
  fcProcess.Log := fcLog;
  fcProcess.OnLogWarning := SendStatusMessage;

  { events }
  fcTokeniser.OnGetFileName := OriginalFileName;
  fcProcess.OnGetFileName   := OriginalFileName;

  { wire them together }
  fcTokeniser.Reader := fcReader;
  fcTokeniser.Log    := fcLog;

  fcProcess.Source := fcTokeniser;
  fcWriter.Source  := fcProcess;

  fcSettings := nil;
end;

destructor TConverter.Destroy;
begin
  FreeAndNil(fcReader);
  FreeAndNil(fcWriter);
  FreeAndNil(fcTokeniser);
  FreeAndNil(fcLog);
  FreeAndNil(fcProcess);

  inherited;
end;


procedure TConverter.Convert;
begin
  Assert(False, ClassName + ' Must override TCOnverter.Convert');
end;


function TConverter.OriginalFileName: string;
begin
  Assert(False, ClassName + ' Must override TCOnverter.OriginalFileName');
end;


function TConverter.CreateReader: TCodeReader;
begin
  Assert(False, ClassName + ' Must override TConverter.CreateReader');
  Result := nil;
end;

function TConverter.CreateWriter: TCodeWriter;
begin
  Assert(False, ClassName + ' Must override TCOnverter.CreateWriter');
  Result := nil;
end;

procedure TConverter.SendStatusMessage(const ps: string);
begin
  if Assigned(fOnStatusMessage) then
    fOnStatusMessage(ps);
end;

{ for failures, use console output, not showmessage in gui mode }
procedure TConverter.DoShowMessage(const psMessage: string);
begin
  if fbGuiMessages then
    ShowMessage(psMessage)
  else
    SendStatusMessage(psMessage);
end;


procedure TConverter.FlushConverter;
begin
  fcReader.Clear;
  fcProcess.Flush;
  fcWriter.Close;
end;

procedure TConverter.SetSettings(const pcValue: TSettings);
begin
  fcSettings := pcValue;

  { tell the owned objects about it }
  fcProcess.Settings   := pcValue;
  fcTokeniser.Settings := pcValue;
  fcLog.Settings       := pcValue;
end;

procedure TConverter.FinalSummary;
var
  lsMessage: string;
begin
  if fbAbort then
    lsMessage := 'Aborted after ' + IntToStr(fiCount) + ' files'
  else
    lsMessage := 'Finished processing ' + IntToStr(fiCount) + ' files';

  SendStatusMessage(lsMessage);

  fcTokeniser.FinalSummary;
  fcProcess.FinalSummary;

  fcLog.EmptyLine;
  fcLog.LogPriorityMessage(lsMessage);
end;

procedure TConverter.OnRunStart;
begin
  Assert(fcTokeniser <> nil);
  Assert(fcProcess <> nil);

  fcTokeniser.OnRunStart;
  fcProcess.OnRunStart;
end;

procedure TConverter.OnFileStart;
begin
  Assert(fcTokeniser <> nil);
  Assert(fcProcess <> nil);

  fcTokeniser.OnFileStart;
  fcProcess.OnFileStart;
end;


procedure TConverter.OnFileEnd;
begin
  Assert(fcTokeniser <> nil);
  Assert(fcProcess <> nil);

  fcTokeniser.OnFileEnd;
  fcProcess.OnFileEnd;
end;

procedure TConverter.Reset;
begin
  fbYesAll := False;
end;


procedure TConverter.DoConvertUnit;
begin
  Assert(Settings <> nil);

  try
    fcWriter.Clear;

    OnFileStart;
    fcWriter.WriteAll;
    FlushConverter;
    OnFileEnd;
  except
    on E: Exception do
      SendStatusMessage('Could not convert the unit: ' + E.Message);
  end;
end;

end.