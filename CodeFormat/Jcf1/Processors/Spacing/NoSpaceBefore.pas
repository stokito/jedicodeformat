{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is NoSpaceBefore.pas, released April 2000.
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

unit NoSpaceBefore;

{ AFS 7 Dec 1999
  No space before certain tokens (e.g. '.' ';'
  the Colon has it's own unit }

interface

uses TokenType, Token, TokenSource;

type

  TNoSpaceBefore = class(TBufferedTokenProcessor)
  private
    fbSaveToRemoveReturn: boolean;  // this taken from NoReturnBefore

    function HasNoSpaceBefore(const pt: TToken): boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;

    procedure OnFileStart; override;
  end;

implementation


uses
    { delphi } Dialogs,
    { local } WordMap, FormatFlags;

{ TNoSpaceBefore }

const
  NoSpaceAnywhere: TTokenTypeSet = [ttSemiColon, ttDot, ttComma,
    ttCloseSquareBracket, ttCloseBracket];

constructor TNoSpaceBefore.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eRemoveSpace];
end;


procedure TNoSpaceBefore.OnFileStart;
begin
  inherited;
  fbSaveToRemoveReturn := True;
end;

function TNoSpaceBefore.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled) and Settings.Spaces.FixSpacing;
end;

function TNoSpaceBefore.HasNoSpaceBefore(const pt: TToken): boolean;
begin
  Result := False;

  if pt.TokenType in NoSpaceAnywhere then
  begin
    Result := True;
    exit;
  end;

  { hat (dereference) is unary postfix operator - so no space before it }
  if (pt.ProcedureSection = psProcedureBody) and (pt.word = wHat) then
    Result := True;
end;

function TNoSpaceBefore.IsTokenInContext(const pt: TToken): boolean;
begin
  // not safe to remove return at a comment like this
  if (pt.TokenType = ttComment) and (pt.CommentStyle = eDoubleSlash) then
    fbSaveToRemoveReturn := False
  else if (pt.TokenType <> ttReturn) then
    fbSaveToRemoveReturn := True;
  // safe again after the next return

  Result := (pt.TokenType in [ttWhiteSpace, ttReturn]) and fbSaveToRemoveReturn;
end;

function TNoSpaceBefore.OnProcessToken(const pt: TToken): TToken;
var
  fcNext: TToken;
begin
  Result := pt;

  { inspect the next token }
  fcNext := BufferTokens(0);
  if HasNoSpaceBefore(fcNext) then
  begin
    pt.Free; // discard the space
    Result := RetrieveToken; // is fcNext, but this will clear it from the buffer
  end;
end;

end.

