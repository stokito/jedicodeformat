unit BaseVisitor;

{ AFS 28 Dec 2002

  Base class that implments the tree node Visitor interface
}

interface

uses VisitParseTree;

type

  TBaseTreeNodeVisitor = class(TInterfacedObject, IVisitParseTree)
  public
    procedure VisitParseTreeNode(const pcNode: TObject; var prVisitResult: TRVisitResult); virtual;
    procedure VisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult); virtual;

    constructor Create; virtual;
  end;

type
  TTreeNodeVisitorType = class of TBaseTreeNodeVisitor;

implementation


// need a virtual constructor for the create-by-class-ref
constructor TBaseTreeNodeVisitor.Create;
begin
  inherited;
end;

procedure TBaseTreeNodeVisitor.VisitParseTreeNode(const pcNode: TObject; var prVisitResult: TRVisitResult);
begin
  // do nothing
end;

procedure TBaseTreeNodeVisitor.VisitSourceToken(const pcToken: TObject; var prVisitResult: TRVisitResult);
begin
  // do nothing
end;

end.