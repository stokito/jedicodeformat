{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is PropertyOnOneLine.pas, released July 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved.
Contributor(s): Anthony Steele. 

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations 
under the License.
------------------------------------------------------------------------------*)
{*)}

unit PropertyOnOneLine;

{ AFS 30 April 2001
  Borland style is to put a property entirely on one line
 }

interface

uses TokenType, Token, TokenSource;

type

  TPropertyOnOneLine = class(TBufferedTokenProcessor)
  private

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

  end;

implementation

uses FormatFlags;

constructor TPropertyOnOneLine.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveReturn, eRemoveSpace];
end;


function TPropertyOnOneLine.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Returns.RemovePropertyReturns;
end;

function TPropertyOnOneLine.IsTokenInContext(const pt: TToken): boolean;
begin
  { use this when in a class def. body }
  Result := pt.ClassDefinitionSection in AccessSpecifierSections;
end;

function TPropertyOnOneLine.OnProcessToken(const pt: TToken): TToken;
var
  lcNext:  TToken;
  liIndex: integer;
begin
  Result := pt;

  // never remove a return at the end of a comment like this one! ->
  if (pt.TokenType = ttComment) and (pt.CommentStyle = eDoubleSlash) then
    exit;

  liIndex := 0;
  lcNext  := BufferTokens(0);

  while (lcNext.TokenType in [ttReturn, ttWhiteSpace]) and lcNext.InPropertyDefinition do
  begin
    if (lcNext.TokenType = ttReturn) then
      RemoveBufferToken(liIndex)
    else
    begin
      if lcNext.TokenType = ttWhiteSpace then
        lcNext.SourceCode := ' '; //reduce to a single space
      inc(liIndex);
    end;

    lcNext := BufferTokens(liIndex);
  end;
end;

end.
