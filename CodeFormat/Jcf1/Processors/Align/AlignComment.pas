{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AlignComments.pas, released October 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2001 Anthony Steele.
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

unit AlignComment;

{ AFS 26 October 2001
  Align end-line comments on successive lines
  Feature request from Francois Piette
}

interface

uses TokenType, Token, AlignStatements;

type

  TAlignComment = class(TAlignStatements)
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

{ TAlignComment }


constructor TAlignComment.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eAlignComment];
end;

function TAlignComment.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Align.AlignComment;
end;

{ a token that ends a comment }
function TAlignComment.TokenEndsStatement(const pt: TToken): boolean;
begin
  Result := (pt.TokenType in [ttReturn, ttEOF]);
end;

function TAlignComment.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (not Settings.Align.InterfaceOnly) or (pt.FileSection = fsInterface);
end;

function TAlignComment.TokenIsAligned(const pt: TToken): boolean;
var
  ltNext: TToken;
begin
  // must be a comment on one line
  Result := pt.IsSingleLineComment;
  if Result then
  begin
    // must be the last thing on the line
    ltNext := BufferTokens(BufferIndex(pt) + 1);
    Result := (ltNext <> nil) and (ltNext.TokenType = ttReturn);
  end;

end;

end.
