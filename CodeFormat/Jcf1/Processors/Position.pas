{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Position.pas, released April 2000.
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

unit Position;

{ AFS 5 Feb 2K
  Code ripped from Indentation
  This sets up a token's position
 }
interface

uses TokenType, Token, TokenSource;

type

  TPosition = class(TBufferedTokenProcessor)
  private
    fxPos, fyPos: integer;
    fiIndexOnLine: integer;

  protected
    function GetIsEnabled: boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;
    procedure OnFileStart; override;

  end;

implementation

uses
  { delphi } SysUtils;

{ TPosition }

constructor TPosition.Create;
begin
  inherited;
  fbFormatsAsm := True;
end;


function TPosition.OnProcessToken(const pt: TToken): TToken;
begin
  { processing before the token }
  if not (pt.TokenType in [ttReturn, ttWhiteSpace]) then
    inc(fiIndexOnLine);

  { put data onto the token }
  pt.XPosition   := fxPos;
  pt.YPosition   := fyPos;
  pt.IndexOnLine := fiIndexOnLine;

  { processing after the token
   watch out for long comments containing returns ! }
  fxPos := fxPos + Length(pt.SourceCode);

  if pt.TokenType = ttReturn then
  begin
    inc(fyPos);
    fiIndexOnLine := 0;
    fxPos         := 0;
  end;

  Result := pt;
end;


procedure TPosition.OnFileStart;
begin
  inherited;
  fxPos := 0;
  { start on line 1. this must agree with the IDE,
    so that errors and for warnings can be found }
  fyPos := 1;
  fiIndexOnLine := 0;
end;

function TPosition.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled);
end;

end.