{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Pipeline.pas, released April 2000.
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

unit Pipeline;

{ AFS 3 Dec 1999
 A collection of TokenProcessors }

interface

uses
    { delphi } contnrs,
    { local } TokenSource, Token, JCFLog, JCFSettings;

type 
  TPipeline = class(TTokenProcessor)
  private
    fProcs: TObjectList;
    function Get_Item(piIndex: integer): TTokenProcessor;
  protected

    procedure SetTokenSource(const Value: TTokenSource); override;
    procedure SetSettings(const pcValue: TSettings); override;
    procedure SetLog(const Value: TLog); override;
    procedure SetGetFileName(const pcValue: TStringProc); override;
    procedure SetOnLogWarning(const pcValue: TTokenMessageProc); override;

  public
    constructor Create; override;
    destructor Destroy; override;

    function GetNextToken: TToken; override;

    procedure OnFileStart; override;
    procedure OnFileEnd; override;

    procedure OnRunStart; override;
    procedure FinalSummary; override;

    procedure Add(pcTp: TTokenProcessor); virtual;

    function Count: integer;
    function LastItem: TTokenProcessor;

    procedure SetIsEnabled;
    procedure Flush; override;

    property Items [piIndex: integer]: TTokenProcessor read Get_Item;

  end;

implementation

uses SysUtils, Dialogs;

{ TPipeline }

procedure TPipeline.Add(pcTp: TTokenProcessor);
begin
  if Count = 0 then
    pcTp.Source := Source
  else
    pcTp.Source := LastItem;

  fProcs.Add(pcTp);
end;

function TPipeline.Count: integer;
begin
  Result := fProcs.Count;
end;

constructor TPipeline.Create;
begin
  inherited;
  fProcs := TObjectList.Create;
end;

destructor TPipeline.Destroy;
begin
  FreeAndNil(fProcs);
  inherited;
end;

procedure TPipeline.Flush;
var
  liLoop: integer;
begin
  for liLoop := 0 to Count - 1 do
    Items[liLoop].Flush;
end;

function TPipeline.GetNextToken: TToken;
begin
  Result := LastItem.GetNextToken;
  Assert(Result <> nil);
end;

function TPipeline.Get_Item(piIndex: integer): TTokenProcessor;
begin
  Result := fProcs.Items[piIndex] as TTokenProcessor;
end;

function TPipeline.LastItem: TTokenProcessor;
begin
  Result := Items[Count - 1];
end;

procedure TPipeline.SetTokenSource(const Value: TTokenSource);
begin
  inherited;
  if Count > 0 then
    Items[0].Source := Value;
end;

procedure TPipeline.SetSettings(const pcValue: TSettings);
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].Settings := pcValue;
end;


procedure TPipeline.SetLog(const Value: TLog);
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].Log := Value;
end;


procedure TPipeline.FinalSummary;
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].FinalSummary;
end;

procedure TPipeline.OnFileStart;
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].OnFileStart;
end;

procedure TPipeline.OnFileEnd;
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].OnFileEnd;
end;

procedure TPipeline.OnRunStart;
var
  liLoop: integer;
begin
  inherited;

  for liLoop := 0 to Count - 1 do
    Items[liLoop].OnRunStart;
end;

procedure TPipeline.SetIsEnabled;
var
  liLoop: integer;
begin
  for liLoop := 0 to Count - 1 do
    Items[liLoop].SetIsEnabled;
end;

procedure TPipeline.SetGetFileName(const pcValue: TStringProc);
var
  liLoop: integer;
begin
  inherited;
  for liLoop := 0 to Count - 1 do
    Items[liLoop].OnGetFileName := pcValue;
end;

procedure TPipeline.SetOnLogWarning(const pcValue: TTokenMessageProc);
var
  liLoop: integer;
begin
  inherited;
  for liLoop := 0 to Count - 1 do
    Items[liLoop].OnLogWarning := pcValue;
end;


end.