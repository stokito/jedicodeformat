{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is IndentUsesClause.pas, released April 2000.
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

unit IndentUsesClause;

{ AFS 21 March 2000
  indent uses & exports clause
}

interface

uses TokenType, Token, Indenter;

type 
  TIndentUsesClause = class(TIndenter)
  private

  protected
    function GetIsEnabled: boolean; override;
    function GetDesiredIndent(const pt: TToken): integer; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public

  end;

implementation


uses WordMap;

{ TIndentUsesClause }

function TIndentUsesClause.GetDesiredIndent(const pt: TToken): integer;
begin
  if pt.Word in [wUses, wExports] then
    Result := 0
  else
  begin
    Result := 1;
    { run-on line }
    if (pt.TokenType <> ttWord) then
      inc(Result);
  end;

  Result := Settings.Indent.SpacesForIndentLevel(Result);
end;

function TIndentUsesClause.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Indent.IndentGlobals;
end;

function TIndentUsesClause.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);

  { only indent uses & exports }
  if lcNext.InUsesClause or lcNext.InExports then
  begin
    if (lcNext.FirstTokenOnLine) and (lcNext.TokenType <> ttComment) then
      IndentToken(pt, lcNext);
  end;
end;

end.