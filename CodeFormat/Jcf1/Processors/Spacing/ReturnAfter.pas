{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ReturnAfter.pas, released April 2000.
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

unit ReturnAfter;

{ AFS Jan 2K
  Some tokens need a return after them for fomatting
}

interface

uses
  TokenType, Token, TokenSource;

type

  TReturnAfter = class(TBufferedTokenProcessor)
  private

    function NeedsReturn(const pt, ptNext: TToken): boolean;
    function NeedsBlankLine(const pt, ptNext: TToken): boolean;

    function SemicolonHasReturn(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

  end;

implementation

uses WordMap, FormatFlags;

const
  WordsJustReturnAfter: TWordSet = [wType, wBegin, wRepeat,
    wTry, wExcept, wFinally, wLabel,
    wInitialization, wFinalization];
  // can't add 'interface' as it has a second meaning :(

  { blank line is 2 returns }
  WordsBlankLineAfter: TWordSet = [wImplementation];

{ TReturnAfter }

constructor TReturnAfter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddReturn];
end;

function TReturnAfter.NeedsReturn(const pt, ptNext: TToken): boolean;
begin
  Result := False;

  if (pt.TokenType in ReservedWordTokens) and (pt.Word in WordsJustReturnAfter) then
  begin
    Result := True;
    exit;
  end;

  if (pt.TokenType = ttSemiColon) then
  begin
    Result := SemicolonHasReturn(pt);
    if Result then
      exit;
  end;

  { var and const when not in procedure parameters or array properties }
  if (pt.Word in [wVar, wThreadVar, wConst, wResourceString]) and
    (pt.BracketLevel = 0) and (pt.SquareBracketLevel = 0) then
  begin
    Result := True;
    exit;
  end;

  { return after else unless there is an in }
  if (pt.Word = wElse) and (ptNext.Word <> wIf) then
  begin
    Result := True;
    exit;
  end;

  { case .. of  }
  if (pt.Word = wOf) and (pt.RHSOfExpressionWord = wCase) then
  begin
    Result := True;
    exit;
  end;

  { end without semicolon or dot, or hint directive }
  if (pt.Word = wEnd) and (not (ptNext.TokenType in [ttSemiColon, ttDot]))  and
    (not (ptNext.Word in HintDirectives)) then
  begin
    Result := True;
    exit;
  end;

  { access specifiying directive (private, public et al) in a class def }
  if (pt.StructuredType = stClass) and pt.IsClassDirective then
  begin
    Result := True;
    exit;
  end;

  { comma in exports clause }
  if (pt.TokenType = ttComma) and pt.InExports then
  begin
    Result := True;
    exit;
  end;

  { comma in uses clause of program or lib - these are 1 per line,
    using the 'in' keyword to specify the file  }
  if (pt.TokenType = ttComma) and pt.InUsesClause and pt.RHSIn then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word = wRecord) and pt.RHSColon then
  begin
    Result := True;
    exit;
  end;

  { end of class heritage }
  if (pt.StructuredType in ObjectTypes) and
    (ptNext.StructuredType = pt.StructuredType) and
    (pt.ClassDefinitionSection in ClassStartSections) and
    (ptNext.ClassDefinitionSection in AccessSpecifierSections) then
  begin
    Result := True;
    exit;
  end;

  { return in record def after the record keyword }
  if (pt.DeclarationSection = dsType) and (pt.Word = wRecord) then
  begin
    Result := True;
    exit;
  end;


  if NeedsBlankLine(pt, ptNext) then
  begin
    Result := True;
    exit;
  end;
end;

{ semicolons have reurns after them except for a few places
   1) before and between procedure directives, e.g. procedure Fred; virtual; safecall;
   2) The array property directive 'default' has a semicolon before it
   3) seperating fields of a const record declaration
   4) between params in a procedure declaration or header
   5) as 4, in a procedure type in a type def
}
function TReturnAfter.SemicolonHasReturn(const pt: TToken): boolean;
const
  NoReturnSections: TProcedureSectionSet = [psProcedureDefinition,
    psProcedureDirectives];
var
  lcNext: TToken;
begin
  Result := True;

  if (pt.ProcedureSection in NoReturnSections) then
  begin
    Result := False;
    exit;
  end;

  { in a record type def }
  if (pt.DeclarationSection = dsType) and (pt.StructuredType = stRecord) then
  begin
    Result := True;
    exit;
  end;

  {  Make use of the fact that 3,4,5 are all inside () brackets }
  if (pt.BracketLevel > 0) then
  begin
    Result := False;
    exit;
  end;

  { default array properties - we want to format them like, e.g

    property Foo[piIndex: integer]: integer read GetFoo write SetFoo; default;

    note that this is different semantically and syntactically
    from default storage on non-array properties, e.g.

    property Bar: integer read fiBar write fiBar default 12; }

  if pt.InPropertyDefinition then
  begin
    lcNext := FirstSolidToken;
    if lcNext.Word = wDefault then
      Result := False;
  end;
end;

function TReturnAfter.NeedsBlankLine(const pt, ptNext: TToken): boolean;
begin
  Result := False;

  if (pt.TokenType in ReservedWordTokens) and (pt.Word in WordsBlankLineAfter) then
  begin
    Result := True;
    exit;
  end;

  { interface, but not as a typedef }
  if (pt.Word = wInterface) and (pt.RHSEquals = False) then
  begin
    Result := True;
    exit;
  end;

  { semicolon that ends a proc or is between procs e.g. end of uses clause }
  if (pt.TokenType = ttSemiColon) and
    (pt.ProcedureSection = psNotInProcedure) and
    (pt.DeclarationSection = dsNotInDeclaration) and
    (pt.NestingLevel = 0) then
  begin
    Result := True;
    exit;
  end;
end;


function TReturnAfter.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.AddGoodReturns;
end;


function TReturnAfter.OnProcessToken(const pt: TToken): TToken;
var
  lcNext, lcCommentTest: TToken;
  liNext, liIndex: integer;
  liReturnsNeeded, liLoop: integer;
begin
  Result := pt;


  { check the next significant token  }
  liNext := 0;
  lcNext := GetBufferTokenWithExclusions(liNext, [ttWhiteSpace, ttComment]);

  if not NeedsReturn(pt, lcNext) then
    exit;

  { catch comments!

    if the token needs a return after but the next thing is a // comment, then leave as is
    ie don't turn
      if (a > 20) then // catch large values
      begin
        ...
    into
      if (a > 20) then
      // catch large values
      begin
        ... }
  liIndex := 0;
  lcCommentTest := GetBufferTokenWithExclusions(liIndex, [ttWhiteSpace, ttReturn]);
  if (lcCommentTest.TokenType = ttComment) then
    exit;

  liReturnsNeeded := 0;
  if (lcNext.TokenType <> ttReturn) then
  begin
    { no returns at all }
    inc(liReturnsNeeded);
    if NeedsBlankLine(Result, lcNext) then
      inc(liReturnsNeeded);
  end
  else
  begin
    { one return }
    if NeedsBlankLine(Result, lcNext) then
    begin
      { check for a second return }
      inc(liNext);
      lcNext := GetBufferTokenWithExclusions(liNext, [ttWhiteSpace]);
      if (lcNext.TokenType <> ttReturn) then
        inc(liReturnsNeeded);
    end;
  end;

  for liLoop := 0 to liReturnsNeeded - 1 do
    InsertReturnInBuffer;
end;


end.