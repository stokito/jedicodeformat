unit WarnAssignToFunctionName;

{ AFS 21 Sept 2001

 warn of assignment to function name in old TurboPascal code

 ie
  function Fred: integer;
  begin
    Fred := 3;
  end;

 should be

  function Fred: integer;
  begin
    Result := 3;
  end;
}

interface

uses Warning, VisitParseTree;

type

  TWarnAssignToFunctionName = class(TWarning)
    private
      procedure WarnAllAssigns(const psFnName: string; const pcRoot: TObject);
    public
      procedure PreVisitParseTreeNode(const pcNode: TObject; var prVisitResult: TRVisitResult); override;
  end;


implementation

uses
  { delphi } SysUtils,
  ParseTreeNode, ParseTreeNodeType, SourceToken, TokenType,
  TokenUtils;



{ get the node that represents the identifier that is being assigned to
  node passed in will be statement

  looking for the last id before the ':=',

  e.g. in "TFoo(bar.baz) := fish;" we want "baz"

  NB this may not work in complex examples as the id may be under an expr node
  but may suffice for this fn name assign detection
  }
function GetIdentifierBeforeAssign(const pcNode: TParseTreeNode): TSourceToken;
var
  liLoop: integer;
  lcChildNode: TParseTreeNode;
  lcSourceToken: TSourceToken;
begin
  Result := nil;

  for liLoop := 0 to pcNode.ChildNodeCount - 1 do
  begin
    lcChildNode := pcNode.ChildNodes[liLoop];

    if lcChildNode is TSourceToken then
    begin
      lcSourceToken := TSourceToken(lcChildNode);

      if lcSourceToken.TokenType in IdentifierTypes then
        Result := lcSourceToken;
    end
    else if lcChildNode.NodeType = nAssignment then
      break;

  end;
end;

procedure TWarnAssignToFunctionName.PreVisitParseTreeNode(const pcNode: TObject; var prVisitResult: TRVisitResult);
var
  lcNode: TParseTreeNode;
  lcFunctionHeading: TParseTreeNode;
  lsName: string;
begin
  lcNode := TParseTreeNode(pcNode);

  if lcNode.NodeType <> nFunctionDecl then
    exit;

  { we now have a function decl
    Find the name, find the assign statements. Compare }
  lcFunctionHeading := lcNode.GetImmediateChild([nFunctionHeading]);
  Assert(lcFunctionHeading <> nil);

  lsName := ExtractNameFromFunctionHeading(lcFunctionHeading, False);

  WarnAllAssigns(lsName, lcNode);
end;

procedure TWarnAssignToFunctionName.WarnAllAssigns(const psFnName: string;
  const pcRoot: TObject);
var
  lcNode: TParseTreeNode;
  lcLeftName: TSOurceToken;
  liLoop: integer;
begin
  Assert(pcRoot <> nil);
  lcNode := TParseTreeNode(pcRoot);

  if (lcNode.NodeType = nStatement) and (lcNode.HasChildNode(nAssignment, 1)) then
  begin

    // this is an assign statement. Look at the LHS
    lcLeftName := GetIdentifierBeforeAssign(lcNode);

    if AnsiSameText(lcLeftName.SourceCode, psFnName) then
    begin
      SendWarning(lcLeftName,
        'Assignment to the function name "' + psFnName +
          '" is deprecated, Use assignment to "Result"');
    end;
  end
  else
  begin
    // look at all nodes under here
    for liLoop := 0 to lcNode.ChildNodeCount - 1 do
      WarnAllAssigns(psFnName, lcNode.ChildNodes[liLoop]);
  end;
end;

end.