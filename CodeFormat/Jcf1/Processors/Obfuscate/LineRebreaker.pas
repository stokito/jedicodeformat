{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is LineRebreaker.pas, released April 2000.
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

unit LineRebreaker;

{ AFS 24 Dec 1999
 an obfuscator
  - put back some returns
  Break at regular intervals
  irrespective of semantic context
}

interface

uses TokenType, Token, TokenSource;

type

  TLineRebreaker = class(TBufferedTokenProcessor)
  private
    fxPos: integer;
    fbFirstToken: boolean;

  protected

    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public

    procedure OnFileStart; override;

  end;

implementation

uses
    { delphi } SysUtils, Dialogs;

function TLineRebreaker.GetIsEnabled: boolean;
begin
  Result := Settings.Returns.RebreakLines and Settings.Obfuscate.Enabled;
end;

function TLineRebreaker.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType <> ttComment);
end;

function TLineRebreaker.OnProcessToken(const pt: TToken): TToken;
var
  lcNew: TToken;
begin
  { fbFirstToken flag copes with the case where a single token
    (e.g. a string) is longer than the max chars
    when it has been wrapped once onto a new line, to will stay there }

  if pt.TokenType = ttReturn then
  begin
    fxPos  := 1;
    Result := pt;
    fbFirstToken := True;
  end
  else if (fxPos + Length(pt.SourceCode) > Settings.Returns.MaxLineLength) and
    (not fbFirstToken) then
  begin
    lcNew := NewReturnToken;

    pt.IndexOnLine := 1; // now the first token on a line
    AddTokenToFrontOfBuffer(pt);
    Result         := lcNew;
    fxPos          := 0;
    fbFirstToken   := True;
  end
  else
  begin
    fxPos  := fxPos + Length(pt.SourceCode);
    Result := pt;
    if pt.TokenType <> ttWhiteSpace then
      fbFirstToken := False;
  end;
end;

procedure TLineRebreaker.OnFileStart;
begin
  inherited;
  fxPos := 1;
  fbFirstToken := True;
end;

end.