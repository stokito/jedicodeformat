unit NoSpaceBefore;

{ AFS 5 Jan 2002
  No space before certain tokens (e.g. '.' ';'
  the Colon has it's own unit }


{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoSpaceBefore, released May 2003.
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

interface

uses SwitchableVisitor, VisitParseTree;

type
  TNoSpaceBefore = class(TSwitchableVisitor)
  private
    fbSafeToRemoveReturn: boolean;  // this taken from NoReturnBefore
  protected
    procedure EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult); override;
  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
  end;


implementation

uses JcfSettings, SourceToken, Tokens, ParseTreeNodeType,
  FormatFlags, TokenUtils;

const
  NoSpaceAnywhere: TTokenTypeSet = [ttDot, ttComma,
    ttCloseSquareBracket, ttCloseBracket];

function HasNoSpaceBefore(const pt: TSourceToken): boolean;
var
  lcPrev: TSourceToken;
begin
  Result := False;

  if pt = nil then
    exit;

  // '@@' in asm, e.g. "JE @@initTls" needs the space
  if pt.HasParentNode(nAsm) then
    exit;

  if pt.TokenType in NoSpaceAnywhere then
  begin
    Result := True;
    exit;
  end;

  // semicolon usually, except after 'begin' and another semicolon
  if pt.TokenType = ttSemiColon then
  begin
    lcPrev := pt.PriorTokenWithExclusions(NotSolidTokens);
    if not (lcPrev.TokenType in [ttSemiColon, ttBegin]) then
    begin
      Result := True;
      exit;
    end;
  end;

  { hat (dereference) in expression is unary postfix operator - so no space before it }
  if (pt.HasParentNode(nExpression)) and (pt.TokenType = ttHat) then
  begin
    Result := True;
    exit;
  end;

  { no space before open brackets for fn name - declaration or use }
  if IsActualParamOpenBracket(pt) or IsFormalParamOpenBracket(pt) then
  begin
    Result := True;
    exit;
  end;

  { no space before colon -- anywhere? }
  if pt.TokenType = ttColon then
  begin
    Result := True;
    exit;
  end;

  { '[' of array property definition }
  if (pt.TokenType = ttOpenSquareBracket) and pt.HasParentNode(nProperty) then
  begin
    Result := True;
    exit;
  end;


end;

constructor TNoSpaceBefore.Create;
begin
  inherited;
  fbSafeToRemoveReturn := True;
  FormatFlags := FormatFlags + [eRemoveSpace];
end;

procedure TNoSpaceBefore.EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult);
var
  lcSourceToken: TSourceToken;
  lcNext: TSourceToken;
begin
  lcSourceToken := TSourceToken(pcNode);

  // not safe to remove return at a comment like this
  if (lcSourceToken.TokenType = ttComment) and (lcSourceToken.CommentStyle = eDoubleSlash) then
    fbSafeToRemoveReturn := False
  else if (lcSourceToken.TokenType <> ttReturn) then
    fbSafeToRemoveReturn := True;

  // work on whitespace and returns
  if (not (lcSourceToken.TokenType in [ttWhiteSpace, ttReturn])) or (not fbSafeToRemoveReturn) then
    exit;

  lcNext := lcSourceToken.NextToken;
  if lcNext = nil then
    exit;

  if HasNoSpaceBefore(lcNext) then
  begin
    // the space
    BlankToken(lcSourceToken);
  end;
end;

function TNoSpaceBefore.IsIncludedInSettings: boolean;
begin
  Result := FormatSettings.Spaces.FixSpacing;
end;

end.