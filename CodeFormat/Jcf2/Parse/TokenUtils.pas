unit TokenUtils;

{ AFS 2 Jan
  procedureal code that works on the parse tree
  not put on the class as it's most fairly specific stuff
    (but has been put here because 2 or more processes use it )
  and nedds to know both classes - TParseTreeNode and TSoruceTOken
  }

interface

uses ParseTreeNode, SourceToken;

{ make a new return token }
function NewReturn: TSourceToken;
function NewSpace(const piLength: integer): TSourceToken;

function InsertReturnAfter(const pt: TSourceToken): TSourceToken;
function InsertSpacesBefore(const pt: TSourceToken; const piSpaces: integer): TSourceToken;

{ return the name of the procedure around any parse tree node or source token
  empty string if there is none }
function GetProcedureName(const pcNode: TParseTreeNode;
  const pbFullName: boolean; const pbTopmost: boolean): string;


{ depending on context, one of Procedure, function, constructor, destructor }
function GetBlockType(const pcNode: TParseTreeNode): string;


function ExtractNameFromFunctionHeading(const pcNode: TParseTreeNode; const pbFullName: boolean): string;

function IsClassFunction(const pt: TSourceToken): boolean;

function RHSExprEquals(const pt: TSourceToken): Boolean;

function RHSTypeEquals(const pt: TSourceToken): Boolean;

function IsClassDirective(const pt: TSourceToken): boolean;

function RoundBracketLevel(const pt: TSourceToken): integer;
function SquareBracketLevel(const pt: TSourceToken): integer;
function AllBracketLevel(const pt: TSourceToken): integer;
function BlockLevel(const pt: TSourceToken): integer;

function InRoundBrackets(const pt: TSourceToken): boolean;

function SemicolonNext(const pt: TSourceToken): boolean;

{ true if the token is in code, ie in procedure/fn body,
  init section, finalization section, etc

  False if it is vars, consts, types etc
  or in asm }
function InStatements(const pt: TSourceToken): Boolean;
function InProcedureDeclarations(const pt: TsourceToken): Boolean;
function InDeclarations(const pt: TsourceToken): Boolean;

function IsCaseColon(const pt: TSourceToken): boolean;
function IsLabelColon(const pt: TSourceToken): boolean;

function IsFirstSolidTokenOnLine(const pt: TSourceToken): boolean;

function IsUnaryOperator(const pt: TSourceToken): boolean;

function InFormalParams(const pt: TSourceToken): boolean;

function IsActualParamOpenBracket(const pt: TSourceToken): boolean;
function IsFormalParamOpenBracket(const pt: TSourceToken): boolean;

function IsLineBreaker(const pcToken: TSourceToken): boolean;
function IsMultiLineComment(const pcToken: TSourceToken): boolean;

function VarIdentCount(const pcNode: TParseTreeNode): integer;
function IdentListNameCount(const pcNode: TParseTreeNode): integer;

implementation

uses
  SysUtils,
  JclStrings,
  ParseTreeNodeType, TokenType, WordMap, Nesting;


function NewReturn: TSourceToken;
begin
  Result := TSourceToken.Create;
  Result.TokenType := ttReturn;
  Result.SourceCode := AnsiLineBreak;
end;

function NewSpace(const piLength: integer): TSourceToken;
begin
  Assert(piLength > 0, 'Bad space length of' + IntToStr(piLength));

  Result := TSourceToken.Create;
  Result.TokenType := ttWhiteSpace;
  Result.SourceCode := StrRepeat(AnsiSpace, piLength);
end;


function InsertReturnAfter(const pt: TSourceToken): TSourceToken;
begin
  Assert(pt <> nil);
  Assert(pt.Parent <> nil);

  Result := NewReturn;
  pt.Parent.InsertChild(pt.IndexOfSelf + 1, Result);
end;

function InsertSpacesBefore(const pt: TSourceToken; const piSpaces: integer): TSourceToken;
begin
  Assert(pt <> nil);
  Assert(pt.Parent <> nil);

  Result := NewSpace(piSpaces);
  pt.Parent.InsertChild(pt.IndexOfSelf, Result);
end;

{ given a function header parse tree node, extract the fn name underneath it }
function ExtractNameFromFunctionHeading(const pcNode: TParseTreeNode;
  const pbFullName: boolean): string;
var
  liLoop: integer;
  lcChildNode: TParseTreeNode;
  lcSourceToken: TSourceToken;
  lcNameToken: TSourceToken;
  lcPriorToken1, lcPriorToken2: TSourceToken;
begin
  lcNameToken := nil;

  { function heading is of one of these forms
      function foo(param: integer): integer;
      function foo: integer;
      function TBar.foo(param: integer): integer;
      function TBar.foo: integer;

    within the fn heading, the name will be last identifier before nFormalParams or ':'

  }
  for liLoop := 0 to pcNode.ChildNodeCount - 1 do
  begin
    lcChildNode := pcNode.ChildNodes[liLoop];

    if lcChildNode.NodeType = nFormalParams then
      break;

    if lcChildNode is TSourceToken then
    begin
      lcSourceToken := TSourceToken(lcChildNode);

      { keep the name of the last identifier }
      if lcSourceToken.TokenType in IdentifierTypes then
        lcNameToken := lcSourceToken
      else if lcSourceToken.TokenType = ttColon then
        break;
    end;
  end;

  if lcNameToken = nil then
    Result := ''
  else if pbFullName then
  begin
    Result := lcNameToken.SourceCode;

    // is it a qualified name
    lcPriorToken1 := lcNameToken.PriorSolidToken;
    if (lcPriorToken1 <> nil) and (lcPriorToken1.TokenType = ttDot) then
    begin
      lcPriorToken2 := lcPriorToken1.PriorSolidToken;
      if (lcPriorToken2 <> nil) and (lcPriorToken2.TokenType in IdentifierTypes) then
      begin
        Result := lcPriorToken2.SourceCode + lcPriorToken1.SourceCode + lcNameToken.SourceCode;
      end;
    end;
  end
  else
  begin
    // just the proc name, no prefix
    Result := lcNameToken.SourceCode;
  end;
end;

const
  PROCEDURE_NODE_TYPES: TParseTreeNodeTypeSet =
    [nProcedureDecl, nFunctionDecl, nConstructorDecl, nDestructorDecl];


function GetProcedureName(const pcNode: TParseTreeNode;
  const pbFullName: boolean; const pbTopmost: boolean): string;
var
  lcFunction, lcTemp, lcHeading: TParseTreeNode;
begin
  Assert(pcNode <> nil);

  lcFunction := pcNode.GetParentNode(PROCEDURE_NODE_TYPES);

  if lcFunction = nil then
  begin
    // not in a function, procedure or method
    Result := '';
    exit;
  end;

  if pbTopmost then
  begin
    { find the top level function }
    lcTemp := lcFunction.GetParentNode(PROCEDURE_NODE_TYPES);
    while lcTemp <> nil do
    begin
      lcFunction := lcTemp;
      lcTemp := lcFunction.GetParentNode(PROCEDURE_NODE_TYPES);
    end;
  end;

  lcHeading := lCFunction.GetImmediateChild(ProcedureHeadings);

  Result := ExtractNameFromFunctionHeading(lcHeading, pbFullName)
end;

function GetBlockType(const pcNode: TParseTreeNode): string;
var
  lcFunction: TParseTreeNode;
begin
  lcFunction := pcNode.GetParentNode(PROCEDURE_NODE_TYPES + [nInitSection]);

  if lcFunction = nil then
  begin
    Result := '';
    exit;
  end;

  case lcFunction.NodeType of
    nProcedureDecl:
      Result := 'procedure';
    nFunctionDecl:
      Result := 'function';
    nConstructorDecl:
      Result := 'constructor';
    nDestructorDecl:
      Result := 'destructor';
    nInitSection:
      Result := 'initialization section';
    else
      Result := '';
  end;
end;

function IsClassFunction(const pt: TSourceToken): boolean;
begin
  Result := pt.IsOnRightOf(ProcedureHeadings, [wClass]);
end;

function RHSExprEquals(const pt: TSourceToken): Boolean;
begin
  Result := pt.IsOnRightOf(nExpression, wEquals);
end;

function RHSTypeEquals(const pt: TSourceToken): Boolean;
begin
  Result := pt.IsOnRightOf(nType, wEquals);
end;

function IsClassDirective(const pt: TSourceToken): boolean;
begin
  { property Public: Boolean;
    function Protected: Boolean
    are both legal so have to check that we're not in a property or function def. }

  Result := (pt.Word in ClassDirectives) and
    pt.HasParentNode(nClassVisibility) and
    (not (pt.HasParentNode(ProcedureNodes)));
end;

function RoundBracketLevel(const pt: TSourceToken): integer;
begin
  if pt = nil then
    Result := 0
  else
    Result := pt.Nestings.GetLevel(nlRoundBracket);
end;

function InRoundBrackets(const pt: TSourceToken): boolean;
begin
  if pt = nil then
    Result := False
  else
    Result := (pt.Nestings.GetLevel(nlRoundBracket) > 0);
end;


function SquareBracketLevel(const pt: TSourceToken): integer;
begin
  if pt = nil then
    Result := 0
  else
    Result := pt.Nestings.GetLevel(nlSquareBracket);
end;

function AllBracketLevel(const pt: TSourceToken): integer;
begin
  Result := RoundBracketLevel(pt) + SquareBracketLevel(pt);
end;

function BlockLevel(const pt: TSourceToken): integer;
begin
  if pt = nil then
    Result := 0
  else
    Result := pt.Nestings.GetLevel(nlBlock);
end;

function SemicolonNext(const pt: TSourceToken): boolean;
var
  lcNext: TSourceToken;
begin
  Result := False;

 if pt <> nil then
 begin
  lcNext := pt.NextSolidToken;
  if lcNext <> nil then
    Result := (lcNext.TokenType = ttSemiColon);
 end;
end;

function InStatements(const pt: TSourceToken): Boolean;
begin
  Result := pt.HasParentNode(nStatementList) or pt.HasParentNode(nBlock);
  Result := Result and (not pt.HasParentNode(nAsm));
end;

function InProcedureDeclarations(const pt: TsourceToken): Boolean;
begin
  Result := (pt.HasParentNode(ProcedureNodes) and (pt.HasParentNode(InProcedureDeclSections)))
end;

function InDeclarations(const pt: TsourceToken): Boolean;
begin
  Result := (not InStatements(pt)) and (not pt.HasParentNode(nAsm)) and
    pt.HasParentNode(nDeclSection);
end;

function IsLabelColon(const pt: TSourceToken): boolean;
begin
  Result := (pt.TokenType = ttColon) and pt.HasParentNode(nStatementLabel, 1);
end;


function IsCaseColon(const pt: TSourceToken): boolean;
begin
  Result := (pt.TokenType = ttColon) and pt.HasParentNode(nCaseLabels, 1);
end;

function IsFirstSolidTokenOnLine(const pt: TSourceToken): boolean;
begin
  Result := pt.IsSolid and (pt.SolidTokenOnLineIndex = 0);
end;

function IsUnaryOperator(const pt: TSourceToken): boolean;
begin
  Result := (pt <> nil) and (pt.TokenType = ttOperator) and
    (pt.Word in PossiblyUnarySymbolOperators);
  if not Result then
    exit;

  { now must find if there is another token before it,
    ie true for the minus sign in '-2' but false for '2-2' }

  Result := pt.HasParentNode(nUnaryOp, 1);
end;

function InFormalParams(const pt: TSourceToken): boolean;
begin
  Result := (RoundBracketLevel(pt) = 1) and pt.HasParentNode(nFormalParams);
end;

function IsActualParamOpenBracket(const pt: TSourceToken): boolean;
begin
  Result := (pt.TokenType = ttOpenBracket) and (pt.HasParentNode(nActualParams, 1));
end;

function IsFormalParamOpenBracket(const pt: TSourceToken): boolean;
begin
  Result := (pt.TokenType = ttOpenBracket) and (pt.HasParentNode(nFormalParams, 1));
end;


function IsMultiLineComment(const pcToken: TSourceToken): boolean;
begin
  Result := False;

  if pcToken.TokenType <> ttComment then
    exit;

  // double-slash coments are never multiline
  if (pcToken.CommentStyle = eDoubleSlash) then
    exit;

  if (Pos (AnsiLineBreak, pcToken.SourceCode) <= 0) then
    exit;

  Result := True;
end;

function IsLineBreaker(const pcToken: TSourceToken): boolean;
begin
  Result := (pcToken.TokenType = ttReturn) or IsMultiLineComment(pcToken);
end;

{ count the number of identifiers in the var decl
  e.g. "var i,j,k,l: integer" has 4 vars
}
function VarIdentCount(const pcNode: TParseTreeNode): integer;
var
  lcIdents: TParseTreeNode;
begin
  Result := 0;
  if pcNode.NodeType <> nVarDecl then
    exit;

  { the ident list is an immediate child of the var node }
  lcIdents := pcNode.GetImmediateChild(nIdentList);
  Assert(lcIdents <> nil);

  Result := IdentListNameCount(lcIdents);
end;

function IdentListNameCount(const pcNode: TParseTreeNode): integer;
var
  liLoop: integer;
  lcLeafItem: TParseTreeNode;
begin
  Result := 0;
  if pcNode.NodeType <> nIdentList then
    exit;

  {and uner it we find words (names), commas and assorted white space
   count the names }
  for liLoop := 0 to pcNode.ChildNodeCount - 1 do
  begin
    lcLeafItem := pcNode.ChildNodes[liLoop];
    if (lcLeafItem is TSourceToken) and
      (TSourceToken(lcLeafItem).TokenType = ttWord) then
        inc(Result);
  end;
end;

end.