unit WarnEmptyBlock;

{ AFS 20 July 2K
 warn of an enmpty block, one of
 begin..end, try..except, try..finally, except..end, finally..end
}

interface

uses TokenType, Token, Warn;

type
  TWarnEmptyBlock = class(TWarn)
  private
  protected
    function OnProcessToken(const pt: TToken): TToken; override;

  public

  end;

implementation

uses
    { delphi } SysUtils,
    { local } WordMap;

{ TWarnEmptyBlock }


function TWarnEmptyBlock.OnProcessToken(const pt: TToken): TToken;
const
  BlockStart: TWordSet   = [wBegin, wTry, wExcept, wFinally];
  ExceptionEnd: TWordSet = [wExcept, wFinally];
var
  ltNext: TToken;
begin
  Result := pt;

  {  look for:
    - in procedure body
    - block start word  }
  if not (pt.ProcedureSection = psProcedureBody) then
    exit;
  if not (pt.Word in BlockStart) then
    exit;

  ltNext := FirstSolidToken;

  { abnormal end? }
  if (ltNext.TokenType = ttEOF) then
    exit;

  if (pt.Word = wBegin) and (ltNext.Word = wEnd) then
    LogWarning(ltNext, 'Empty begin..end block');

  if (pt.Word = wTry) and (ltNext.Word in ExceptionEnd) then
    LogWarning(ltNext, 'Empty try...' + ltNext.SourceCode + ' block');

  if (pt.Word in ExceptionEnd) and (ltNext.Word = wEnd) then
    LogWarning(ltNext, 'Empty ' + pt.SourceCode + '..end block');
end;


end.