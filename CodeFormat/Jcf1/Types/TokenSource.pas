{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TokenSource.pas, released April 2000.
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

unit TokenSource;

{ AFS 29 Novemeber 1999
  Token processing base classes
  Refactored in Feb 2K
  }

interface

uses
    { delphi } Contnrs,
    { local } TokenType, Token, JCFLog, JCFSettings, WordMap, FormatFlags;

type

  TStringProc = function: string of object;
  TTokenMessageProc = procedure(const ps: string) of object;

  { This base class defines a simple interface
  for a tokeniser or token transformer can emit tokens }

  TTokenSource = class(TObject)
  private
    fcSettings: TSettings;
    fcGetFileName: TStringProc;
    fcOnLogWarning: TTokenMessageProc;
    feFormatFlags: TFormatFlags;

  protected
    { property settors are virtual protected so that child classes can override them }
    procedure SetSettings(const Value: TSettings); virtual;
    procedure SetGetFileName(const Value: TSTringProc); virtual;
    procedure SetOnLogWarning(const pcValue: TTokenMessageProc); virtual;

    function RetrieveToken: TToken; virtual;
    function ProcessToken(pt: TToken): TToken; virtual;

    function OriginalFileName: string;

  public
    constructor Create; virtual;
    function GetNextToken: TToken; virtual;

    function FilePlace(const pt: TToken): string;

    // events

    // when starting a file
    procedure OnFileStart; virtual;
    procedure OnFileEnd; virtual;

    // when starting a batch of files
    procedure OnRunStart; virtual;
      // override to log a message on completion
    procedure FinalSummary; virtual;

    property Settings: TSettings read fcSettings write SetSettings;
    property FormatFlags: TFormatFlags read feFormatFlags write feFormatFlags;

    // processsors need to know the file name to put it in comments etc
    property OnGetFileName: TStringProc read fcGetFileName write SetGetFileName;
    property OnLogWarning: TTokenMessageProc read fcOnLogWarning write SetOnLogWarning;
  end;

  { a token processor takes in tokens from the last processor,
  and spits them out to the next one }

  TTokenProcessor = class(TTokenSource)
  private
    { pointers to outside objects }
    fcTokenSource: TTokenSource;
    fcLog: TLog;

    { working data }
    fbEnabled: boolean;

  protected
    fiResume: integer;
    fbFormatsAsm: Boolean;

    { property settors are virtual protected so that child classes can override them }
    procedure SetTokenSource(const Value: TTokenSource); virtual;
    procedure SetLog(const Value: TLog); virtual;

      { use these to turn off your processor }
    function GetIsEnabled: boolean; virtual; // for all tokens due to settings
    function IsTokenInContext(const pt: TToken): boolean; virtual;
      // for some tokens due to token type

    function RetrieveToken: TToken; override;
    function ProcessToken(pt: TToken): TToken; override;

    function OnProcessToken(const pt: TToken): TToken; virtual;

    procedure LogWarning(const pt: TToken; const ps: string);
      { typical child classes override as follows (cut&paste this)

    function GetIsEnabled: Boolean; override;
    function IsTokenInContext (const pt: TToken): Boolean; override;
    function OnProcessToken (const pt: TToken): TToken; override;
    }


  public
    constructor Create; override;

    procedure Flush; virtual;
    procedure OnFileEnd; override;
    procedure OnFileStart; override;

    procedure SetIsEnabled;

    property Source: TTokenSource read fcTokenSource write SetTokenSource;
    property Log: TLog read fcLog write SetLog;
    property FormatsAsm: Boolean read fbFormatsAsm write fbFormatsAsm;
  end;

  TTokenProcessorType = class of TTokenProcessor;

  TBufferedTokenProcessor = class(TTokenProcessor)
  private
    fcList: TObjectList;

  public
    constructor Create; override;
    destructor Destroy; override;

    function RetrieveToken: TToken; override;
    procedure Flush; override;

    procedure SetBufferLength(piLen: integer);
    procedure AddTokenToFrontOfBuffer(const pt: TToken);
    procedure InsertTokenInBuffer(piIndex: integer; const pt: TToken);
    procedure RemoveBufferToken(piIndex: integer);

    procedure InsertReturnInBuffer;

    function Count: integer;
    function BufferTokens(piIndex: integer): TToken;
    function BufferIndex(const pt: TToken): integer;

    function NextSolidTokenAfter(const pt: TToken): TToken;

    function GetBufferTokenWithExclusions(var piIndex: integer;
      psExlusions: TTokenTypeSet): TToken;
    function FirstSolidToken: TToken;
    function SemicolonNext: boolean;
    function TokenNext(pw: TWord): boolean; overload;
    function TokenNext(pt: TTokenType): boolean; overload;
    function TokenNext(pst: TTokenTypeSet): boolean; overload;

  end;

implementation

uses
  { delphi } SysUtils;

{------------------------------------------------------------------------------
  token source }


constructor TTokenSource.Create;
begin
  inherited;
  fcGetFileName := nil;
  fcOnLogWarning := nil;

  //by default, format unless alll processors are turned off
  feFormatFlags := [eAllFormat];
end;

procedure TTokenSource.OnFileStart;
begin
  // do nothing - here for override
end;

procedure TTokenSource.OnFileEnd;
begin
  // do nothing - here for override
end;


procedure TTokenSource.OnRunStart;
begin
  // do nothing - here for override
end;

procedure TTokenSource.FinalSummary;
begin
  // do nothing - here for override
end;

procedure TTokenSource.SetSettings(const Value: TSettings);
begin
  fcSettings := Value;
end;

procedure TTokenSource.SetGetFileName(const Value: TSTringProc);
begin
  fcGetFileName := Value;
end;

function TTokenSource.GetNextToken: TToken;
begin
  Result := RetrieveToken;
  Assert(Result <> nil);
  Result := ProcessToken(Result);
  Assert(Result <> nil);
end;

function TTokenSource.ProcessToken(pt: TToken): TToken;
begin
  // override this

  // no processing
  Result := pt;
end;

function TTokenSource.RetrieveToken: TToken;
begin
  // override this
  Result := nil;
  Assert(False, 'TTokenSource.RetrieveToken not overriden in' + ClassName);
end;

{------------------------------------------------------------------------------
  token processor }


constructor TTokenProcessor.Create;
begin
  inherited;
  fcTokenSource := nil;
  fcSettings    := nil;

  fbFormatsASM := False;
end;

procedure TTokenProcessor.SetIsEnabled;
begin
  { call a virtual method & store the result }
  fbEnabled := GetIsEnabled;
end;


function TTokenProcessor.GetIsEnabled: boolean;
begin
  // override to look at your settings
  Result := True;
end;


procedure TTokenProcessor.OnFileStart;
begin
  inherited;
  fiResume := 0;
end;

procedure TTokenProcessor.OnFileEnd;
begin
  Flush;
end;

procedure TTokenProcessor.SetLog(const Value: TLog);
begin
  fcLog := Value;
end;

procedure TTokenProcessor.SetTokenSource(const Value: TTokenSource);
begin
  fcTokenSource := Value;
end;

procedure TTokenProcessor.Flush;
begin
  // nothing to do here
end;

{ should not need to override this in a user class  }
function TTokenProcessor.RetrieveToken: TToken;
begin
  Assert(Source <> nil);
  Result := Source.GetNextToken;
  Assert(Result <> nil);
end;

function TTokenProcessor.ProcessToken(pt: TToken): TToken;
begin
  Result := pt;

  { is this process included ? }
  if not fbEnabled then
    exit;

  if pt <> nil then
  begin
    { is the token OK to process? }

    if (FormatFlags * pt.FormatFlags) <> [] then
      exit;

    if pt.TokenIndex < fiResume then
      exit;
    if not IsTokenInContext(pt) then
      exit;

    { may have to modify this bit if some later classes do actually format ASM
     anyway the rest of them should still be exclused at the base class }

    if pt.ASMBlock and not FormatsASM then
      exit;

    // child classes do thier work in here
    Result := OnProcessToken(pt);
  end;
end;

function TTokenProcessor.IsTokenInContext(const pt: TToken): boolean;
begin
  { overide to ignore tokens that the processor doesn't even need to look at
    e.g. a procedure indenter will ignore everything outside of procs }
  Result := True;
end;

function TTokenProcessor.OnProcessToken(const pt: TToken): TToken;
begin
  // do nothing - here for override
  Result := pt;
end;

{-------------------------------------------------------------------------------
  BufferedTokenProcessor }

constructor TBufferedTokenProcessor.Create;
begin
  inherited;

  fcList := TObjectList.Create;
  fcList.OwnsObjects := False;
end;

destructor TBufferedTokenProcessor.Destroy;
begin
  FreeAndNil(fcList);
  inherited;
end;

procedure TBufferedTokenProcessor.Flush;
begin
  inherited;
  Assert(fcList <> nil);
  fcList.Clear;
end;


procedure TBufferedTokenProcessor.AddTokenToFrontOfBuffer(const pt: TToken);
begin
  fcList.Insert(0, pt);
end;

function TBufferedTokenProcessor.BufferTokens(piIndex: integer): TToken;
begin
  SetBufferLength(piIndex + 1);
  if (piIndex < Count) and (piIndex >= 0) then
    Result := fcList.Items[piIndex] as TToken
  else
    Result := nil;
end;

function TBufferedTokenProcessor.BufferIndex(const pt: TToken): integer;
var
  liLoop: integer;
begin
  Result := -1;
  for liLoop := 0 to fcList.Count - 1 do
  begin
    if BufferTokens(liLoop) = pt then
    begin
      Result := liLoop;
      break;
    end;
  end;
end;

function TBufferedTokenProcessor.NextSolidTokenAfter(const pt: TToken): TToken;
var
  liIndex: integer;
begin
  // where is this token?
  liIndex := BufferIndex(pt) + 1;

  // next solid one after that
  Result := GetBufferTokenWithExclusions(liIndex, NotSolidTokens);
end;

function TBufferedTokenProcessor.Count: integer;
begin
  Result := fcList.Count;
end;

function TBufferedTokenProcessor.GetBufferTokenWithExclusions(var piIndex: integer;
  psExlusions: TTokenTypeSet): TToken;
begin
  Result := BufferTokens(piIndex);

  while Result.TokenType in psExlusions do
  begin
    inc(piIndex);
    Result := BufferTokens(piIndex);
  end;
end;

function TBufferedTokenProcessor.FirstSolidToken: TToken;
var
  liIndex: integer;
begin
  liIndex := 0;
  Result  := GetBufferTokenWithExclusions(liIndex, NotSolidTokens);
end;


function TBufferedTokenProcessor.RetrieveToken: TToken;
var
  lcNext: TToken;
begin
  { this is what makes it buffered - if there are tokens waiting in the list,
    use them up first }

  if fcList.Count > 0 then
  begin
    Result := fcList.Items[0] as TToken;
    fcList.Delete(0);
  end
  else
    Result := inherited RetrieveToken;

  { can fix uncontextualised tokens here - context should be the same as next token }
  if not Result.HasContext then
  begin
    lcNext := BufferTokens(0);
    if (lcNext <> nil) and (lcNext.HasContext) then
      Result.CopyContextFrom(lcNext);
  end;
end;

procedure TBufferedTokenProcessor.InsertReturnInBuffer;
var
  tcBuffer: TToken;
  liCount:  integer;
begin
  { at the front,
    actually should put in after any white space so as not to
    make the new token indented without reason }
  liCount := -1;
  repeat
    inc(liCount);
    tcBuffer := BufferTokens(liCount);
  until tcBuffer.TokenType <> ttWhiteSpace;

  InsertTokenInBuffer(liCount, NewReturnToken);
end;

procedure TBufferedTokenProcessor.InsertTokenInBuffer(piIndex: integer;
  const pt: TToken);
begin
  fcList.Insert(piIndex, pt);
end;

procedure TBufferedTokenProcessor.RemoveBufferToken(piIndex: integer);
var
  lt: TToken;
begin
  Assert(fcList.Count > piIndex);
  lt := fcList.Items[piIndex] as TToken;
  fcList.Delete(piIndex);
  lt.Free;
end;

procedure TBufferedTokenProcessor.SetBufferLength(piLen: integer);
var
  fcNext: TToken;
begin
  while Count < piLen do
  begin
    fcNext := Source.GetNextToken;
    Assert(fcNext <> nil);
    // when we run out fo file, we'll get a stream of EOF tokens - not nil
    fcList.Add(fcNext);
  end;
end;

function TBufferedTokenProcessor.SemicolonNext: boolean;
begin
  Result := (FirstSolidToken.TokenType = ttSemiColon);
end;

function TBufferedTokenProcessor.TokenNext(pw: TWord): boolean;
begin
  Result := (FirstSolidToken.Word = pw);
end;

function TBufferedTokenProcessor.TokenNext(pt: TTokenType): boolean;
begin
  Result := (FirstSolidToken.TokenType = pt);
end;

function TBufferedTokenProcessor.TokenNext(pst: TTokenTypeSet): boolean;
begin
  Result := (FirstSolidToken.TokenType in pst);
end;

function TTokenSource.OriginalFileName: string;
begin
  if Assigned(fcGetFileName) then
    Result := fcGetFileName
  else
    Result := '';
end;

function TTokenSource.FilePlace(const pt: TToken): string;
begin
  Result := ExtractFileName(OriginalFileName);
  if pt.YPosition > 0 then
    Result := Result + ' line ' + IntToStr(pt.YPosition) + ': ';
end;

procedure TTokenProcessor.LogWarning(const pt: TToken; const ps: string);
var
  lsMessage: string;
begin
  lsMessage :=  FilePlace(pt) + ps;
  Log.LogWarning(lsMessage);
  Log.EmptyLine;

  if Assigned(fcOnLogWarning) then
    fcOnLogWarning(lsMessage);
end;

procedure TTokenSource.SetOnLogWarning(const pcValue: TTokenMessageProc);
begin
  fcOnLogWarning := pcValue;
end;

end.