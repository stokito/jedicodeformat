unit WarnRealType;

{ AFS 13 May 2K
 The first and simplest warner
}

interface

uses TokenType, Token, Warn;

type 
  TWarnRealType = class(TWarn)
  private
  protected
    function OnProcessToken(const pt: TToken): TToken; override;

  public

  end;

implementation

uses
    { delphi } SysUtils,
    { local } WordMap;

{ TWarnRealType }


function TWarnRealType.OnProcessToken(const pt: TToken): TToken;
const
  REAL_WARNING = ' This type is obsolete and is seldom useful. ' +
    'See the help for details';
begin
  Result := pt;

  if not (pt.DeclarationSection = dsVar) then
    exit;

  { see your help on 'real' for details.
   I don't know any reason to prefer these types to 'Double'

   If the code was orignally Delphi V1, then it may be better of as "Currency"
   }

  if pt.word = wReal then
  begin
    LogWarning(pt, 'Real type used.' + REAL_WARNING);
  end
  else if pt.word = wReal48 then
  begin
    LogWarning(pt, 'Real48 type used.' + REAL_WARNING);
  end;
end;

end.
































































































































