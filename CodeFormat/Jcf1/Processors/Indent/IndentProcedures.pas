{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is IndentProcedures.pas, released April 2000.
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

unit IndentProcedures;

{ AFS 2 Dec 1999
  indentation of procedure header and body

 }
interface

uses TokenType, Token, Indenter;

type

  TIndentProcedures = class(TIndenter)
  private
    function IsInProc(const pt: TToken): boolean;
    function NeedsIndent(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function GetDesiredIndent(const pt: TToken): integer; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public

  end;

implementation

uses
    { local}  WordMap;

{ TIndentProcedures }
function TIndentProcedures.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Indent.IndentProcedures;
end;

function TIndentProcedures.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);

  { only indent procedures & functions here
    initialization section also qualifies }
  if NeedsIndent(lcNext) then
    IndentToken(pt, lcNext);
end;


{ this logic is used in 2 places }
function IndentProcedureBody(const pt: TToken): integer;
begin
  { it's basically NestingLevel ie nubmer or times begin has been used, but
    - nested procedures are indented more.
    - case blocks are indented more }
  Result := pt.NestingLevel + (pt.ProcedureNestingLevel - 1);

  { end of block word is still inside the block }
  if pt.Word in (OutdentWords + [wExcept, wFinally]) then
    dec(Result);

  { lines that start with '(' as in a object type cast are too far in }
  if (pt.TokenType = ttOpenBracket) and (not pt.RHSAnything) then
    dec(Result);

  { run-on line  }
  if pt.IsRunOnLine then
    inc(Result);
end;

function TIndentProcedures.GetDesiredIndent(const pt: TToken): integer;
begin
  case pt.ProcedureSection of
    psProcedureBody:
    begin
      Result := IndentProcedureBody(pt);
    end;
    psProcedureDefinition, psProcedureDirectives:
    begin
      { indent the procedure/fn def line }
      Result := pt.ProcedureNestingLevel;
      { params can run on - note that the nesting level is
       already incremented if this is not a forward def }

      if not (pt.Word in ProcedureWords) and (pt.ProcedureNestingLevel = 0) then
        Inc(Result);
    end;
    psProcedureDeclarations:
    begin
      { indent the procedure's vars and consts }
      Result := pt.ProcedureNestingLevel;
      if pt.Word in Declarations then
        dec(Result);

      { can run on }
      if pt.IsRunOnLine and (pt.RecordCount = 0) then
        Inc(Result);
      Result := Result + pt.RecordCount;
      Result := Result + pt.RecordCases;
      if (pt.RecordCases > 0) and (pt.Word = wCase) then
        Dec(result);
    end;
    else
      Result := 0;
  end;

  Result := Settings.Indent.SpacesForIndentLevel(Result);

  { indent internal begin/ends by a few spaces ? }
  if (pt.Word in [wBegin, wEnd]) and (Result > 0) then
  begin
    if Settings.Indent.IndentBeginEnd then
      Result := Result +  Settings.Indent.IndentBeginEndSpaces;
  end;

end;

function TIndentProcedures.IsInProc(const pt: TToken): boolean;
begin
  { in a procedure (excluding a proc def in a class) }
  Result := ((pt.ProcedureSection <> psNotInProcedure) and
    (pt.StructuredType = stNotInStructuredType));

  if Result then
    Result := not pt.InProcedureTypeDeclaration;
end;

function TIndentProcedures.NeedsIndent(const pt: TToken): boolean;
begin
  Result := False;

  if not IsInProc(pt) then
    exit;

  if not  pt.FirstTokenOnLine then
    exit;

  // indent comments ?
  if (pt.TokenType = ttComment) then
  begin
    Result := pt.IsSingleLineComment and Settings.Indent.KeepCommentsWithCodeInProcs;
    exit;
  end;

  // if we get here it was good
  Result := True;
end;

end.