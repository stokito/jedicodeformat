{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is IndentClassDef.pas, released April 2000.
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

unit IndentClassDef;

{ AFS 18 Feb 2000
  indent class Definitions
  also does interface and record def bodies

  this is now gettting hacked to shreds
}

interface

uses TokenType, Token, Indenter;

type 
  TIndentClassDef = class(TIndenter)
  private
    fbLastTokenInType: boolean;

    function NeedsIndent(const pt: TToken): Boolean;
  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
    function GetDesiredIndent(const pt: TToken): integer; override;
  public
    procedure OnFileStart; override;

  end;

implementation

uses WordMap;

{ TIndentClassDef }

procedure TIndentClassDef.OnFileStart;
begin
  inherited;
  fbLastTokenInType := False;
end;


function RunOnDef(const pt: TToken): boolean;
begin
  Result := False;

  if pt.TokenType = ttComment then
    exit;

  if (pt.ProcedureSection in [psProcedureDefinition, psProcedureDirectives])
    and not (pt.Word in ProcedureWords) then
  begin
    Result := True;
    exit;
  end;

  if (pt.ProcedureSection in [psProcedureDefinition]) and (pt.Word in ProcedureWords) and
    (pt.ClassFunction) then
  begin
    Result := True;
    exit;
  end;

  if pt.InPropertyDefinition and not (pt.Word = wProperty) then
  begin
    Result := True;
    exit;
  end;
end;

function TIndentClassDef.GetDesiredIndent(const pt: TToken): integer;
begin
  Result := 1;

  Result := Result + pt.BracketLevel;

  if not pt.IsClassDirective then
  begin
    { line run-on: directive as first token on line indicates something before it,
      being inside brackets indicates a run-on parameter list  }

    if (pt.BracketLevel = 0) and RunOnDef(pt) then
      inc(Result);

    if pt.NestingLevel > 0 then
      Result := Result + pt.NestingLevel;


    { end of brackets indented to match the open }
    if pt.TokenType in CloseBrackets then
      Dec(Result);

    if pt.Word = wEnd then
      Dec(Result);
  end;

  Result := Settings.Indent.SpacesForIndentLevel(Result);
end;

function TIndentClassDef.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Indent.IndentClasses;
end;

function TIndentClassDef.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);

  if NeedsIndent(lcNext) then
      IndentToken(pt, lcNext);
end;

function TIndentClassDef.NeedsIndent(const pt: TToken): Boolean;
var
  lbLast: boolean;
begin
  Result := False;

  if pt.TokenType in [ttWhiteSpace, ttReturn] then
    exit;

  { only indent global type defs here }
  lbLast := (pt.StructuredType in [stClass, stInterface, stRecord]);

  // catch tokens in structured types and the trailing end
  if lbLast or (fbLastTokenInType and (pt.Word = wEnd)) then
  begin
    if (pt.FirstTokenOnLine) then
    begin
      if (pt.TokenType = ttComment) then
        Result := pt.IsSingleLineComment and Settings.Indent.KeepCommentsWithCodeInClassDef
      else
        Result := True;
    end;
  end;

  fbLastTokenInType := lbLast;
end;

end.