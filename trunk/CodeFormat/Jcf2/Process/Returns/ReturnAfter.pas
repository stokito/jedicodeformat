unit ReturnAfter;

{ AFS 7 Jan 2003
  Some tokens need a return after them for fomatting
}

interface

uses SwitchableVisitor, VisitParseTree;


type
  TReturnAfter = class(TSwitchableVisitor)
    private
    protected
      procedure EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult); override;
    public
      constructor Create; override;
  end;


implementation

uses
  SysUtils,
  JclStrings,
  JcfMiscFunctions,
  TokenUtils, SourceToken, TokenType, WordMap, Nesting,
  ParseTreeNodeType, ParseTreeNode, JcfSettings, FormatFlags;

const
  WordsJustReturnAfter: TWordSet = [wBegin, wRepeat,
    wTry, wExcept, wFinally, wLabel,
    wInitialization, wFinalization, wThen, wDo];
  // can't add 'interface' as it has a second meaning :(

  { blank line is 2 returns }
  WordsBlankLineAfter: TWordSet = [wImplementation];

{ semicolons have returns after them except for a few places
   1) before and between procedure directives, e.g. procedure Fred; virtual; safecall;
   2)  property directives such as 'default' has a semicolon before it.
       Only the semicolon that ends the propery def always have a line break after it
   3) seperating fields of a const record declaration
   4) between params in a procedure declaration or header
   5) as 4, in a procedure type in a type def
}
function SemicolonHasReturn(const pt, ptNext: TSourceToken): boolean;
begin
  Result := True;

  { point 1 }
  if (ptNext.HasParentNode(nProcedureDirectives)) then
  begin
    Result := False;
    exit;
  end;

  { point 2. to avoid the return,
    the next token must still be in the same  property}
  if ptNext.HasParentNode(nProperty) and (ptNext.Word <> wProperty) then
  begin
    Result := False;
    exit;
  end;

  { point 3 }
  if pt.HasParentNode(nRecordConstant) then
  begin
    Result := False;
    exit;
  end;

  { point 4 }
  if (pt.HasParentNode(nFormalParams)) then
  begin
    Result := False;
    exit;
  end;

  { point 4, for a procedure type def }
  if pt.HasParentNode(nProcedureType) then
  begin
    Result := False;
    exit;
  end;

  { in a record type def }
  if pt.HasParentNode(nRecordType) then
  begin
    Result := True;
    exit;
  end;
end;


// does this 'end' end an object type, ie class or interface
function EndsObjectType(const pt: TSourceToken): Boolean;
begin
  Result := False;

  if pt.Word <> wEnd then
    exit;

  if (BlockLevel(pt) = 0) and pt.HasParentNode([nClassType, nInterfaceType], 1) then
      Result := True;
end;

// does this 'end' end a procedure, function or method
function EndsProcedure(const pt: TSourceToken): Boolean;
var
  lcParent: TParseTreeNode;
begin
  Result := False;

  if pt.Word <> wEnd then
    exit;

  if not pt.HasParentNode(ProcedureNodes) then
    exit;

  // is this the top 'end' of a main or contained procedure
  lcParent := pt.Parent;

  if (lcParent = nil) or (lcParent.NodeType <> nCompoundStatement) then
    exit;

  lcParent := lcParent.Parent;


  if (lcParent = nil) or (lcParent.NodeType <> nBlock) then
    exit;

  lcParent := lcParent.Parent;

  if (lcParent <> nil) and (lcParent.NodeType in ProcedureNodes) then
    Result := True;

end;


function NeedsBlankLine(const pt, ptNext: TSourceToken): boolean;
var
  lcPrev: TSourceToken;
begin
  Result := False;

  if pt = nil then
    exit;

  if pt.HasParentNode(nAsm) then
    exit;

  // form dfm comment
  if IsDfmIncludeDirective(pt) then
  begin
    Result := True;
    exit;
  end;

  if (pt.TokenType in ReservedWordTokens) and (pt.Word in WordsBlankLineAfter) then
  begin
    Result := True;
    exit;
  end;

  { 'interface', but not as a typedef, but as the section }
  if (pt.Word = wInterface) and pt.HasParentNode(nInterfaceSection, 1) then
  begin
    Result := True;
    exit;
  end;

  { semicolon that ends a proc or is between procs e.g. end of uses clause }
  if (pt.TokenType = ttSemiColon) then
  begin
    if (not pt.HasParentNode(ProcedureNodes)) and
      (BlockLevel(pt) = 0) and
      (not pt.HasParentNode(nDeclSection)) then
    begin
      Result := True;
      exit;
    end;

    { semicolon at end of block
      e.g.
       var
         A: integer;
         B: float; <- blank line here

       procedure foo;
    }
    if pt.HasParentNode([nVarSection, nConstSection]) and (ptNext.Word in ProcedureWords) then
    begin
      Result := True;
      exit;
    end;

    // at the end of type block with a proc next. but not in a class def
    if pt.HasParentNode(nTypeSection) and (ptNext.Word in ProcedureWords) and
      (not pt.HasParentNode(ObjectBodies)) then
    begin
      Result := True;
      exit;
    end;


    lcPrev := pt.PriorToken;
    { 'end' at end of type def or proc
      There can be hint directives between the type/proc and the 'end'
    }
    while (lcPrev <> nil) and (lcPrev.Word <> wEnd) and lcPrev.HasParentNode(nHintDirectives, 2) do
      lcPrev := lcPrev.PriorToken;

    if (lcPrev.Word = wEnd) and (pt.TokenType <> ttDot) then
    begin
      if EndsObjectType(lcPrev) or EndsProcedure(lcPrev) then
      begin
        Result := True;
        exit;
      end;
    end;
  end;
end;


function NeedsReturn(const pt, ptNext: TSourceToken): boolean;
begin
  Result := False;

  if (pt.TokenType = ttReturn) then
    exit;

  if (pt.TokenType in ReservedWordTokens) and (pt.Word in WordsJustReturnAfter) then
  begin
    Result := True;
    exit;
  end;

  { return after 'type' unless it's the second type in "type foo = type integer;" }
  if (pt.Word = wType) and (pt.HasParentNode(nTypeSection, 1)) and
    (not pt.IsOnRightOf(nTypeDecl, wEquals)) then
  begin
    Result := True;
    exit;
  end;

  if (pt.TokenType = ttSemiColon) then
  begin
    Result := SemicolonHasReturn(pt, ptNext);
    if Result then
      exit;
  end;

  { var and const when not in procedure parameters or array properties }
  if (pt.Word in [wVar, wThreadVar, wConst, wResourceString]) and
    pt.HasParentNode([nVarSection, nConstSection]) then
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
  if (pt.Word = wOf) and (pt.IsOnRightOf(nCaseStatement, wCase)) then
  begin
    Result := True;
    exit;
  end;

  { record varaint with of}
  if (pt.Word = wOf) and pt.HasParentNode(nRecordVariantSection, 1) then
  begin
    Result := True;
    exit;
  end;


  { label : }
  if (pt.TokenType = ttColon) and pt.HasParentNode(nStatementLabel, 1) then
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
  if IsClassDirective(pt) then
  begin
    Result := True;
    exit;
  end;

  // "TSomeClass = class(TAncestorClass)" has a return after the close brackets
  if (pt.TokenType = ttCloseBracket) and
    pt.HasParentNode([nClassHeritage, nInterfaceHeritage], 1) then
  begin
    Result := True;
    exit;
  end;

  { otherwise "TSomeClass = class" has a return after "class"
    determining features are
      -  word = 'class'
      -  immediate parent is the classtype/interfacetype tree node
      - there is no classheritage node containing the brackets and base types thereunder
      - it's not the metaclass syntax 'foo = class of bar; ' }
  if (pt.Word = wClass) and
    pt.HasParentNode([nClassType, nInterfaceType], 1) and
    not (pt.Parent.HasChildNode(nClassHeritage, 1)) and
    not (ptNext.Word = wOf) then
  begin
    Result := True;
    exit;
  end;

  { comma in exports clause }
  if (pt.TokenType = ttComma) and pt.HasParentNode(nExports) then
  begin
    Result := True;
    exit;
  end;

  { comma in uses clause of program or lib - these are 1 per line,
    using the 'in' keyword to specify the file  }
  if (pt.TokenType = ttComma) and pt.HasParentNode(nUses) and
    pt.HasParentNode(TopOfProgramSections) then
  begin
    Result := True;
    exit;
  end;

  // 'uses' in program, library or package
  if (pt.Word = wUses) and pt.HasParentNode(TopOfProgramSections) then
  begin
    Result := True;
    exit;
  end;

  if (pt.Word = wRecord) and pt.IsOnRightOf(nFieldDeclaration, ttColon) then
  begin
    Result := True;
    exit;
  end;

  { end of class heritage }
  if (pt.HasParentNode(nRestrictedType)) and
    (not pt.HasParentNode(nClassVisibility)) and
    (ptNext.HasParentNode(nClassVisibility)) then
  begin
    Result := True;
    exit;
  end;

  { return in record def after the record keyword }
  if pt.HasParentNode(nRecordType) and (pt.Word = wRecord) then
  begin
    Result := True;
    exit;
  end;

  // guid in interface
  if (pt.TokenType = ttCloseSquareBracket) and pt.HasParentNode(nInterfaceTypeGuid, 1) then
  begin
    Result := True;
    exit;
  end;

end;

constructor TReturnAfter.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAddReturn];
end;

procedure TReturnAfter.EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult);
var
  lcNext, lcCommentTest: TSourceToken;
  liReturnsNeeded: integer;
  lcSourceToken: TSourceToken;
begin
  lcSourceToken := TSourceToken(pcNode);

  { check the next significant token  }
  lcNext := lcSourceToken.NextSolidToken;
  if lcNext = nil then
    exit;


  if NeedsBlankLine(lcSourceToken, lcNext) then
    liReturnsNeeded := 2
  else if NeedsReturn(lcSourceToken, lcNext) then
    liReturnsNeeded := 1
  else
    liReturnsNeeded := 0;

  if liReturnsNeeded < 1 then
    exit;

  lcNext := lcSourceToken.NextTokenWithExclusions([ttWhiteSpace, ttComment]);
  if lcNext = nil then
    exit;

  if (lcNext.TokenType = ttReturn) then
  begin
    dec(liReturnsNeeded);

    // is there a second return?
    lcNext := lcNext.NextTokenWithExclusions([ttWhiteSpace]);
    if (lcNext.TokenType = ttReturn) then
      dec(liReturnsNeeded);
  end;

  if liReturnsNeeded < 1 then
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
  lcCommentTest := lcSourceToken.NextTokenWithExclusions([ttWhiteSpace, ttReturn]);

  if lcCommentTest = nil then
    exit;

  if (lcCommentTest.TokenType = ttComment) and (lcCommentTest.CommentStyle = eDoubleSlash) then
    exit;

  case liReturnsNeeded of
    1:
    begin
      prVisitResult.Action := aInsertAfter;
      prVisitResult.NewItem := NewReturn;
    end;
    2:
    begin
      prVisitResult.Action := aInsertAfter;
      prVisitResult.NewItem := NewReturn;
      prVisitResult.NewItem2 := NewReturn;
    end;
    else
    begin
      Assert(False, 'Too many returns' + IntToStr(liReturnsNeeded));
    end;
  end;

end;

end.