{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is SingleSpaceBefore.pas, released April 2000.
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

unit SingleSpaceBefore;

{ AFS 7 Dec 1999
  single space before certain tokens (e.g. ':='

  This process and SingleSpaceAfter must be carefull with directives:
   words like "read" and "write" must be single-spaced in property defs
   but in normal code these are valid procedure names, and
     converting "Result := myObject.Read;" to
     "Result := myObject. read ;" compiles, but looks all wrong
}


interface

uses TokenType, Token, TokenSource;

type

  TSingleSpaceBefore = class(TBufferedTokenProcessor)
  private

    function NeedsSpaceBefore(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses
  { jcl } JclStrings,
  { local } WordMap, FormatFlags;

{ TSingleSpaceBefore }

const
  // space before all operators
  SingleSpaceBeforeTokens: TTokenTypeSet = [ttAssign, ttOperator];
  SingleSpaceBeforeWords: TWordSet       = [wEquals, wThen, wOf, wDo,
    wTo, wDownTo,
    // some unary operators
    wNot,
    // all operators that are always binary
    wAnd, wAs, wDiv, wIn, wIs, wMod, wOr, wShl, wShr, wXor,
    wTimes, wFloatDiv, wEquals, wGreaterThan, wLessThan,
    wGreaterThanOrEqual, wLessThanOrEqual, wNotEqual];


constructor TSingleSpaceBefore.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddSpace, eRemoveSpace, eRemoveReturn];
end;

function TSingleSpaceBefore.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.FixSpacing;
end;

function TSingleSpaceBefore.NeedsSpaceBefore(const pt: TToken): boolean;
begin
  Result := False;

  if (pt.TokenType in SingleSpaceBeforeTokens) then
  begin
    Result := True;
    exit;
  end;

  if (pt.IsDirective) then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word in SingleSpaceBeforeWords) then
  begin
    Result := True;
    exit;
  end;

  { 'in' in the uses clause }
  if ((pt.Word = wIn) and (pt.InUsesClause)) then
  begin
    Result := True;
    exit;
  end;

  { string that starts with # , ie char codes
  }
  if pt.IsHashLiteral then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word = wDefault) and pt.InPropertyDefinition then
  begin
    Result := True;
    exit;
  end;


end;

function TSingleSpaceBefore.OnProcessToken(const pt: TToken): TToken;
var
  fcNext1, fcNext2, fcNew: TToken;
begin
  { inspect the next 2 tokens }
  fcNext1 := BufferTokens(0);
  fcNext2 := BufferTokens(1);

  if NeedsSpaceBefore(fcNext2) then
  begin
    if (fcNext1.TokenType = ttWhiteSpace) then
      fcNext1.SourceCode := ' '
    else
    begin
      fcNew := TToken.Create;
      fcNew.TokenType := ttWhiteSpace;
      fcNew.SourceCode := ' ';
      InsertTokenInBuffer(1, fcNew);
    end;
  end;

  Result := pt;
end;

end.