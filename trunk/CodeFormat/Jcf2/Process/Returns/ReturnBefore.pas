unit ReturnBefore;

{ AFS 10 Jan 2003
  Return before
}

interface

uses SwitchableVisitor, VisitParseTree;


type
  TReturnBefore = class(TSwitchableVisitor)
    private
      fiReturnsBefore, fiNextReturnsBefore: integer;
    protected
      procedure InspectSourceToken(const pcToken: TObject); override;

      procedure EnabledVisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult); override;
    public
      constructor Create; override;
  end;


implementation

uses
  JclStrings,
  JcfMiscFunctions, TokenUtils,
  SourceToken, TokenType, ParseTreeNode,
  WordMap, Nesting, ParseTreeNodeType, JcfSettings,
  FormatFlags;

const
  WordsReturnBefore: TWordSet =
    [wBegin, wEnd, wUntil, wElse, wTry, wFinally, wExcept];

  WordsBlankLineBefore: TWordSet =
    [wImplementation, wInitialization, wFinalization, wUses];


function NeedsBlankLine(const pt, ptNext: TSourceToken): boolean;
var
  lcNext, lcPrev: TSourceToken;
  lcParent: TParseTreeNode;
begin
  Result := (pt.Word in WordsBlankLineBefore);
  if Result then
    exit;

  { function/proc body needs a blank line
   but not in RHSEquals of type defs,
   but not in class & interface def,
   but not if precedeed by the class specified for class functions
   but not if it doesn't have a proc body

   IMHO should also have blank line before contained procs
   }

  if (pt.Word in ProcedureWords) and
    (not pt.IsOnRightOf(nTypeDecl, wEquals)) and
    (not IsClassFunction(pt)) and
    (ProcedureHasBody(pt)) then
  begin
    Result := True;
    exit;
  end;

  // form dfm comment
  if IsDfmIncludeDirective(pt) or IsGenericResIncludeDirective(pt) then
  begin
    Result := True;
    exit;
  end;

    { blank line before the words var, type or const at top level
      except for:
      type t2 = type integer; }
  if (pt.Word in Declarations) and (pt.Nestings.Total = 0) and
    (not pt.IsOnRightOf(nTypeDecl, wEquals)) then
  begin
    Result := True;
    exit;
  end;

  { start of class function body }
  if (pt.Word = wClass) and (IsClassFunction(pt)) and
    (not pt.HasParentNode(nDeclSection)) and
    (pt.HasParentNode(nImplementationSection)) then
  begin
    Result := True;
    exit;
  end;

  { interface, but not as a typedef }
  if (pt.Word = wInterface) and not (pt.HasParentNode(nTypeDecl)) then
  begin
    Result := True;
    exit;
  end;


  {
    before class/interface def with body when it's not the first type.

    e.g.
      type
        foo = integer;

        TSOmeClass = class...

    These start with a type name
   and have a parent node nTypeDecl, which in turn owns a Restircted type -> Class type
  }
  lcPrev := pt.PriorSolidToken;
  if (lcPrev <> nil) and (lcPrev.Word <> wType) and (pt.TokenType = ttWord) then
  begin
    lcParent := pt.Parent;

    if (lcParent <> nil) and (lcParent.NodeType = nTypeDecl) and
      lcParent.HasChildNode(ObjectTypes, 2) and
      lcParent.HasChildNode(ObjectBodies, 3) then
    begin
      Result := True;
      exit;
    end;

    { likewise before a record type }
    if (lcParent <> nil) and (lcParent.NodeType = nTypeDecl) and
      lcParent.HasChildNode(nRecordType, 2) and
      lcParent.HasChildNode(nFieldDeclaration, 3) then
    begin
      Result := True;
      exit;
    end;

  end;


  { end. where there is no initialization section code,
    ie 'end' is the first and only token in the init section   }
  if (pt.Word = wEnd) and
    pt.HasParentNode(nInitSection, 1) and
    (pt.Parent.SolidChildCount = 1) then
  begin
    lcNext := pt.NextSolidToken;
    if (lcNext <> nil) and (lcNext.TokenTYpe = ttDot) then
    begin
      Result := True;
      exit;
    end;
  end;
end;


function NeedsReturn(const pt, ptNext: TSourceToken): boolean;
begin
  Result := False;

  if pt = nil then
    exit;

  if pt.HasParentNode(nAsm) then
    exit;

  Result := (pt.Word in WordsReturnBefore);
  if Result = True then
    exit;

  { there is not always a return before 'type'
    e.g.
    type TMyInteger = type Integer;
    is legal, only a return before the first one

   var, const, type but not in parameter list }
  if (pt.Word in Declarations) and pt.HasParentNode(nTopLevelSections, 1)
    and (not pt.IsOnRightOf(nTypeDecl, wEquals)) then
  begin
    Result := True;
    exit;
  end;

  { procedure & function in class def get return but not blank line before }
  if (pt.Word in ProcedureWords + [wProperty]) and
    (pt.HasParentNode([nClassType, nClassType])) and
    (not IsClassFunction(pt)) then
  begin
    Result := True;
    exit;
  end;

  { nested procs get it as well }
  if (pt.Word in ProcedureWords) and (not pt.HasParentNode(nProcedureDecl)) and
    (not IsClassFunction(pt)) and
    (not pt.HasParentNode(nType)) then
  begin
    Result := True;
    exit;
  end;

  { class function }
  if (pt.Word = wClass) and pt.HasParentNode(nProcedureDecl) then
  begin
    Result := True;
    exit;
  end;

  { access specifiying directive (private, public et al) in a class def }
  if pt.HasParentNode(nClassType) and IsClassDirective(pt) then
  begin
    Result := True;
    exit;
  end;

  { return before 'class' in class function }
  if (pt.Word = wClass) and pt.HasParentNode(ProcedureHeadings) and
    (RoundBracketLevel(pt) < 1) then
  begin
    Result := True;
    exit;
  end;

  { "uses UnitName in 'File'" has a blank line before UnitName }
  if (pt.TokenType = ttWord) and (pt.HasParentNode(nUses)) and (ptNext.Word = wIn) then
  begin
    Result := True;
    exit;
  end;

  // guid in interface
  if (pt.TokenType = ttOpenSquareBracket) and pt.HasParentNode(nInterfaceTypeGuid, 1) then
  begin
    Result := True;
    exit;
  end;

end;

constructor TReturnBefore.Create;
begin
  inherited;
  fiReturnsBefore := 0;
  fiNextReturnsBefore := 0;
  FormatFlags := FormatFlags + [eAddReturn];
end;

procedure TReturnBefore.EnabledVisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult);
var
  lcSourceToken: TSourceToken;
  lcNext: TSourceToken;
  liReturnsNeeded: integer;
begin
  lcSourceToken := TSourceToken(pcToken);
  lcNext := lcSourceToken.NextToken;
  if lcNext = nil then
    exit;

  liReturnsNeeded := 0;

  if NeedsBlankLine(lcSourceToken, lcNext) then
    liReturnsNeeded := 2
  else if NeedsReturn(lcSourceToken, lcNext) then
    liReturnsNeeded := 1;


  { number to insert = needed - actual }
  liReturnsNeeded := liReturnsNeeded - fiReturnsBefore;

  if liReturnsNeeded > 0 then
  begin

    case liReturnsNeeded of
      1:
      begin
        prVisitResult.Action := aInsertBefore;
        prVisitResult.NewItem := NewReturn;
      end;
      2:
      begin
        prVisitResult.Action := aInsertBefore;
        prVisitResult.NewItem := NewReturn;
        prVisitResult.NewItem2 := NewReturn;
      end;
      else
      begin
        Assert(False, 'Too many returns');
      end;
    end;
  end;

end;

procedure TReturnBefore.InspectSourceToken(const pcToken: TObject);
var
  lcSourceToken: TSourceToken;
begin
  {
    inspect the tokens as they go past
    this is a running total, that is affeced by returns & non-white-space chars
   A comment line is as good as a blank line for this

    if we encounter the tokens <return> <spaces> <word-needing-return before> the flag must be set true
   }
   fiReturnsBefore := fiNextReturnsBefore;

  lcSourceToken := TSourceToken(pcToken);

  if (lcSourceToken.TokenType = ttReturn) then
    inc(fiNextReturnsBefore)
  else if not (lcSourceToken.TokenType in [ttReturn, ttWhiteSpace, ttComment]) then
    fiNextReturnsBefore := 0;

end;

end.