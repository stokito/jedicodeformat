{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Replace.pas, released April 2000.
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

unit Replace;


{ AFS 17 Jan 2k

  - find/replace

 }
interface

uses TokenType, Token, TokenSource;

type

  TReplace = class(TTokenProcessor)
  private
    fiCount: integer;

    procedure FixToken(pct: TToken);

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

    procedure FinalSummary; override;

  end;

implementation

uses
  { delphi } SysUtils,
  { local } FormatFlags;


constructor TReplace.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eFindReplace];
end;

procedure TReplace.FinalSummary;
begin
  if fiCount > 0 then
    Log.LogMessage('Replace: ' + IntToStr(fiCount) + ' changes were made');
end;

procedure TReplace.FixToken(pct: TToken);
begin
  if pct = nil then
    exit;
  if pct.SourceCode = '' then
    exit;

  if not Settings.Replace.HasWord(pct.SourceCode) then
    exit;

  pct.SourceCode := Settings.Replace.Replace(pct.SourceCode);
  inc(fiCount);
end;

function TReplace.OnProcessToken(const pt: TToken): TToken;
begin
  FixToken(pt);
  Result := pt;
end;

function TReplace.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Replace.Enabled;
end;

function TReplace.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttWord);
end;


end.