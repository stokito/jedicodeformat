{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SpecificWordCaps.pas, released April 2000.
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

unit SpecificWordCaps;


{ AFS 7 Dec 1999
  - fix capitalisation on specified words

 }
interface

uses TokenType, Token, TokenSource;

type

  TSpecificWordCaps = class(TTokenProcessor)
  private
    fiCount: integer;
    lsLastChange: string;

    function Excluded(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pc: TToken): TToken; override;
  public
    constructor Create; override;

    procedure OnRunStart; override;
    procedure FinalSummary; override;

  end;

implementation

uses
  { delphi } SysUtils, // debug Dialogs,
  { local } FormatFlags;

constructor TSpecificWordCaps.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eCapsSpecificWord];
  fiCount     := 0;
end;


procedure TSpecificWordCaps.OnRunStart;
begin
  inherited;
  fiCount      := 0;
  lsLastChange := '';
  // debug ShowMessage('Reset');
end;

function TSpecificWordCaps.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.SpecificWordCaps.Enabled;
end;

function TSpecificWordCaps.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType in TextualTokens);
end;


function TSpecificWordCaps.OnProcessToken(const pc: TToken): TToken;
var
  lsChange: string;
begin
  Result := pc;

  if Excluded(pc) then
    exit;

  if Settings.SpecificWordCaps.HasWord(pc.SourceCode) then
  begin
    // get the fixed version
    lsChange := Settings.SpecificWordCaps.FixWord(pc.SourceCode);

    // case-sensitive test - see if anything to do.
    if AnsiCompareStr(pc.SourceCode, lsChange) <> 0 then
    begin
      lsLastChange  := pc.SourceCode + ' - ' + lsChange;
      pc.SourceCode := lsChange;
      inc(fiCount);
    end;
  end;
end;

procedure TSpecificWordCaps.FinalSummary;
var
  lsMsg: string;
begin
  if fiCount > 0 then
  begin
    if fiCount = 1 then
      lsMsg := 'One change was made: ' + lsLastChange
    else
      lsMsg := IntToStr(fiCount) + ' changes were made';

    Log.LogMessage('Specific word caps: ' + lsMsg);
  end;
end;

function TSpecificWordCaps.Excluded(const pt: TToken): boolean;
begin
  Result := False;

  { directives in context are excluded }
  if pt.IsDirective then
  begin
    Result := True;
    exit;
  end;

  { built in types that are actually being used as types are excluded
    eg.
    // this use of 'integer' is definitly the type
    var li: integer;

    // this use is definitely not
    function Integer(const ps: string): integer;

    // this use is ambigous
    li := Integer(SomeVar);

   user defined types are things that we often *want* to set a specific caps on
   so they are not covered }

  if (pt.TokenType = ttBuiltInType) and (pt.DeclarationSection = dsVar) and
    (pt.RHSColon) then
  begin
    Result := True;
    exit;
  end;
end;

end.
