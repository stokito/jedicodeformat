{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Writer.pas, released April 2000.
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

unit Writer;

{ AFS 28 November 1999
  Writer - final output stage of code formattter

  AFS 22 July 2K - optimised by using a string to store tokens,
  and writing the file all at once at the end
  This is best in the usual-case scenario of a file < 10k

  AFS 8 Jan 2K
  divided into TCodeWriter and TFileWriter, so that another subclass, TIDEWriter,
  can be made with the same interface for the IDW pluggin

  Now called  TCodeWriter not TWriter to avoid a name clash with Classes.Writer
  }

interface

uses TokenType, Token, TokenSource;

type
  TCodeWriter = class(TObject)
  private
    fiTokensWritten: integer;

    { properties }
    FTokenSource: TTokenSource;

    { worker procs }
    procedure SetTokenSource(const Value: TTokenSource);

  protected
    { working vars }
    fbBOF: boolean;
    fsDestText: string;

    // common to both
    procedure BeforeWrite;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    procedure Close; virtual;

    procedure WriteOut(const ch: char); overload;
    procedure WriteOut(const st: string); overload;
    procedure WriteOut(const pt: TToken); overload;

    { return True if there is more }
    function DoNextToken: boolean;
    procedure WriteAll;

    property Source: TTokenSource read FTokenSource write SetTokenSource;

    property BOF: boolean read fbBOF;
  end;

implementation
                               
uses { delphi } SysUtils,
  { local } JclStrings;

const
  MAX_TOKENS = 100000;

  { TCodeWriter }

constructor TCodeWriter.Create;
begin
  inherited;
  fbBOF           := True;
  FTokenSource    := nil;
end;

destructor TCodeWriter.Destroy;
begin
  Close;
  inherited;
end;

procedure TCodeWriter.WriteOut(const ch: char);
begin
  fsDestText := fsDestText + ch;
  fbBOF      := False;
end;

procedure TCodeWriter.WriteOut(const st: string);
begin
  //Assert(st <> #0);
  if st = #0 then
    exit;

  fsDestText := fsDestText + st;
  fbBOF      := False;
end;

procedure TCodeWriter.SetTokenSource(const Value: TTokenSource);
begin
  FTokenSource := Value;
end;

procedure TCodeWriter.WriteOut(const pt: TToken);
begin
  WriteOut(pt.SourceCode);
  inc(fiTokensWritten);
end;

function TCodeWriter.DoNextToken: boolean;
var
  lcToken: TToken;
begin
  lcToken := Source.GetNextToken;
  Assert(lcToken <> nil);

  if lcToken.TokenType <> ttEOF then
    WriteOut(lcToken);

  Result := not (lcToken.TokenType = ttEOF);
  lcToken.Free;

  { this can also be the result of parsing
    machine generated TLB.pas files
    this is piointless, give it up. }
  if fiTokensWritten > MAX_TOKENS then
    raise Exception.Create('Too many tokens (' + IntToStr(MAX_TOKENS) +
      ') in file ' +  // OutputFileName +
      ' Suspected program error. ' +
      'If you are parsing large input files, raise the limit.');
end;

procedure TCodeWriter.WriteAll;
var
  lbMore: boolean;
begin
  Assert(Source <> nil);
  lbMore := True;
  fiTokensWritten := 0;

  while lbMore do
    lbMore := DoNextToken;
end;

procedure TCodeWriter.Close;
begin
  Assert(False, ClassName + ' must override TCodeWriter.Close');
end;

procedure TCodeWriter.Clear;
begin
  fsDestText := '';
end;

procedure TCodeWriter.BeforeWrite;
var
  liRets: integer;
begin
  { a quick hack to remove trailing lines & spaces
    after the final 'end.' of the unit
    has now turned into an option }
  fsDestText := TrimRight(fsDestText);

  // don't have the settings global, but can get it from the token source
  assert(Source <> nil);
  assert(Source.Settings <> nil);
  liRets := Source.Settings.Returns.NumReturnsAfterFinalEnd;
  if liRets > 0 then
    fsDestText := fsDestText + StrRepeat(AnsiLineBreak, liRets);
end;

end.