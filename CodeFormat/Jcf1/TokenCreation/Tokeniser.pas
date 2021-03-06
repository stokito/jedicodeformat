{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Tokeniser.pas, released April 2000.
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

unit Tokeniser;

{ AFS 29 Nov 1999
converts the input stream of chars into a stream of tokens
}

interface

uses
  Reader, TokenType, WordMap, Token, TokenSource, JCFLog;

type

  TTokeniser = class(TTokenSource)
  private

    { property implementation }
    fcReader: TCodeReader;
    FcLog: TLog;
    fiCount: integer;

    procedure LogToken(const pc: TToken);

      { implementation of GetNextToken }
    function TryEOF(pcToken: TToken): boolean;
    function TryReturn(pcToken: TToken): boolean;

    function TryCurlyComment(pcToken: TToken): boolean;
    function TrySlashComment(pcToken: TToken): boolean;
    function TryBracketStarComment(pcToken: TToken): boolean;

    function TryWhiteSpace(pcToken: TToken): boolean;
    function TryLiteralString(pcToken: TToken): boolean;
    function TryNumber(pcToken: TToken): boolean;
    function TryHexNumber(pcToken: TToken): boolean;

    function TryAssign(pcToken: TToken): boolean;


    function TryOperator(pcToken: TToken; ch: char; pw: TWord): boolean;
    function TryPunctuation(pcToken: TToken): boolean;
    function TryWord(pcToken: TToken): boolean;

    function TrySingleCharToken(pcToken: TToken; ch: char; tt: TTokenType): boolean;

  protected

  public
    constructor Create; override;
    destructor Destroy; override;

    function GetNextToken: TToken; override;
    procedure OnFileEnd; override;

    property Reader: TCodeReader read fcReader write fcReader;
    property Log: TLog read FcLog write FcLog;
  end;


implementation

uses
    { delphi } SysUtils, Dialogs,
    { jcl } JclStrings,
    { local } SetLog;

{ TTokeniser }

constructor TTokeniser.Create;
begin
  inherited;
  fcReader := nil;
end;

destructor TTokeniser.Destroy;
begin
  inherited;
end;

function TTokeniser.GetNextToken: TToken;
var
  lcNewToken: TToken;

  procedure DoAllTheTries;
  begin
    { first look for EOF }
    if TryEOF(lcNewToken) then 
      exit;
    { then for return }
    if TryReturn(lcNewToken) then 
      exit;
    { comments }
    if TryCurlyComment(lcNewToken) then 
      exit;
    if TrySlashComment(lcNewToken) then 
      exit;
    if TryBracketStarComment(lcNewToken) then 
      exit;
    { the rest }
    if TryWhiteSpace(lcNewToken) then 
      exit;
    if TryLiteralString(lcNewToken) then 
      exit;
    if TryWord(lcNewToken) then
      exit;
    if TryNumber(lcNewToken) then 
      exit;
    if TryHexNumber(lcNewToken) then 
      exit;

    if TrySingleCharToken(lcNewToken, ';', ttSemiColon) then 
      exit;
    if TrySingleCharToken(lcNewToken, ',', ttComma) then 
      exit;
    if TrySingleCharToken(lcNewToken, '(', ttOpenBracket) then 
      exit;
    if TrySingleCharToken(lcNewToken, ')', ttCloseBracket) then 
      exit;
    if TrySingleCharToken(lcNewToken, '[', ttOpenSquareBracket) then 
      exit;
    if TrySingleCharToken(lcNewToken, ']', ttCloseSquareBracket) then 
      exit;
    if TrySingleCharToken(lcNewToken, '.', ttDot) then 
      exit;

    { attempt assign before colon }
    if TryAssign(lcNewToken) then 
      exit;
    if TrySingleCharToken(lcNewToken, ':', ttColon) then 
      exit;

    if TryOperator(lcNewToken, '^', wHat) then 
      exit;
    if TryOperator(lcNewToken, '@', wAt) then
      exit;
    if TryPunctuation(lcNewToken) then 
      exit;

    { default }
    lcNewToken.TokenType  := ttUnknown;
    lcNewToken.SourceCode := Reader.Current;
    Reader.Consume(1);
  end;

begin
  Reader.BufferLength := 1;
  lcNewToken          := TToken.Create;
  DoAllTheTries;
  Result := lcNewToken;
  LogToken(lcNewToken);
  Inc(fiCount);
end;

{-------------------------------------------------------------------------------
  worker fns for GetNextComment }

function TTokeniser.TryEOF(pcToken: TToken): boolean;
begin
  Result := False;

  if Reader.EndOfFile then
  begin
    { it is now EOF }
    pcToken.TokenType := ttEOF;
    Result            := True;
  end;
end;

function TTokeniser.TryBracketStarComment(pcToken: TToken): boolean;
begin
  Result := False;
  if not (Reader.Current = '(') then
    exit;

  Reader.BufferLength := 2;

  if Reader.BufferCharsLeft(2) <> '(*' then
    exit;

  { until *) or End of file }
  while (Reader.BufferCharsRight(2) <> '*)') and (not Reader.BufferEndOfFile) do
    Reader.IncBuffer;

  pcToken.TokenType    := ttComment;
  pcToken.CommentStyle := eBracketStar;
  pcToken.SourceCode   := Reader.ConsumeBuffer;
  Result               := True;
end;

function TTokeniser.TryCurlyComment(pcToken: TToken): boolean;
begin
  Result := False;
  if Reader.Current <> '{' then
    exit;

  { comment is ended by close-curly or by EOF (bad source) }
  while (Reader.Last <> '}') and not (Reader.BufferEndOfFile) do
    Reader.IncBuffer;

  pcToken.TokenType    := ttComment;
  pcToken.CommentStyle := eCurly;
  pcToken.SourceCode   := Reader.ConsumeBuffer;
  Result               := True;
end;

function TTokeniser.TrySlashComment(pcToken: TToken): boolean;
var
  liLen: integer;
begin
  Result := False;
  if Reader.Current <> '/' then
    exit;

  Reader.BufferLength := 2;

  { until end of line or file }
  if Reader.BufferCharsLeft(2) <> '//' then
    exit;

  while (not CharIsReturn(Reader.Last)) and (not Reader.BufferEndOfFile) do
    Reader.IncBuffer;

  liLen := Reader.BufferLength;
  if CharIsReturn(Reader.Last) then
    dec(liLen);
  Reader.BufferLength := liLen;

  pcToken.TokenType    := ttComment;
  pcToken.CommentStyle := eDoubleSlash;
  pcToken.SourceCode   := Reader.ConsumeBuffer;
  Result               := True;
end;


function TTokeniser.TryReturn(pcToken: TToken): boolean;
var
  chNext: char;
begin
  Result := False;
  if not CharIsReturn(Reader.Current) then
    exit;

  pcToken.TokenType  := ttReturn;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;

  { concat the next return char if it is not the same
    This will recognise <cr><lf> or <lf><cr>, but not <cr><cr> }

  chNext := Reader.Current;
  if CharIsReturn(chNext) and (chNext <> pcToken.SourceCode[1]) then
  begin
    pcToken.SourceCode := pcToken.SourceCode + chNext;
    Reader.Consume;
  end;
  Result := True;
end;

{ have to combine this with literal chars, as these can be mixed,
  eg 'Hello'#32'World' and #$12'Foo' are both valid strings }
function TTokeniser.TryLiteralString(pcToken: TToken): boolean;

  function TrySubString(pcToken: TToken): boolean;
  var
    lbFoundEnd: boolean;
    liLen:      integer;
    lCh:        char;
  begin
    Result := False;

    if Reader.Current <> AnsiSingleQuote then
      exit;

    { find the end of the string
      string is ended by another quote char or by return (bad source)
      but two consecutive quote chars can occur without ending the string }

    lbFoundEnd := False;

    while not lbFoundEnd do
    begin
      if not lbFoundEnd then
        Reader.IncBuffer;

      { error - end on line end or EOF }
      lCh := Reader.Last;
      if CharIsReturn(lCh) then
        lbFoundEnd := True;
      if Reader.BufferEndOfFile then
        lbFoundEnd := True;

      if (Reader.Last = AnsiSingleQuote) then
      begin
        { followed by another? }
        Reader.IncBuffer;
        if (Reader.Last <> AnsiSingleQuote) then
          lbFoundEnd := True;
      end;
    end; { while not found }

    liLen := StrLastPos(AnsiSingleQuote, Reader.Buffer);
    if liLen < 0 then
    begin
      liLen := Reader.BufferLength;
      if CharIsReturn(Reader.Last) then
        Dec(liLen);
    end;

    Assert(liLen > 0, 'Bad string' + StrDoubleQuote(Reader.Buffer));
    Reader.BufferLength := liLen;

    pcToken.SourceCode := pcToken.SourceCode + Reader.ConsumeBuffer;
    Result             := True;
  end;

  function TryLiteralChar(pcToken: TToken): boolean;
  begin
    Result := False;
    if Reader.Current <> '#' then
      exit;

    pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;

    { can be hex string, as in #$F }
    if Reader.Current = '$' then
    begin
      { eat the $ }
      pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
      Reader.Consume;

      { hexidecimal string - concat any subsequent digits }
      while (Reader.Current in AnsiHexDigits) do
      begin
        pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
        Reader.Consume;
        Result := True;
      end;
    end
    else
    begin
      { normal decimal string - concat any subsequent digits }
      while CharIsDigit(Reader.Current) do
      begin
        pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
        Reader.Consume;
        Result := True;
      end;
    end;
  end;

begin
  Result := False;

  { read any sequence of literal chars , eg #$F or #32#32  oR even #27#$1E }
  while Reader.Current in ['#', AnsiSingleQuote] do
  begin
    if Reader.Current = '#' then
    begin
      if TryLiteralChar(pcToken) then
        Result := True;
    end
    else if Reader.Current = AnsiSingleQuote then
    begin
      if TrySubString(pcToken) then
        Result := True;
    end;
  end;

  if Result then
    pcToken.TokenType  := ttLiteralString;
end;

function TTokeniser.TryWord(pcToken: TToken): boolean;

  function IsWordChar(const ch: char): boolean;
  begin
    Result := CharIsAlpha(ch) or (ch = '_');
  end;

var
  leWordType: TWordType;
  leWord:     TWord;
begin
  Result := False;

  if not IsWordChar(Reader.Current) then
    exit;

  pcToken.TokenType  := ttWord;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;

  { concat any subsequent word chars }
  while IsWordChar(Reader.Current) or CharIsDigit(Reader.Current) do
  begin
    pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;
  end;

  { try to recognise the word as built in }
  TypeOfWord(pcToken.SourceCode, leWordType, leWord);
  pcToken.TokenType := leWordType;
  pcToken.Word      := leWord;

  Result := True;
end;

function CharIsWhiteSpaceNoReturn(const ch: AnsiChar): boolean;
begin
  Result := CharIsWhiteSpace(ch) and (ch <> AnsiLineFeed) and (ch <> AnsiCarriageReturn);
end;

function TTokeniser.TryWhiteSpace(pcToken: TToken): boolean;
begin
  Result := False;
  if not CharIsWhiteSpaceNoReturn(Reader.Current) then
    exit;

  pcToken.TokenType  := ttWhiteSpace;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;

  { concat any subsequent return chars }
  while CharIsWhiteSpaceNoReturn(Reader.Current) do
  begin
    pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;
  end;

  Result := True;
end;

function TTokeniser.TryAssign(pcToken: TToken): boolean;
begin
  Result := False;

  if Reader.Current <> ':' then
    exit;

  Reader.BufferLength := 2;

  if Reader.Buffer <> ':=' then
    exit;

  pcToken.TokenType  := ttAssign;
  pcToken.SourceCode := Reader.ConsumeBuffer;
  Result             := True;
end;

function TTokeniser.TryNumber(pcToken: TToken): boolean;
begin
  Result := False;

  { recognise a number -
   they don't start with a '.' but may contain one

   a minus sign in front is considered unary operator not part of the number
   this is bourne out by the compiler considering
    '- 0.3' and -0.3' to be the same value
    and -.3 is not legal at all }

  { first one must be a digit }
  if not CharIsDigit(Reader.Current) then
    exit;

  if (Reader.Current = '.') or (Reader.Current = '-') then
    exit;

  pcToken.TokenType  := ttNumber;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;

  { concat any subsequent number chars }
  while CharIsDigit(Reader.Current) or (Reader.Current = DecimalSeparator) do
  begin
    pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;
  end;

  { scientific notation suffic, eg 3e2 = 30, 2.1e-3 = 0.0021 }

  { check for a trailing 'e' }
  if Reader.Current in ['e', 'E'] then
  begin
    // sci notation mode
    pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;

    // can be a minus or plus here
    if Reader.Current in ['-', '+'] then
    begin
      pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
      Reader.Consume;
    end;

    { exponent must be integer }
    while CharIsDigit(Reader.Current)  do
    begin
      pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
      Reader.Consume;
    end;
  end;

  Result := True;
end;

function TTokeniser.TryHexNumber(pcToken: TToken): boolean;
begin
  Result := False;

  { starts with a $ }
  if Reader.Current <> '$' then
    exit;

  pcToken.TokenType  := ttNumber;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;

  { concat any subsequent number chars }
  while (Reader.Current in AnsiHexDigits) or (Reader.Current = DecimalSeparator) do
    begin
      pcToken.SourceCode := pcToken.SourceCode + Reader.Current;
    Reader.Consume;
  end;
  Result := True;
end;


{ hat and @ always on thier own }
function TTokeniser.TryOperator(pcToken: TToken; ch: char; pw: TWord): boolean;
begin
  Result := False;
  if Reader.Current <> ch then
    exit;

  pcToken.TokenType  := ttOperator;
  pcToken.Word       := pw;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;
  Result := True;
end;

function IsPuncChar(const ch: char): boolean;
begin
  Result := False;

  if CharIsWhiteSpace(ch) then
    exit;
  if CharIsAlphaNum(ch) then
    exit;
  if CharIsReturn(ch) then
    exit;

  if CharIsControl(ch) then
    exit;

  Result := True;
end;

function TTokeniser.TryPunctuation(pcToken: TToken): boolean;


  function FollowsPunctuation(const chLast, ch: char): boolean;
  const
    { these have meanings on thier own and should not be recognised as part of the punc.
     e.g '=(' is not a punctation symbol, but 2 of them ( for e.g. in const a=(3); }
   NotFollowChars: set of char = [AnsiSingleQuote, '"', '(', '[', '{', '#', '$', '_'];

   { these can't have anything following them:
    for e.g, catch the case if a=-1 then ...
      where '=-1' should be read as '=' '-1' not '=-' '1'
      Nothing legitamtely comes after '=' AFAIK
      also a:=a*-1;
      q:=q--1; // q equals q minus minus-one. It sucks but it compiles so it must be parsed
      etc }
   SingleChars : set of char = ['=', '+', '-', '*', '/'];

  begin
    Result := False;

    if ch in NotFollowChars then
      exit;

    if chLast in SingleChars then
      exit;

    Result := IsPuncChar(ch);
  end;

var
  leWordType: TWordType;
  leWord:     TWord;
  lcLast: char;
begin
  Result := False;

  if not IsPuncChar(Reader.Current) then
    exit;

  pcToken.TokenType  := ttPunctuation;
  lcLast := Reader.Current;
  pcToken.SourceCode := lcLast;
  Reader.Consume;

  { concat any subsequent punc chars }
  while FollowsPunctuation(lcLast, Reader.Current) do
  begin
    lcLast := Reader.Current;
    pcToken.SourceCode := pcToken.SourceCode + lcLast;
    Reader.Consume;
  end;

  { try to recognise the punctuation as an operator }
  TypeOfWord(pcToken.SourceCode, leWordType, leWord);
  if leWordType = ttOperator then
  begin
    pcToken.TokenType := leWordType;
    pcToken.Word      := leWord;
  end;

  Result := True;
end;

function TTokeniser.TrySingleCharToken(pcToken: TToken; ch: char;
  tt: TTokenType): boolean;
begin
  Result := False;

  if Reader.Current <> ch then
    exit;

  pcToken.TokenType  := tt;
  pcToken.SourceCode := Reader.Current;
  Reader.Consume;
  Result := True;
end;


procedure TTokeniser.LogToken(const pc: TToken);
var
  lsType: string;
  lsError, lsFile: string;
begin
  Assert(Log <> nil);

  if pc.TokenType = ttPunctuation then
  begin
    lsError := 'Unknown punctuation token found: ' +
      StrDoubleQuote(pc.SourceCode);
    lsFile  := ' in ' + OriginalFileName;
    if lsFile <> '' then
      lsError := lsError + lsFile;
    Log.LogError(lsError);
  end;

  if Settings.Log.LogLevel = eLogTokens then
  begin
    lsType := TokenTypeToString(pc.TokenType);

    case pc.TokenType of
      ttReturn, ttWhiteSpace:
        Log.LogMessage(lsType + ', length ' + IntToStr(Length(pc.SourceCode)));
      else
        Log.LogMessage(lsType + ': ' + pc.SourceCode);
    end;
  end;
end;

procedure TTokeniser.OnFileEnd;
begin
  inherited;

  Log.LogMessage(IntToStr(fiCount) + ' tokens found');
  fiCount := 0;
end;


end.