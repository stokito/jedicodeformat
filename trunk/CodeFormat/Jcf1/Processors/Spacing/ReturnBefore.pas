{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ReturnBefore.pas, released April 2000.
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

unit ReturnBefore;

{ AFS Jan 2K
 put a return (or blank line) before some words

 to insert tokens before words, it must look ahead
 to cope with the case of the unit's terminal end "end."
 it must look ahead 2 tokens

 As of Feb 2K this processor does not keep it's own instrumentation except for fbBlankLineBefore
 on the token's position, that is done by the position class and the data attached to the token
}


interface

uses
  TokenType, Token, TokenSource;

type

  TReturnBefore = class(TBufferedTokenProcessor)
  private
    fbBlankLineBefore: boolean;

    function NeedsReturn(const pt, ptNext: TToken): boolean;
    function NeedsBlankLine(const pt, ptNext: TToken): boolean;

    procedure AddReturn;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

    procedure OnFileStart; override;
  end;

implementation

uses WordMap, FormatFlags;

const
  WordsReturnBefore: TWordSet =
    [wBegin, wEnd, wUntil, wElse, wTry, wFinally, wExcept];

  WordsBlankLineBefore: TWordSet =
    [wImplementation, wInitialization, wFinalization, wUses];

  // special things: wProcedure, wFunction, wConst

  { TReturnBefore }

constructor TReturnBefore.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddReturn];
end;

function TReturnBefore.NeedsReturn(const pt, ptNext: TToken): boolean;
begin
  Result := (pt.Word in WordsReturnBefore);
  if Result = True then
    exit;

  { there is not always a return before 'type'
    e.g.
    type TMyInteger = type Integer;
    is legal, only a return before the first one

   var, const, type but not in parameter list }
  if (pt.Word in Declarations) and (pt.BracketLevel = 0) and (not pt.RHSEquals) then
  begin
    Result := True;
    exit;
  end;

  { procedure & function in class def get return but not blank line before }
  if (pt.Word in ProcedureWords + [wProperty]) and (not pt.ClassFunction) and
    (pt.StructuredType in [stClass, stInterface]) then
  begin
    Result := True;
    exit;
  end;

  { nested procs get it as well }
  if (pt.Word in ProcedureWords) and (not pt.RHSEquals) and (not pt.ClassFunction) and
    (pt.StructuredType = stNotInStructuredType) then
  begin
    Result := True;
    exit;
  end;

  { class function }
  if (pt.Word = wClass) and (pt.ClassFunction) then
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

  { "uses UnitName in 'File'" has a blank line before UnitName }
  if (pt.TokenType = ttWord) and (pt.InUsesClause) and (ptNext.Word = wIn) then
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

function TReturnBefore.NeedsBlankLine(const pt, ptNext: TToken): boolean;
begin
  Result := (pt.Word in WordsBlankLineBefore);

  { function/proc body needs a blank line
   but not in RHSEquals of type defs,
   but not in class & interface def,
   but not if precedeed by the class specified for class functions
   but not if it is a contained function

   !! this mistakenly spaces proc forwards.
   }


  if (pt.Word in [wProcedure, wFunction]) and pt.ProcedureHasBody and
    (pt.DeclarationSection = dsNotInDeclaration) and
    (not pt.ClassFunction) and (pt.ProcedureNestingLevel = 0) then
  begin
    Result := True;
    exit;
  end;


  { start of class function body }
  if (pt.Word = wClass) and (pt.ClassFunction) and
    (pt.DeclarationSection = dsNotInDeclaration) and
    (pt.FileSection = fsImplementation) then
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

  { end. }
  if (pt.Word = wEnd) and (ptNext.TokenType = ttDot) and (pt.NestingLevel = 0) then
  begin
    Result := True;
    exit;
  end;
end;


procedure TReturnBefore.AddReturn;
begin
  { add a return before the next }
  AddTokenToFrontOfBuffer(NewReturnToken);
end;

procedure TReturnBefore.OnFileStart;
begin
  inherited;
  fbBlankLineBefore := False;
end;

function TReturnBefore.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.AddGoodReturns;
end;

function TReturnBefore.OnProcessToken(const pt: TToken): TToken;
var
  tcNext, tcNext2: TToken;
  liLoop, liReturnsNeeded: integer;
  liNext:          integer;
begin
  { we are really interested in tcNext, but we inspect pt
   to see if there is a significant token before it on the line
   this is a running total, that is affeced by returns & non-white-space chars
   A comment line is as good as a blank line for this

    if we encounter the tokens <return> <spaces> <word-needing-return before> the flag must be set true
   }

  if (pt.IndexOnLine = 0) and (pt.TokenType = ttReturn) then
    fbBlankLineBefore := True;
  if not (pt.TokenType in [ttReturn, ttWhiteSpace, ttComment]) then
    fbBlankLineBefore := False;

  { check the next token  }
  liReturnsNeeded := 0;
  tcNext          := BufferTokens(0);
  liNext          := 1; // start with token after lcNext
  tcNext2         := GetBufferTokenWithExclusions(liNext, [ttWhiteSpace, ttReturn, ttComment]);

  // token should be first on line, or else wrap it  !
  if (tcNext.IndexOnLine > 1) and NeedsReturn(tcNext, tcNext2) then
    inc(liReturnsNeeded);

  if not fbBlankLineBefore and NeedsBlankLine(tcNext, tcNext2) then
    inc(liReturnsNeeded);

  for liLoop := 0 to liReturnsNeeded - 1 do
    AddReturn;

  Result   := pt;
  fiResume := tcNext.TokenIndex + liReturnsNeeded;
end;

end.