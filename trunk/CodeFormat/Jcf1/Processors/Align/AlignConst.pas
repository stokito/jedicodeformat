{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignConst.pas, released April 2000.
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

unit AlignConst;

{ AFS 3 Feb 2K
 Align the RHS of consecutive = signs in a const section 
}

interface

uses TokenType, Token, AlignStatements;

type

  TAlignConst = class(TAlignStatements)
  private
  protected
    { TokenProcessor overrides }
    function IsTokenInContext(const pt: TToken): boolean; override;
    function GetIsEnabled: boolean; override;

      { AlignStatements overrides }
    function TokenIsAligned(const pt: TToken): boolean; override;
    function TokenEndsStatement(const pt: TToken): boolean; override;

  public
    constructor Create; override;
  end;

implementation

uses
    { local} WordMap, FormatFlags;

{ TAlignConst }


constructor TAlignConst.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignConst];
end;

function TAlignConst.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Align.AlignConst;
end;

{ a token that ends an const block }
function TAlignConst.TokenEndsStatement(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection <> dsConst) or
    (pt.TokenType in [ttSemiColon, ttEOF, ttReservedWord]);

  // ended by a blank line
  if (pt.TokenType = ttReturn) and (pt.IndexOnLine <= 1) then
    Result := True;
end;

function TAlignConst.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.DeclarationSection = dsConst) and
    ((not Settings.Align.InterfaceOnly) or (pt.FileSection = fsInterface));
end;

function TAlignConst.TokenIsAligned(const pt: TToken): boolean;
begin
  Result := (pt.Word = wEquals);
end;

end.