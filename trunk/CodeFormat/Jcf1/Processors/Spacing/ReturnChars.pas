{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ReturnStyle.pas, released September 2001.
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

unit ReturnChars;

{ AFS 20 September 2001
  What kind of returns do we want }

interface

uses TokenType, Token, TokenSource;

type

  TReturnChars = class(TTokenProcessor)
  private
    fsTarget: string;
    fbInitialised: boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

    procedure OnFileStart; override;
  end;

implementation

uses
 { delphi } SysUtils,
 { jcl } JclStrings,
 { local } FormatFlags, JCFSettings;

constructor TReturnChars.Create;
begin
  inherited;
  fbInitialised := False;
  fsTarget := '';
  FormatFlags := FormatFlags;
end;

function TReturnChars.GetIsEnabled: Boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and
    (Settings.Returns.ReturnChars <> rcLeaveAsIs);
end;

procedure TReturnChars.OnFileStart;
begin
  inherited;
  // reset the local var - setings may have changed
  fsTarget := '';
  fbInitialised := False;
end;

function TReturnChars.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttReturn);
end;

function TReturnChars.OnProcessToken(const pt: TToken): TToken;
var
  ls: string;
begin

  case Settings.Returns.ReturnChars of
    rcLeaveAsIs:
    begin
     // leave as is
    end;
    rcLinefeed:
    begin
      // easy case - replace CrLf with Lf
      ls := pt.SourceCode;
      StrReplace(ls, AnsiCrLf, AnsiCarriageReturn, [rfReplaceAll]);
      pt.SourceCode := ls;
    end;
    rcCrLf:
    begin
      // returns are isolated
      ls := pt.SourceCode;
      if (ls = AnsiLineFeed) or (ls = AnsiCarriageReturn) then
        ls := AnsiCrLf;
      pt.SourceCode := ls;

    end;
  end;

  Result := pt;
end;

end.
