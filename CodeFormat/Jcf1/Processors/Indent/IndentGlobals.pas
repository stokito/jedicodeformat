{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is IndentGlobals.pas, released April 2000.
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

unit IndentGlobals;

{ AFS 18 Feb 2000
  indent global vars
}

interface

uses TokenType, Token, Indenter;

type 
  TIndentGlobals = class(TIndenter)
  private
    function NeedsIndent(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
    function GetDesiredIndent(const pt: TToken): integer; override;
  public

  end;

implementation

uses WordMap;

{ TIndentGlobals }

function TIndentGlobals.GetDesiredIndent(const pt: TToken): integer;
begin
  { 'type', 'var', 'const' etc are flush left except when var, const etc are param types }
  if (pt.Word in ParamTypes) and (pt.BracketLevel >  0) and pt.RHSEquals then
    Result := 2
  else if pt.Word in Declarations then
    Result := 0
  // 'implementation' etc. also
  else if pt.Word in SectionWords then
    Result := 0
  // end. also
  else if (pt.Word = wEnd) and (pt.NestingLevel = 0) then
    Result := 0
  else
  begin
    Result := 1;

    { not sure which style is more standard
      - one indent per bracket level, or
       just a single indent of the stuff in any level of brackets
       I am currently using the latter.

    Result := Result + pt.BracketLevel + pt.SquareBracketLevel;
    if pt.TokenType in BracketTokens then
      Dec(Result);
    }

    {
    if ((pt.BracketLevel > 0) or (pt.SquareBracketLevel > 0)) and not
      (pt.TokenType in BracketTokens) then
        inc(Result);
    }
    if pt.IsRunOnLine and (pt.RecordCount = 0) then
        Inc(Result);
  end;

  Result := Result + pt.RecordCount;

  Result := Settings.Indent.SpacesForIndentLevel(Result);
end;

function TIndentGlobals.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Indent.IndentGlobals;
end;

function TIndentGlobals.NeedsIndent(const pt: TToken): boolean;
begin
  Result := False;

  if not (pt.FirstTokenOnLine) then
    exit;

  if pt.DeclarationSection = dsNotInDeclaration then
    exit;

  if pt.ProcedureSection <> psNotInProcedure then
    exit;

  if pt.StructuredType <> stNotInStructuredType then
    exit;

  // indent comments?
  if (pt.TokenType = ttComment) then
  begin
    Result := pt.IsSingleLineComment and Settings.Indent.KeepCommentsWithCodeInGlobals;
    exit;
  end;

  Result := True;
end;

function TIndentGlobals.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);

  { only indent global vars, const etc. here
   do not indent comments
   do not indent structured types }
  if NeedsIndent(lcNext) then
    IndentToken(pt, lcNext);
end;

end.