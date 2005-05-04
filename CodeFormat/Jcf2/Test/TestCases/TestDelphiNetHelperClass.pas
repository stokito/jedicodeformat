unit TestDelphiNetHelperClass;

interface

type
TMyClass = class
  public
    procedure HelloMyClass;
  end;

  TMyClassHelper = class helper for TMyClass
  public
    procedure HelloMyClassHelper;virtual;
  end;
 
  TMyClassHelper2 = class helper(TMyClassHelper) for TMyClass
  public
    procedure HelloMyClassHelper;override;
  end;

implementation

{ TMyClass }

procedure TMyClass.HelloMyClass;
begin

end;

{ TMyClassHelper }

procedure TMyClassHelper.HelloMyClassHelper;
begin

end;

{ TMyClassHelper2 }

procedure TMyClassHelper2.HelloMyClassHelper;
begin
  inherited;

end;

end.
