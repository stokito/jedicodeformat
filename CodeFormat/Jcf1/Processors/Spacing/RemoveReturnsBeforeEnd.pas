unit RemoveReturnsBeforeEnd;

{ AFS 8 May 2K
  Processor to correct what is IMHO a commeon aethetic failing:
  blank lines before a block end (see also RemoveReturnsAfterBegin.pas)
  they are unnecessary and do not contribute to readability

  If you disagree, then turn it off
}

interface

uses Token, TokenSource;

type 
  TRemoveReturnsBeforeEnd = class(TBufferedTokenProcessor)
  private
  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

  end;

implementation

uses WordMap, TokenType, FormatFlags;

{ TRemoveReturnsBeforeEnd }

constructor TRemoveReturnsBeforeEnd.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn];
end;

function TRemoveReturnsBeforeEnd.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.RemoveBlockBlankLines;
end;

function TRemoveReturnsBeforeEnd.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttReturn) and (pt.ProcedureSection = psProcedureBody);
end;

function TRemoveReturnsBeforeEnd.OnProcessToken(const pt: TToken): TToken;
var
  liLoop, liMax: integer;
  ptNext:        TToken;
begin
  Result := pt;

  { find the index of the next solid token }
  liMax  := 0;
  ptNext := BufferTokens(liMax);
  while ptNext.TokenType in [ttWhiteSpace, ttReturn] do
  begin
    inc(liMax);
    ptNext := BufferTokens(liMax);
  end;

  { only process if the first solid token is an end }
  if ptNext.Word <> wEnd then
    exit;

  { remove all returns up to that point -
    ie remove all returns between pt (which is a return) and the end token }
  for liLoop := liMax - 1 downto 0 do
  begin
    ptNext := BufferTokens(liLoop);
    if (ptNext.TokenType = ttReturn) then
      RemoveBufferToken(liLoop);
  end;
end;

end.