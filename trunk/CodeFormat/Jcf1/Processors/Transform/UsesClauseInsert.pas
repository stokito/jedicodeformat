{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is UsesClauseRemove.pas, released October 2000.
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

unit UsesClauseInsert;


{ AFS 14 October 2K

  - massage the uses clause. Insert units if they aren't already there

 }
interface

uses
  { delphi } CLasses,
  { local } TokenType, Token, TokenSource;

type

  TUsesClauseInsert = class(TBufferedTokenProcessor)
  private
    fiCount: integer;
    fbDoneInterface, fbDoneImplementation: Boolean;
    fsInsertInterface, fsInsertImplementation: TStringList;

    procedure RemoveTodo(const psList: TStringList; const psItem: string);
    procedure AddUses(const psList: TStringList);

    procedure SetDoneSection(const fs: TFileSection);
    function DoneSection(const fs: TFileSection): Boolean;

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure OnRunStart; override;
    procedure OnFileStart; override;
    procedure FinalSummary; override;

  end;

implementation

uses
  { delphi } SysUtils,
  { local } FormatFlags;

constructor TUsesClauseInsert.Create;
begin
  inherited;
  fsInsertInterface := TStringList.Create;
  fsInsertImplementation := TStringList.Create;

  FormatFlags := FormatFlags + [eFindReplaceUses];
end;

destructor TUsesClauseInsert.Destroy;
begin
  FreeAndNil(fsInsertInterface);
  FreeAndNil(fsInsertImplementation);
  inherited;
end;

procedure TUsesClauseInsert.FinalSummary;
begin
  if fiCount > 0 then
    Log.LogMessage('Uses clause insertion: ' + IntToStr(fiCount) + ' removals were made');
end;

function TUsesClauseInsert.GetIsEnabled: boolean;
begin
  Result := Settings.UsesClause.InsertInterfaceEnabled or Settings.UsesClause.InsertImplementationEnabled;
end;

function TUsesClauseInsert.IsTokenInContext(const pt: TToken): boolean;
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

procedure TUsesClauseInsert.OnFileStart;
begin
  inherited;

  Assert(Settings <> nil);
  Assert(fsInsertInterface <> nil);
  Assert(fsInsertImplementation <> nil);

  { start with all of them needed }
  fsInsertInterface.Assign(Settings.UsesClause.InsertInterface);
  fsInsertImplementation.Assign(Settings.UsesClause.InsertImplementation);
  fbDoneInterface := False;
  fbDoneImplementation := False;
end;

procedure TUsesClauseInsert.OnRunStart;
begin
  inherited;
  fiCount := 0;
end;

function TUsesClauseInsert.OnProcessToken(const pt: TToken): TToken;
var
  ptNext: TToken;
begin
  Result := pt;
  ptNext := BufferTokens(0);

  { if this is a word, then it might be in the list of words to insert
    if so, remove it, as we don't want it in twice }
  if pt.TokenType = ttWord then
  begin
    if pt.FileSection = fsInterface then
      RemoveTodo(fsInsertInterface, pt.SourceCode)
    else if pt.FileSection = fsImplementation then
      RemoveTodo(fsInsertImplementation, pt.SourceCode);
  end;

  if (ptNext.TokenType = ttSemiColon) and not DoneSection(pt.FileSection) then
  begin
    { Reached the end - insert the rest }
    if pt.FileSection = fsInterface then
      AddUses(fsInsertInterface)
    else if pt.FileSection = fsImplementation then
      AddUses(fsInsertImplementation);

    SetDoneSection(pt.FileSection);
  end;
end;

procedure TUsesClauseInsert.RemoveTodo(const psList: TStringList;
  const psItem: string);
var
  liIndex: integer;
begin
  Assert(psList <> nil);
  Assert(psItem <> '');

  liIndex := psList.IndexOf(psItem);
  if liIndex >= 0 then
    psList.Delete(liIndex);
end;

procedure TUsesClauseInsert.AddUses(const psList: TStringList);
var
  liLoop: integer;
  liPos: integer;
  pt: TToken;
begin
  liPos := 0;

  for liLoop := 0 to psList.Count - 1 do
  begin
    pt := TToken.Create;
    pt.TokenType := ttComma;
    pt.SourceCode := ',';
    InsertTokenInBuffer(liPos, pt);
    inc(liPos);

    pt := TToken.Create;
    pt.TokenType := ttWord;
    pt.SourceCode := psList[liLoop];
    InsertTokenInBuffer(liPos, pt);
    inc(liPos);
    inc(fiCount);
  end;
end;

function TUsesClauseInsert.DoneSection(const fs: TFileSection): Boolean;
begin
  if fs = fsInterface then
    Result := fbDoneInterface
  else
    Result := fbDoneImplementation;
end;

procedure TUsesClauseInsert.SetDoneSection(const fs: TFileSection);
begin
  if fs = fsInterface then
    fbDoneInterface := True
  else
    fbDoneImplementation := True;
end;

end.

