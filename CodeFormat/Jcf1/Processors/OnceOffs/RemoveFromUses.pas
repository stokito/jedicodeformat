{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is RemoveFromUses.pas, released April 2000.
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

unit RemoveFromUses;

{ AFS 10 Jan 1999
  Remove an unneeded unit form all uses clauses
}

interface

uses TokenType, Token, TokenSource;

type

  TRemoveFromUses = class(TTokenProcessor)
  private
    fiCount: integer;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

    procedure FinalSummary; override;

  end;

implementation

uses
    { delphi}  SysUtils,
    { local} WordMap;

{ TRemoveFromUses }

function IsOldUnit(psText: string): boolean;
begin
  Result := (AnsiCompareText(psText, 'ColorControls') = 0);
end;


constructor TRemoveFromUses.Create;
begin
  inherited;
  fiCount := 0;
end;

procedure TRemoveFromUses.FinalSummary;
begin
  if not Settings.Clarify.OnceOffs then
    exit;

  Log.LogMessage('Remove from uses: ' + IntToStr(fiCount) +
    ' removals were made');
end;

function TRemoveFromUses.GetIsEnabled: boolean;
begin
  Result := Settings.Clarify.OnceOffs;
end;


function TRemoveFromUses.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := False;

  { only do this in interface & implementation, ie not in program/libray uses clause }
  if not (pt.FileSection in [fsInterface, fsImplementation]) then
    exit;

  { only do this in a uses clause }
  if not pt.InUsesClause then
    exit;

  { only proceed on one of the specifed words }
  if not (pt.TokenType = ttWord) then
    exit;

  if not (IsOldUnit(pt.SourceCode)) then
    exit;

  Result := True;
end;

function TRemoveFromUses.OnProcessToken(const pt: TToken): TToken;
begin
  Result := pt;

  { throw away the word and the trailing comma }
  repeat
    Result.Free;
    Result := inherited GetNextToken;
  until (Result.TokenType <> ttComma) and (Result.TokenType <> ttWhiteSpace);

  inc(fiCount);
end;

end.