{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoSpaceAfter.pas, released April 2000.
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

unit NoSpaceAfter;

{ AFS 9 Dec 1999
  no space after  }

interface

uses TokenType, Token, TokenSource;

type

  TNoSpaceAfter = class(TBufferedTokenProcessor)
  private
    function NeedsNoSpace(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses WordMap, MiscFunctions, FormatFlags;

constructor TNoSpaceAfter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveSpace, eRemoveReturn];
end;


function TNoSpaceAfter.NeedsNoSpace(const pt: TToken): boolean;
const
  NoSpaceAnywhere: TTokenTypeSet = [ttOpenBracket, ttOpenSquareBracket, ttDot];
var
  ptNext: TToken;
  liIndex: integer;
begin
  Result := False;

  { if the next thing is a comment, leave well enough alone }
  liIndex := 0;
  ptNext  := GetBufferTokenWithExclusions(liIndex, [ttWhiteSpace, ttReturn]);
  if ptNext.TokenType = ttComment then
    exit;


  if pt.TokenType in NoSpaceAnywhere then
  begin
    Result := True;
    exit;
  end;

  { no space between method name and open bracket for param list
    no space between type & bracket for cast
    no space between fn name & params for procedure call }
  if (pt.ProcedureSection in [psProcedureDefinition, psProcedureBody])
    and (pt.TokenType in [ttWord, ttBuiltInType]) then
  begin
    if (ptNext.TokenType in OpenBrackets) then
    begin
      Result := True;
      exit;
    end;
  end;

  { the above takes care of procedure headers but not procedure type defs
   eg type TFred = procedure(i: integer) of object;
    note no space before the open bracket }
  if (pt.DeclarationSection = dsType) and (pt.RHSEquals) and
    (pt.Word in ProcedureWords) then
  begin
    if (ptNext.TokenType in OpenBrackets) then
    begin
      Result := True;
      exit;
    end;
  end;

  { no space after unary operator }
  if (pt.ProcedureSection = psProcedureBody) and
    (pt.TokenType = ttOperator) and (pt.Word in PossiblyUnarySymbolOperators) and
    (not pt.RHSOperand) and (not StrHasAlpha(pt.SourceCode)) then
  begin
    Result := True;
    exit;
  end;

  { no space before class heritage ? could be one of 3 things
    TFoo = class; - no space, but "No space before semicolon" should take care of that
    TBar = class(TBaz) - no space unless you are Marcel van Brakel
    TWibble = class of TFish - has space

    see SingleSpaceAfter

    also applies to type TFoo = interface(IDispatch) }
  if (pt.DeclarationSection = dsType) and (pt.Word in ObjectTypeWords)
    and not (Settings.Spaces.SpaceBeforeClassHeritage) then
  begin
    if (ptNext.TokenType in [ttOpenBracket, ttSemiColon]) then
    begin
      Result := True;
      exit;
    end;
  end;
end;


function TNoSpaceAfter.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.FixSpacing;
end;

function TNoSpaceAfter.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := NeedsNoSpace(pt);
end;

function TNoSpaceAfter.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;

  lcNext := BufferTokens(0);
  while lcNext.TokenType in [ttWhiteSpace, ttReturn] do
  begin
    RemoveBufferToken(0);
    lcNext := BufferTokens(0);
  end;
end;

end.