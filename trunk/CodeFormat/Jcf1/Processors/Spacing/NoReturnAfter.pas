{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoReturnAfter.pas, released July 2000.
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

unit NoReturnAfter;

{ AFS 13 July 2K
  No return after - modeled on NoSpaceAfter }

interface

uses TokenType, Token, TokenSource;

type

  TNoReturnAfter = class(TBufferedTokenProcessor)
  private
    fcLastSolidToken: TToken;

    function NeedsNoReturn(const pt: TToken): boolean;
    function NoDeclarationBefore: Boolean;
    function CommentBefore: Boolean;
    function NoSemiColonBefore: Boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

    procedure OnFileStart; override;
  end;

implementation

uses WordMap, FormatFlags, SetReturns;

constructor TNoReturnAfter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

function TNoReturnAfter.NeedsNoReturn(const pt: TToken): boolean;
const
  NoReturnWords: TWordSet = [wProcedure, wFunction,
    wConstructor, wDestructor, wProperty];
var
  lcSetReturns: TSetReturns;
  ptNext: TToken;
  liIndex: integer;
begin
  Result := False;

  lcSetReturns := Settings.Returns;
  Assert(lcSetReturns <> nil);

  if Settings.Returns.RemoveBadReturns then
  begin

    if pt.Word in NoReturnWords then
    begin
      Result := True;
      exit;
    end;

    { only place a return after a colon is legit is at a label
      in a proc body }
    if pt.TokenType = ttColon then
    begin
      if not ((pt.ProcedureSection = psProcedureBody) and (pt.BracketLevel = 0)) then
      begin
        Result := True;
        exit;
      end;
    end;

    { var x absolute y;  just after absolute is a bad place to break }
    if (pt.Word = wAbsolute) and (pt.DeclarationSection = dsVar) then
    begin
      Result := True;
      exit;
    end;

    { Default property values:
      No return after 'default' in property def on non-array property
      because it's always followed by a number, e.g.
      property FloonCount: integer default 12;
      as opposed to default (array) properties,
      eg property Items[piIndex: integer]; default; }
    if (pt.Word = wDefault) and (pt.StructuredType <> stNotInStructuredType) and
      (pt.InPropertyDefinition) then
    begin
      { use the persence of semicolon to distinguish
      Default property values from default (array) properties }
      if not SemiColonNext then
      begin
        Result := True;
        exit;
      end;
    end;

    { array property params - no returns }
    if (pt.SquareBracketLevel > 0) and (pt.StructuredType <> stNotInStructuredType) and
      (pt.InPropertyDefinition) then
    begin
      { use the persence of semicolon to distinguish
      Default property values from default (array) properties }
      if not SemiColonNext then
      begin
        Result := True;
        exit;
      end;
    end;

    { in procedure params - no return after 'var' or 'const' }
    if (pt.ProcedureSection = psProcedureDefinition) and (pt.BracketLevel > 0) then
    begin
      if pt.Word in [wVar, wConst] then
      begin
        Result := True;
        exit;
      end;
    end;

    { in procedure body - no return directly after 'if' }
    if pt.ProcedureSection = psProcedureBody then
    begin
      if pt.Word = wIf then
      begin
        Result := True;
        exit;
      end;
    end;
  end;

  { remove returns based on options }

  { the options don't apply after comments }
  if (pt.TokenType = ttComment) then
  begin
    Result := False;
    exit;
  end;

  { or just before them }
  liIndex := 0;
  ptNext  := GetBufferTokenWithExclusions(liIndex, [ttWhiteSpace, ttReturn]);

  if (ptNext.TokenType = ttComment) or CommentBefore then
  begin
    Result := False;
    exit;
  end;

  if lcSetReturns.RemoveExpressionReturns and pt.InExpression then
  begin
    { can have a block that ends in expression without a semicolon, eg Don't remove return here:
      begin
        a := a + 2
      end;    }

    if ptNext.InExpression then
    begin
      Result := True;
      exit;
    end;
  end;

  if lcSetReturns.RemoveVarReturns and (pt.TokenType <> ttSemiColon) and
    (not (pt.Word in Declarations)) and pt.InVarList then
  begin
    if NoDeclarationBefore and NoSemicolonBefore and ptNext.InVarList then
    begin
      Result := True;
      exit;
    end;
  end;

  if lcSetReturns.RemoveProcedureDefReturns and pt.InProcedureParamList then
  begin
    Result := True;
    exit;
  end;

  if lcSetReturns.RemovePropertyReturns and (pt.TokenType <> ttSemiColon) and pt.InPropertyDefinition then
  begin
    Result := True;
    exit;
  end;
end;

function TNoReturnAfter.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled);
end;

function TNoReturnAfter.IsTokenInContext(const pt: TToken): boolean;
begin
  if not (pt.TokenType in [ttWhiteSpace, ttReturn]) then
    fcLastSolidToken := pt;

  Result := NeedsNoReturn(pt);
end;

function TNoReturnAfter.OnProcessToken(const pt: TToken): TToken;
var
  lcNext:  TToken;
  liIndex: integer;
begin
  Result := pt;

  liIndex := 0;
  lcNext  := BufferTokens(0);
  while lcNext.TokenType in [ttReturn, ttWhiteSpace] do
  begin
    if lcNext.TokenType = ttReturn then
      RemoveBufferToken(liIndex)
    else
      inc(liIndex);

    lcNext := BufferTokens(liIndex);
  end;
end;

procedure TNoReturnAfter.OnFileStart;
begin
  inherited;
  fcLastSolidToken := nil;
end;

function TNoReturnAfter.NoDeclarationBefore: Boolean;
begin
  Result := (fcLastSolidToken = nil) or (not (fcLastSolidToken.Word in Declarations));
end;

function TNoReturnAfter.NoSemiColonBefore: Boolean;
begin
  Result := (fcLastSolidToken = nil) or (not (fcLastSolidToken.TokenType = ttSemiColon));
end;

function TNoReturnAfter.CommentBefore: Boolean;
begin
  Result := (fcLastSolidToken <> nil) and (fcLastSolidToken.TokenType = ttComment)
end;

end.