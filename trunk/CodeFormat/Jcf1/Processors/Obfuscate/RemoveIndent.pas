unit RemoveIndent;

{ AFS 8 May 2K
  This obfuscator is useful when the "remove white space" is not engaged
  ie not a complete obfusctae
  It is intended to remove all leading sapces,
  leaving all lines flush against the left hand side
}

interface

uses Token, TokenSource;

type

  TRemoveIndent = class(TBufferedTokenProcessor)
  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  end;

implementation

uses TokenType;

{ TRemoveIndent }

function TRemoveIndent.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and Settings.Obfuscate.RemoveIndent;
end;

function TRemoveIndent.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := pt.TokenType = ttReturn;
end;

function TRemoveIndent.OnProcessToken(const pt: TToken): TToken;
var
  lcNext: TToken;
begin
  Result := pt;
  { remove all spaces after the return }
  lcNext := BufferTokens(0);
  while lcNext.TokenType = ttWhiteSpace do
    begin
      RemoveBufferToken(0);
    lcNext := BufferTokens(0);
  end;
end;

end.