{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is LineBreaker.pas, released April 2000.
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

unit LineBreaker;

{ AFS 2 April 2k
  Better line breaking algorythm to split long lines at
 aethetically pleasing & readable places

 The concept is:
 Find the start of the line, read forward to the end of the line.
 If the line does not run on, nothing to do.
 If the line does run on, asign a score to every token on the line
 break after the token with the highest score
 Look at the code for scoring.
}


interface

uses Token, TokenType, TokenSource, IntList;

type


  TLineBreaker = class(TBufferedTokenProcessor)
  private
    lcScores: TIntList;
    fiIndexOfFirstSolidToken: integer;

    function PositionScore(piIndex, piPos: integer): integer;
    procedure ScoreToken(const pt: TToken; piIndex: integer; const pcScores: TIntList);
    procedure FixPos(piStart, piEnd: integer);

  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure OnFileStart; override;
  end;

implementation

uses
    {delphi } SysUtils,
    { local } WordMap, FormatFlags;

{ TLineBreaker }

constructor TLineBreaker.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eLineBreaking];

  lcScores := TIntList.Create;
end;

destructor TLineBreaker.Destroy;
begin
  FreeAndNil(lcScores);
  inherited;
end;

procedure TLineBreaker.OnFileStart;
begin
  if lcScores <> nil then
    lcScores.Clear;
  fiIndexOfFirstSolidToken := 0;
end;

function TLineBreaker.GetIsEnabled: boolean;
begin
  Result := Settings.Returns.RebreakLines and not Settings.Obfuscate.Enabled;
end;

function TLineBreaker.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.TokenType = ttReturn);

  { never break lines in program uses clause - this is generated code }
  if Result and pt.InUsesClause and (pt.FileSection = fsProgram) then
    Result := False;
end;

function TLineBreaker.OnProcessToken(const pt: TToken): TToken;
const
  DONT_BOTHER_CHARS = 2;
var
  lt: TToken;
  liCount, liLoop, liWidth: integer;
  lcBreakToken: TToken;
  liPlaceToBreak, liWidthRemaining: integer;
  lbFound: boolean;
begin
  Result := pt;

  { read until the next return  - how long is this line? }
  liCount := 0;
  liWidth := 0;
  fiIndexOfFirstSolidToken := -1;
  lbFound := False;
  while not lbFound do
  begin
    lt := BufferTokens(liCount);

    if (lt.TokenType in [ttEOF, ttReturn]) then
      lbFound := True
    else
    begin
      { record which one starts the line - don;t want to break before it }
      if (lt.TokenType <> ttWhiteSpace) and (fiIndexOfFirstSolidToken = -1) then
        fiIndexOfFirstSolidToken := liCount;

      Inc(liCount);
      liWidth := liWidth + Length(lt.SourceCode);
    end;
  end;

  { if the line does not run on, exit now }
  if liWidth < Settings.Returns.MaxLineLength then
    exit;

  { -------------
    scoring }

  { Set up scores - first the basics just for poistion on the line }
  lcScores.Clear;
  liWidth := 0;

  for liLoop := 0 to liCount - 1 do
  begin
    lt := BufferTokens(liLoop);
    lcScores.Add(PositionScore(liLoop, liWidth));
    liWidth := liWidth + Length(lt.SourceCode);
  end;

  { modify the weights. This is what will make it work -
   it is better to break line at some syntax than at other }
  for liLoop := 0 to liCount - 1 do
  begin
    lt := BufferTokens(liLoop);
    ScoreToken(lt, liLoop, lcScores);
  end;

  { Where shall we break, if anywhere? }
  liPlaceToBreak := lcScores.IndexOfMax;

  { ignore the error conditions
   - is the break place before the first non-space token? }
  if (liPlaceToBreak < fiIndexOfFirstSolidToken) then
    exit;
  { - is it at the end of the line already, just before the existing return?}
  if (liPlaceToBreak >= (liCount - 1)) then
    exit;

  { check if the program has made a bad decision,
    e.g. the only thing on the line is a *really* long string constant and it's semicolon
    The program must break because the line is too long,
    so only place it can break lines is before the semicolon }
  lcBreakToken := BufferTokens(liPlaceToBreak + 1);
  liWidthRemaining := liWidth - lcBreakToken.XPosition;
  if liWidthRemaining <= DONT_BOTHER_CHARS then
    exit;

  InsertTokenInBuffer(liPlaceToBreak + 1, NewReturnToken);
  { the tokens in the buffer past liPlaceToBreak now have the wrong Xpos }
  FixPos(liPlaceToBreak + 1, liCount);
end;

function TLineBreaker.PositionScore(piIndex, piPos: integer): integer;
const
  WIDTH_SCORE_FACTOR = 5;
  TO_FAR_SCORE_FACTOR = 5;
  FAR_TO_FAR_SCORE_FACTOR = 0.3;
  NOGO_PLACE = -100;
  PLATEAU    = 50;
  ROOFSLOPE  = 7;
var
  liEffectiveWidth: integer;
  liMidPoint, liThreeQuarterPoint: integer;
  liClose:    integer;
  liOverFlow: integer;
  fUnderflow: double;
begin
  if piIndex < fiIndexOfFirstSolidToken then
  begin
    Result := NOGO_PLACE;
    exit;
  end;

  { middle of the actual line (ie from first token pos to max length) }
  liEffectiveWidth := Settings.Returns.MaxLineLength - fiIndexOfFirstSolidToken;
  liMidPoint       := (liEffectiveWidth div 2) + fiIndexOfFirstSolidToken;

  if piPos < liMidPoint then
  begin
    { slope up evenly over the first half }
    Result := NOGO_PLACE + ((PLATEAU - NOGO_PLACE) * piPos * 2) div liEffectiveWidth;
  end
  else if piPos <= Settings.Returns.MaxLineLength then
  begin
    { relatively flat plateau, slight bump in the middle }
    liThreeQuarterPoint := (liEffectiveWidth * 3 div 4) + fiIndexOfFirstSolidToken;
    { how close to it }
    liClose := (liEffectiveWidth div 4) - abs(piPos - liThreeQuarterPoint) + 1;
    Assert(liClose >= 0);

    Result := PLATEAU + (liClose div ROOFSLOPE);
  end
  else
  begin
    { past the end}
    liOverFlow := piPos - Settings.Returns.MaxLineLength;
    Result     := PLATEAU - (liOverFlow * TO_FAR_SCORE_FACTOR);
    if Result < NOGO_PLACE then
    begin
      fUnderflow := NOGO_PLACE - Result;
      { must make is slightly lower the further we go -
      otherwise the last pos is found in lines that are far too long with no good place to break
      eg lines that start with a very long text string }
      Result     := NOGO_PLACE - Round(fUnderflow * FAR_TO_FAR_SCORE_FACTOR);
    end;
  end;
end;

{ scoring - based on the current token,
  score how aestetically pleasing a line break here would be }
procedure TLineBreaker.ScoreToken(const pt: TToken; piIndex: integer;
  const pcScores: TIntList);
const
  VERY_BAD_PLACE  = -20;
  BAD_PLACE       = -10;
  SEMI_BAD_PLACE  = -5;
  SEMI_GOOD_PLACE = 5;
  GOOD_PLACE      = 10;
  EXCELLENT_PLACE = 20;
  AWESOME_PLACE   = 30;
  BRACKET_SCALE   = -8;
begin
  Assert(pt <> nil);
  Assert(pcScores <> nil);

  case pt.TokenType of

    { bad to break just before or after a dot.
      However if you must pick, break after it  }
    ttDot:
    begin
      pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
      pcScores.ChangeValue(piIndex, BAD_PLACE);
    end;
    { it is Goodish to break after a colon
      unless in a paremeter list or var declaration }
    ttColon:
    begin
      if (pt.DeclarationSection = dsVar) or (pt.ProcedureSection = psProcedureDefinition) then
      begin
        pcScores.ChangeValue(piIndex - 1, BAD_PLACE);
        pcScores.ChangeValue(piIndex, VERY_BAD_PLACE);
      end
      else
      begin
        pcScores.ChangeValue(piIndex - 1, SEMI_BAD_PLACE);
        pcScores.ChangeValue(piIndex, SEMI_GOOD_PLACE);
      end;
    end;
    { or just before close brackets or a semicolon -
      better to break after these }
    ttCloseBracket, ttCloseSquareBracket:
    begin
      pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
      pcScores.ChangeValue(piIndex, GOOD_PLACE);
    end;
    { break after the semicolon is awesome, before is terrible}
    ttSemiColon:
    begin
      pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
      pcScores.ChangeValue(piIndex, AWESOME_PLACE);
    end;
    { It is good to break after := or comma, not before }
    ttAssign, ttComma:
    begin
      pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
      pcScores.ChangeValue(piIndex, EXCELLENT_PLACE);
    end;
    ttOperator:
    begin
      { good to break after an operator (except unary operators)
      bad to break just before one }
      if pt.RHSOperand then
      begin
        pcScores.ChangeValue(piIndex, GOOD_PLACE);
        pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
      end
      else
        { dont break between unary operator and operand }
        pcScores.ChangeValue(piIndex, VERY_BAD_PLACE);
    end;

    { break before white Space, not after }
    ttWhiteSpace:
    begin
      pcScores.ChangeValue(piIndex - 1, GOOD_PLACE);
      pcScores.ChangeValue(piIndex, BAD_PLACE);
    end;

    { words }
    ttReservedWord:
    begin
      case pt.Word of
        { good to break after if <exp> then, not before
         likewise case <exp> of and while <exp> dp }
        wThen, wOf, wDo:
        begin
          pcScores.ChangeValue(piIndex - 1, VERY_BAD_PLACE);
          pcScores.ChangeValue(piIndex, AWESOME_PLACE);
        end;
        { in the unlikely event that one of these is embedded in a long line }
        wBegin, wEnd:
        begin
          // good to break before, even better to break after
          pcScores.ChangeValue(piIndex - 1, GOOD_PLACE);
          pcScores.ChangeValue(piIndex, AWESOME_PLACE);
        end;
        wConst:
        begin
          { bad to break just after const in params as it's part of the following var
            e.g. procedure Fred(const value: integer); }
          if (pt.ProcedureSection = psProcedureDefinition) and (pt.BracketLevel = 1) then
          begin
            pcScores.ChangeValue(piIndex - 1, GOOD_PLACE);
            pcScores.ChangeValue(piIndex, BAD_PLACE);
          end;
        end;
      end;
    end;
    ttReservedWordDirective:
    begin
      case pt.Word of
        { in a property def, good to break before 'read', Ok to break before 'Write'
          bad to break just after then }
        wRead:
        begin
          if pt.InPropertyDefinition then
          begin
            pcScores.ChangeValue(piIndex - 1, AWESOME_PLACE);
            pcScores.ChangeValue(piIndex, VERY_BAD_PLACE);
          end;
        end;
        wWrite, wImplements:
        begin
          if pt.InPropertyDefinition then
          begin
            pcScores.ChangeValue(piIndex - 1, EXCELLENT_PLACE);
            pcScores.ChangeValue(piIndex, VERY_BAD_PLACE);
          end;
        end;
      end;
    end;
  end; { case }

  { slightly different rules for procedure params }
  if pt.InProcedureParamList then
  begin
    case pt.Word of
      wArray, wOf:
        begin
          pcScores.ChangeValue(piIndex - 1, BAD_PLACE);
          pcScores.ChangeValue(piIndex, BAD_PLACE);
        end;
        wConst, wVar, wOut:
        begin
          pcScores.ChangeValue(piIndex - 1, GOOD_PLACE);
          pcScores.ChangeValue(piIndex, BAD_PLACE);
        end;
    end;
  end;

  { less of a good place if it is in brackets }
  pcScores.ChangeValue(piIndex,
  (pt.BracketLevel + pt.SquareBracketLevel) * BRACKET_SCALE);
end;

procedure TLineBreaker.FixPos(piStart, piEnd: integer);
var
  liLoop, liPos: integer;
  lt: TToken;
begin
  liPos := 0;
  for liLoop := piStart to piEnd do
  begin
    lt := BufferTokens(liLoop);
    lt.XPosition := liPos;

    case lt.TokenType of
      ttEOF: break;
      ttReturn: liPos := 0;
      else
        liPos := liPos + Length(lt.SourceCode);
    end;
  end;
end;

end.































































































































