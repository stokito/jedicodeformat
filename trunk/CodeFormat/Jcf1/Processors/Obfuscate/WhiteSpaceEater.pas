{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is WhiteSpaceEater.pas, released April 2000.
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

unit WhiteSpaceEater;

{ AFS 24 Dec 1999
 an obfuscator
  - all white space becomes a single space
}

interface

uses TokenType, Token, TokenSource;

type

  TWhiteSpaceEater = class(TTokenProcessor)
  private

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public

  end;

implementation

uses
    { delphi } SysUtils;

{ TWhiteSpaceEater }
function TWhiteSpaceEater.GetIsEnabled: boolean;
begin
  Result := Settings.Obfuscate.Enabled and Settings.Obfuscate.RemoveWhiteSpace;
end;

function TWhiteSpaceEater.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttWhiteSpace);
end;

function TWhiteSpaceEater.OnProcessToken(const pt: TToken): TToken;
begin
  pt.SourceCode := ' ';
  Result        := pt;
end;

end.