unit AddBeginEnd;
{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AddBeginEnd.pas, March 2004.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 2004 Anthony Steele.
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

uses BaseVisitor;

type
  TAddBeginEnd = class(TBaseTreeNodeVisitor)
  private

  protected
  public
    constructor Create; override;

    procedure PostVisitParseTreeNode(const pcNode: TObject); override;
    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses
  SettingsTypes,
  ParseTreeNode, ParseTreeNodeType,
  JcfSettings, SourceToken, Tokens, SetTransform, TokenUtils;

function IsBlockParent(const pcNode: TParseTreeNode): boolean;
const
  BLOCK_PARENTS: TParseTreeNodeTypeSet =
    [nIfBlock, nElseBlock, nCaseSelector, nElseCase,
    nWhileStatement, nForStatement, nWithStatement];
begin
  Result := (pcNode <> nil) and (pcNode.NodeType in BLOCK_PARENTS);
end;

function HasBlockChild(const pcNode: TParseTreeNode): boolean;
var
  liDepth: integer;
begin
  if pcNode.NodeType = nElseCase then
    liDepth := 3
  else
    liDepth := 2;

  { a compound statement is the begin..end block. }
  Result := pcNode.HasChildNode(nCompoundStatement, liDepth);
end;

procedure TestAddSpaceAtEnd(const pcNode: TParseTreeNode);
var
  lcLeaf: TSourceToken;
begin
  lcLeaf := TSourceToken(pcNode.LastLeaf);
  if (lcLeaf = nil) or lcLeaf.IsSolid then
    pcNode.AddChild(NewSpace(1));
end;

{
  it is not safe to remove the block from
    if <cond1> then
    begin
      if <cond2> then
        <statement1>
    end
    else
      <statement2>;
}
function SafeToRemoveBeginEnd(const pcNode: TParseTreeNode): Boolean;
const
  { if there is an if stament with no else case immediately hereunder,
  should find it by this depth }
  IMMEDIATE_IF_DEPTH = 4;
var
  lcChildStmnt: TParseTreeNode;
begin
  Result := True;

  { is this an if block? }
  if (pcNode <> nil) and (pcNode.NodeType = nIfBlock) then
  begin
    { does it have an else case? }
    if pcNode.Parent.HasChildNode(nElseBlock, 1) then
    begin
      lcChildStmnt := pcNode.GetImmediateChild(nStatement);

      { does the if block contain an if statement? }
      if (lcChildStmnt <> nil) and lcChildStmnt.HasChildNode(nIfBlock, IMMEDIATE_IF_DEPTH) and
        (not lcChildStmnt.HasChildNode(nElseBlock, IMMEDIATE_IF_DEPTH)) then
        Result := False;
    end;
  end;
end;

procedure AddBlockChild(const pcNode: TParseTreeNode);
var
  liIndex: integer;
  lcTop: TParseTreeNode;
  lcStatement, lcCompound, lcStatementList: TParseTreeNode;
  lcBegin, lcEnd: TSourceToken;
  lcPrior: TSourceToken;
begin
  { this is an if block or the like
    with a single statement under it  }
  if pcNode.NodeType = nElseCase then
    lcTop := pcNode.GetImmediateChild(nStatementList)
  else
    lcTop := pcNode;

  lcStatement := lcTop.GetImmediateChild(nStatement);

  if lcStatement = nil then
  begin
    // a dangling else or the like
    liIndex := 0;
  end
  else
  begin
    liIndex := lcTop.IndexOfChild(lcStatement);
    Assert(liIndex >= 0);
  end;

  { temporarily take it out }
  lcTop.ExtractChild(lcStatement);

  { need some new nodes:
    statement
     - compound statement
       - begin
       - statement list
         -  lcStatement
       - end
    }
    
    lcCompound := TParseTreeNode.Create;
    lcCompound.NodeType := nCompoundStatement;
    lcTop.InsertChild(liIndex, lcCompound);

    lcBegin := TSourceToken.Create;
    lcBegin.SourceCode := 'begin';
    lcBegin.TokenType := ttBegin;
    lcCompound.AddChild(lcBegin);
    lcCompound.AddChild(NewSpace(1));

    { check we have got space before the begin }
    lcPrior := lcBegin.PriorToken;
    if (lcPrior <> nil) and lcPrior.IsSolid then
      lcPrior.Parent.InsertChild(lcPrior.IndexOfSelf + 1, NewSpace(1));

    lcStatementList := TParseTreeNode.Create;
    lcStatementList.NodeType := nStatementList;
    lcCompound.AddChild(lcStatementList);

    { the original statement goes in the middle of this }
    if lcStatement <> nil then
      lcStatementList.AddChild(lcStatement);

    TestAddSpaceAtEnd(lcCompound);

    lcEnd := TSourceToken.Create;
    lcEnd.SourceCode := 'end';
    lcEnd.TokenType := ttEnd;
    lcCompound.AddChild(lcEnd);
end;

procedure RemoveBlockChild(const pcNode: TParseTreeNode);
var
  lcTop, lcTopStatement: TParseTreeNode;
  lcCompoundStatement: TParseTreeNode;
  lcStatementList: TParseTreeNode;
  lcStatement: TParseTreeNode;
  liIndex: integer;
begin
  if pcNode.NodeType = nElseCase then
    lcTop := pcNode.GetImmediateChild(nStatementList)
  else
    lcTop := pcNode;

  Assert(lcTop <> nil);

  lcTopStatement := lcTop.GetImmediateChild(nStatement);
  if lcTopStatement = nil then
    exit;

  liIndex := lcTop.IndexOfChild(lcTopStatement);
  Assert(liIndex >= 0);

  lcCompoundStatement := lcTopStatement.GetImmediateChild(nCompoundStatement);
  if lcCompoundStatement = nil then
    exit;

  lcStatementList := lcCompoundStatement.GetImmediateChild(nStatementList);
  if lcStatementList = nil then
    exit;

  // if this begin...end owns more than one statement, we can't do it
  if lcStatementList.CountImmediateChild(nStatement) > 1 then
    exit;

  lcStatement := lcStatementList.GetImmediateChild(nStatement);

  if lcStatement <> nil then
  begin
    // right, put this single statement in at the top
    lcStatementList.ExtractChild(lcStatement);
    lcTop.InsertChild(liIndex, lcStatement);
  end;

  // and free the rest of the scaffolding
  lcTopStatement.Free;
end;

constructor TAddBeginEnd.Create;
begin
  inherited;

  HasPostVisit := True;
  HasSourceTokenVisit := False;
end;

procedure TAddBeginEnd.PostVisitParseTreeNode(const pcNode: TObject);
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(pcNode);

  if not IsBlockParent(lcNode) then
    exit;

  case FormatSettings.Transform.BeginEndStyle of
    eNever:
    begin
      if HasBlockChild(lcNode) and SafeToRemoveBeginEnd(lcNode) then
        RemoveBlockChild(lcNode);
    end;
    eAlways:
    begin
      if (not HasBlockChild(lcNode)) then
        AddBlockChild(lcNode);
    end
    else
      // should not be here
      Assert(false);
  end;
end;

function TAddBeginEnd.IsIncludedInSettings: boolean;
begin
  Result := (FormatSettings.Transform.BeginEndStyle <> eLeave);
end;

end.