{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SingleSpaceAfter.pas, released April 2000.
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

unit SingleSpaceAfter;

{ AFS 9 Dec 1999
  Single space after : }

interface

uses TokenType, Token, TokenSource;

type

  TSingleSpaceAfter = class(TBufferedTokenProcessor)
  private
    procedure SingleSpaceNext;
    function NeedsSingleSpace(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses
  { jcl } JclStrings,
  { local } WordMap, FormatFlags;

{ TSingleSpaceAfter }

const
  SingleSpaceAfterTokens: TTokenTypeSet = [ttColon, ttAssign, ttComma];
  SingleSpaceAfterWords: TWordSet       = [wProcedure, wFunction,
    wConstructor, wDestructor, wProperty,
    wOf, wDo, wWhile, wUntil, wCase, wIf, wTo, wDownTo,

    // some unary operators
    wNot,
    // all operators that are always binary
    wAnd, wAs, wDiv, wIn, wIs, wMod, wOr, wShl, wShr, wXor,
    wTimes, wFloatDiv, wEquals, wGreaterThan, wLessThan,
    wGreaterThanOrEqual, wLessThanOrEqual, wNotEqual];

  PossiblyUnaryOperators: TWordSet = [wPlus, wMinus];


constructor TSingleSpaceAfter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddSpace, eRemoveSpace, eRemoveReturn];
end;

function TSingleSpaceAfter.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.FixSpacing;
end;

function TSingleSpaceAfter.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := NeedsSingleSpace(pt);
end;

function TSingleSpaceAfter.OnProcessToken(const pt: TToken): TToken;
begin
  SingleSpaceNext;
  Result := pt;
end;

function TSingleSpaceAfter.NeedsSingleSpace(const pt: TToken): boolean;
var
  ptNext: TToken;
begin
  Result := False;

  ptNext := FirstSolidToken;
  // if the next token is a comment, leave it where it is, do not adjust spacing
  if ptNext.TokenType = ttComment then
    exit;

  { semciolon as a record field seperator in a const record declaration
   has no newline (See ReturnAfter.pas), just a single space }
  if (pt.TokenType = ttSemiColon) and (pt.IsSeparatorSemiColon) then
  begin
    Result := True;
    exit;
  end;

  { semicolon  in param list }
  if (pt.TokenType = ttSemiColon) and (pt.ProcedureSection = psProcedureDefinition) and
    (pt.Bracketlevel = 1) then
  begin
    Result := True;
    exit;
  end;

  { semicolon in param lists in proc type def. bit of a hack }
  if (pt.TokenType = ttSemiColon) and (pt.DeclarationSection = dsType) and
    (pt.RHSEquals) and (pt.Bracketlevel = 1) then
  begin
    Result := True;
    exit;
  end;

  if (pt.TokenType in SingleSpaceAfterTokens) then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word in SingleSpaceAfterWords) then
  begin
    Result := True;
    exit;
  end;

  { + or - but only if it is a binary operator, ie a term to the left of it }
  if (pt.Word in PossiblyUnaryOperators) and (pt.RHSOperand) then
  begin
    Result := True;
    exit;
  end;

  { only if it actually is a directive, sse TestCases/TestBogusDirectivves for details }
  if (pt.IsDirective) then
  begin
    Result := True;
    exit;
  end;

  if pt.Word = wEquals then
  begin
    Result := True;
    exit;
  end;

  { 'in' in the uses clause }
  if (pt.Word = wIn) and (pt.InUsesClause) then
  begin
    Result := True;
    exit;
  end;

  { const or var as parameter var types }
  if (pt.Word in ParamTypes) and (pt.ProcedureSection = psProcedureDefinition) and
    (pt.BracketLevel > 0) then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word in ParamTypes) and pt.InPropertyDefinition and
    (pt.SquareBracketLevel > 0) then
  begin
    Result := True;
    exit;
  end;

  { single space before class heritage ?
    see NoSpaceAfter }
  if (pt.DeclarationSection = dsType) and (pt.Word in ObjectTypeWords) and
    (Settings.Spaces.SpaceBeforeClassHeritage) then
  begin
    if (ptNext.TokenType in [ttOpenBracket, ttSemiColon]) then
    begin
      Result := True;
      exit;
    end;
  end;
end;

procedure TSingleSpaceAfter.SingleSpaceNext;
var
  fcNext, fcNew: TToken;
  liIndex: integer;
begin
  { exclude if a comment is next }
  liIndex := 0;
  fcNext := GetBufferTokenWithExclusions(liIndex, [ttWhiteSpace, ttReturn]);
  if fcNext.TokenType = ttComment then
    exit;

  { inspect the next token }
  fcNext := BufferTokens(0);
  if fcNext.TokenType = ttWhiteSpace then
  begin
    fcNext.SourceCode := AnsiSpace;
  end
  else if (fcNext.TokenType <> ttReturn) then
  begin
    // insert a space
    fcNew := TToken.Create;
    fcNew.TokenType := ttWhiteSpace;
    fcNew.SourceCode := AnsiSpace;
    AddTokenToFrontOfBuffer(fcNew);
  end;
end;

end.