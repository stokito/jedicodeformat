{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is UsesClauseFindReplace.pas, released October 2000.
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

unit UsesClauseFindReplace;


{ AFS 14 October 2K
  - massage the uses clause. Replace specified units with others
  very similar in implementation to UsesClauseRemove }

interface

uses TokenType, Token, TokenSource;

type

  TUsesClauseFindReplace = class(TBufferedTokenProcessor)
  private
    fbHasFind: boolean;
    fiCount: integer;

    function MatchesSearch(const ps: string): Boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public

    constructor Create; override;
    procedure OnFileStart; override;
    procedure OnRunStart; override;

    procedure FinalSummary; override;

  end;

implementation

uses
  { delphi } SysUtils,
  { local } FormatFlags;


{ TUsesClauseFindReplace }

constructor TUsesClauseFindReplace.Create;
begin
  inherited;
  fbHasFind := False;
  FormatFlags := FormatFlags + [eFindReplaceUses];
end;

procedure TUsesClauseFindReplace.FinalSummary;
begin
  if fiCount > 0 then
    Log.LogMessage('Uses clause find/replace: ' + IntToStr(fiCount) + ' changes were made');
end;

function TUsesClauseFindReplace.GetIsEnabled: boolean;
begin
  Result := Settings.UsesClause.FindReplaceEnabled;
end;

function TUsesClauseFindReplace.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := False;

  { only do this in interface & implementation }
  if not (pt.FileSection in [fsInterface, fsImplementation]) then
    exit;

  { only do this in a uses clause }
  if not pt.InUsesClause then
    exit;

  Result := True;
end;

function TUsesClauseFindReplace.MatchesSearch(const ps: string): Boolean;
begin
  Result := Settings.UsesClause.Find.IndexOf(ps) >= 0;
end;

procedure TUsesClauseFindReplace.OnFileStart;
begin
  inherited;

  { reset the flag at the top of each unit }
  fbHasFind := False;
end;

procedure TUsesClauseFindReplace.OnRunStart;
begin
  inherited;

  fiCount := 0;
end;

function TUsesClauseFindReplace.OnProcessToken(const pt: TToken): TToken;
var
  ptNext: TToken;
  ptRemove: TToken;
  liBufferIndex: integer;
begin
  Result := pt;

  ptNext := FirstSolidToken;
  liBufferIndex := BufferIndex(ptNext);

  { only proceed on one of the specifed words }
  if not (ptNext.TokenType = ttWord) then
    exit;

  if not MatchesSearch(ptNext.SourceCode) then
    exit;

  if not fbHasFind then
  begin
    { first instance, convert the name }
    fbHasFind := True;
    ptNext.SourceCode :=  Settings.UsesClause.GetReplace;
    inc(fiCount);
    exit;
  end;

  { throw away the word and the trailing comma, as in uses clause remove  }
  repeat
    RemoveBufferToken(liBufferIndex);
    ptRemove := BufferTokens(liBufferIndex);
  until (ptRemove.TokenType <> ttComma) and (ptRemove.TokenType <> ttWhiteSpace);

  { now if this was the last item we have a surplus comma }
  if (pt.TokenType = ttComma) and (ptRemove.TokenType = ttSemicolon) then
  begin
    pt.Free;
    Result := RetrieveToken;
  end;
end;

end.
