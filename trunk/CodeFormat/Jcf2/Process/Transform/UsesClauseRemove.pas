unit UsesClauseRemove;
{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is UsesClauseRemove.pas, released October 2003.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 1999-2003 Anthony Steele.
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

{ AFS 4 October 2003

  - massage the uses clause. Remove units

 }

uses
  { delphi }
  Classes,
  { local }
  SourceToken,
  SwitchableVisitor, VisitParseTree;

type
  TUsesClauseRemove = class(TSwitchableVisitor)
  private
    fiCount: integer;
    fbDoneInterface, fbDoneImplementation: Boolean;

    function MatchesSearch(const ps: string): Boolean;

  protected
    procedure EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult); override;
  public
    constructor Create; override;

    function IsIncludedInSettings: boolean; override;
    function FinalSummary(var psMessage: string): Boolean; override;

  end;

implementation

uses
  { delphi }
  SysUtils,
  { local }
  JcfSettings,
  Tokens,
  FormatFlags,
  ParseTreeNodeType,
  TokenUtils;

constructor TUsesClauseRemove.Create;
begin
  inherited;

  FormatFlags := FormatFlags + [eFindReplaceUses];

  fbDoneInterface := False;
  fbDoneImplementation := False;
  fiCount := 0;
end;

function TUsesClauseRemove.IsIncludedInSettings: boolean;
begin
  Result := (FormatSettings.UsesClause.InsertInterfaceEnabled or
    FormatSettings.UsesClause.InsertImplementationEnabled);
end;

procedure TUsesClauseRemove.EnabledVisitSourceToken(const pcNode: TObject;
  var prVisitResult: TRVisitResult);
var
  lcSourceToken, lcSepAfter, lcSepBefore: TSourceToken;
  lbInterface, lbImplementation: Boolean;
begin
  if pcNode = nil then
    exit;

  lcSourceToken := TSourceToken(pcNode);

  { only do this in a uses clause }
  if not lcSourceToken.HasParentNode(nUses) then
    exit;

  lbInterface := lcSourceToken.HasParentNode(nInterfaceSection);
  if lbInterface then
    lbImplementation := False
  else
    lbImplementation := lcSourceToken.HasParentNode(nImplementationSection);

  if not (lbImplementation or lbInterface) then
    exit;

  { only proceed on one of the specified words }
  if not (lcSourceToken.TokenType = ttIdentifier) then
    exit;

  if not MatchesSearch(lcSourceToken.SourceCode) then
    exit;

  { throw away the word and the trailing comma, as in uses clause find/replace  }
  BlankToken(lcSourceToken);

  lcSepAfter := lcSourceToken.NextSolidToken;

  if lcSepAfter.TokenType = ttComma then
  begin
    BlankToken(lcSepAfter);
  end
  else if lcSepAfter.TokenType = ttSemiColon then
  begin
    { can't remove the semicolon, but doing nothing
      might leave a comma just before it, e.g. "uses foo, ;"
      get rid of that comma }
    lcSepBefore := lcSourceToken.PriorSolidToken;
    if lcSepBefore.TokenType = ttComma then
      BlankToken(lcSepBefore)
    else if lcSepBefore.TokenType = ttUses then
    begin
      { "uses" before, ";" after. There must have been only 1 unit in the uses clause
        remove it entirely }
      BlankToken(lcSepAfter);
      BlankToken(lcSepBefore);
    end;

  end;
end;

function TUsesClauseRemove.FinalSummary(var psMessage: string): Boolean;
begin
  Result := (fiCount > 0);
  if Result then
    psMessage := 'Uses clause removal: ' + IntToStr(fiCount) + ' removals were made';
end;

function TUsesClauseRemove.MatchesSearch(const ps: string): Boolean;
begin
  Result := FormatSettings.UsesClause.Remove.IndexOf(ps) >= 0;
end;

end.