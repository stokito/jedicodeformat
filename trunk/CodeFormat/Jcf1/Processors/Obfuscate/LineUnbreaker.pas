{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is LineUnbreaker.pas, released April 2000.
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

unit LineUnbreaker;

{ AFS 24 Dec 1999
 an obfuscator
  - remove all returns
}
interface

uses TokenType, Token, TokenSource;

type

  TLineUnbreaker = class(TBufferedTokenProcessor)
  private

  protected

    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public

  end;

implementation

uses
    { delphi } SysUtils;


function TLineUnbreaker.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and Settings.Obfuscate.RebreakLines;
end;


function TLineUnbreaker.OnProcessToken(const pt: TToken): TToken;
var
  ltNext1, ltNext2: TToken;
  lbNextToSpace: boolean;
begin
  Result := pt;
  
  ltNext1     := BufferTokens(0);
  ltNext2     := BufferTokens(1);

  // next1 is considered for deletion
  if (ltNext1.TokenType <> ttReturn) then
   exit;

  // if it is just after a comment like this one, then nooo
  if (pt.TokenType = ttComment) and (pt.CommentStyle = eDoubleSlash) then
    exit;

  lbNextToSpace := (ltNext2.TokenType = ttWhiteSpace) or (pt.TokenType = ttWhiteSpace);


  if lbNextToSpace then
  begin
    { return next to white space - remove it }
    RemoveBufferToken(0);
    // ltNext1 := nil; not used - but ltNext1 is now a dud pointer
  end
  else
  begin
    { return without white space. turn into a space }
    ltNext1.TokenType  := ttWhiteSpace;
    ltNext1.SourceCode := ' ';
  end;

end;



end.