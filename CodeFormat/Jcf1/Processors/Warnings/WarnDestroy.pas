unit WarnDestroy;

{ AFS 13 May 2K

 warn of calls to obj.destroy;
}

interface

uses TokenType, Token, Warn;

type
  TWarnDestroy = class(TWarn)
  private
  protected
    function OnProcessToken(const pt: TToken): TToken; override;
  public

  end;

implementation

uses
    { delphi } SysUtils,
    { local } WordMap;

{ TWarnDestroy }


function TWarnDestroy.OnProcessToken(const pt: TToken): TToken;
var
  lt1: TToken;
begin
  Result := pt;

  {  look for:
    - in procedure body
    - dot followed by destroy
  }

  if not (pt.ProcedureSection = psProcedureBody) then
    exit;

  { Mostly Obj.Destroy should be
      Obj.Free
    or
      FreeAndNil(obj);
    or
      MyForm.Release;
  }

  if pt.TokenType = ttDot then
  begin
    lt1 := BufferTokens(0);
    if AnsiSameText(lt1.SourceCode, 'destroy') then
      LogWarning(pt, 'Destroy should not normally be called. ' +
        'You may want to use FreeAndNil(MyObj), or MyObj.Free, or MyForm.Release');
  end;
end;

end.