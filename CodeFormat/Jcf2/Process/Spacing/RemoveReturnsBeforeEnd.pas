unit RemoveReturnsBeforeEnd;

interface

uses SourceToken, SwitchableVisitor, VisitParseTree;


type
  TRemoveReturnsBeforeEnd = class(TSwitchableVisitor)
    protected
      procedure EnabledVisitSourceToken(const pcNode: TObject; var prVisitResult: TRVisitResult); override;

    public
      constructor Create; override;
  end;

implementation

uses FormatFlags, TokenType, WordMap, ParseTreeNodeType, TokenUtils;

{ TRemoveReturnsBeforeEnd }

constructor TRemoveReturnsBeforeEnd.Create;
begin
  inherited;
end;

procedure TRemoveReturnsBeforeEnd.EnabledVisitSourceToken(
  const pcNode: TObject; var prVisitResult: TRVisitResult);
var
  lcSourceToken: TSourceToken;
  lcNext: TSourceToken;
  lcTest: TSourceToken;
  liReturnCount: integer;
  liMaxReturns: integer;
begin
  lcSourceToken := TSourceToken(pcNode);

  if lcSourceToken.TokenType <> ttReturn then
    exit;

  if not InStatements(lcSourceToken) then
    exit;

  lcNext := lcSourceToken.NextTokenWithExclusions([ttWhiteSpace, ttReturn]);

  if lcNext.Word <> wEnd then
    exit;

  liReturnCount := 0;
  liMaxReturns := 2;
  lcTest := lcSourceToken;

  { remove all returns up to that point (except one) }
  while (lcTest <> lcNext) do
  begin
    if (lcTest.TokenType = ttReturn) then
    begin
      // allow two returns -> 1 blank line
      inc(liReturnCount);
      if (liReturnCount > liMaxReturns) then
      begin
        lcTest.TokenType := ttWhiteSpace;
        lcTest.SourceCode := '';
      end;
    end;
    lcTest := lcTest.NextToken;
  end;
end;

end.
