{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is TokenBareIndent.pas, released April 2000.
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

unit TokenBareIndent;

{ AFS 1 March  2K
 This class introduced to recognse indent on "bare" statements
 ie the statement is not a block but still needs an extra indent

 a normal nesting level is cauased by

 if fred then
 begin
   nested statement;
 end;

 a bare nesting level is caused by

 if fred then
   nested statement - bare of begin and end but still nested;
   

 see the file Testcases\TestLayoutBare.pas for examples of code that excercises this }


interface


uses TokenSource, Token, TokenType, WordMap;

type

  TTokenBareIndent = class(TBufferedTokenProcessor)
  private
    fiStartIndent: integer;
    fwBlockStart: TWordSet; // these symbols start blocks

    function BareStatementStart(const pt: TToken): boolean;
    function BareStatementEnd(const ptStart: TToken): integer;

    function HasDo: Boolean;

  protected
    function IsTokenInContext(const pt: TToken): boolean; override;

    function OnProcessToken(const pt: TToken): TToken; override;
  public
    procedure OnFileStart; override;


  end;

implementation

{ TTokenBareIndent }

// make this a setting
const
  BorlandCaseLayout = True;

function TTokenBareIndent.BareStatementEnd(const ptStart: TToken): integer;
var
  liCount: integer;
  lt:      TToken;
  lbIf, lbFound: boolean;
  lbCase, lbElseCase: Boolean;
  liIfCount: integer;
  lsEndWords: TWordSet;
begin
  { look ahead to find where this bare statement ends }
  liCount := 0;
  lbFound := False;


  { else in a clase block must end with 'end' not '; '
    e.g.
     case (foo) of
       bar:
        x :=1; // bare indent ends here
       else
         x := 2;
         y := 3;
       end; // bare indent ends here.

  }
  lsEndWords := [wEnd];

  lbCase := ptStart.CaseLabelNestingLevel;
  lbElseCase := lbCase and (ptStart.Word = wElse);
  if (ptStart.TokenType <> ttColon) and (not lbElseCase) then
    lsEndWords := lsEndWords + [wElse];



 { if Statement processing

    sometimes I think it would have been simpler to use a tree-parsing algorythym
   you can't just scan forward from the then for the first else
   because the else binds to the innermost if
   So must keep a count (liIfCount) of the if/else pairs encountered whilst looking for the end

   if a > 10 then // start here
     if b > 10 then
       Dosomething
     else // don't match here
       DoSomethingElse
   else // match here !
    DoAnotherThing;
  }

  lbIf      := (ptStart.Word in [wThen, wElse]) and not lbElseCase;
  liIfCount := 0;

  lt := BufferTokens(0);
  fiStartIndent := lt.NestingLevel;

  while not lbFound do
  begin
    lt := BufferTokens(liCount);
    inc(liCount);

    { EOF?!? look no further }
    if lt.TokenType = ttEOF then
      lbFound := True;

    { count the ifs }

    { nesting level or block nesting level? }
    if lbIf then
    begin

      { recognise a block start }
      if (lt.NestingLevel = fiStartIndent) then
      begin
        if (lt.Word = wIf) then
          inc(liIfCount);
      end;

      { recognise a block end  - use BlockNestingLevel to not count existing bare blocks ..
        works emprically, passes test cases. a parse tree would be better   }
      if (fiStartIndent >= lt.NestingLevel) then
      begin
        { if ends with an else or ; recognise semicolon before, else after
          dunno why, just works this way }
        if (lt.TokenType = ttSemiColon) then
        begin
          { dec(liIfCount) is not sufficient when the construct is
            if a then
              if b then
                stmt;

           This produces bad indenting after
           What to do? Can't just reduce by the bare token indent count

            *this is a hack*, and will most likely fail someehere
            but it has finally come to the point
            were a real parse tree is needed to fix it properly
          }
          {
          if liIfCount > 0 then
            Dec(liIfCount);
          }
          liIfCount := 0;
        end;
      end;
    end; // lbIf

    { found it ! }
    if (((lt.TokenType = ttSemiColon) and not lbElseCase) or (lt.Word in lsEndWords)) then
    begin
      if (lt.NestingLevel <= fiStartIndent) and (liIfCount <= 0) then
       lbFound := True;
    end;

    // case ends where the next case starts
    if lbCase and (lt.TokenType = ttColon) then
    begin
      if (lt.NestingLevel <= fiStartIndent) and (liIfCount <= 0) then
       lbFound := True;
    end;


    if lbIf and (lt.Word = wElse) and (lt.NestingLevel = fiStartIndent) and
      (liIfCount > 0) then
      Dec(liIfCount);

    { don't go past the proc end }
    if (lt.ProcedureSection = psNotInProcedure) then
      lbFound := True;
  end;

  { ie stop indenting just before the else or ;
     this would be (liCount - 1),
    but liCount already is the index of the token afer that  }
  Result := liCount - 2;
end;

function TTokenBareIndent.BareStatementStart(const pt: TToken): boolean;
const
  BareStatementStarters: TWordSet = [wThen, wElse, wDo];
var
  lcNext:  TToken;
  liIndex: integer;
  lbCase: boolean;
begin
  Result := False;

  if (pt.ProcedureSection <> psProcedureBody) then
    exit;

  lbCase := pt.IsCaseColon and (not HasDo);

  if (pt.Word in BareStatementStarters) or lbCase then
  begin
    liIndex := 0;
    lcNext  := GetBufferTokenWithExclusions(liIndex, [ttWhiteSpace, ttReturn, ttComment]);
    if (not (lcNext.Word in fwBlockStart)) or (Settings.Indent.BorlandCaseIndent and lbCase) then
      Result := True;

    { else if - don't indent the else clause, the if .. then takes care of that
      except for the xception where the if is not related to the if
       case foo of:
        1:
         ...
        2:
         ..
        else // else ..endis a block, 'if' not withstanding
         if ..
         
        end;
      }
    if Result and (pt.Word = wElse) and (lcNext.Word = wIf) and (not lbCase) then
      Result := False;
  end;
end;

function TTokenBareIndent.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.ProcedureSection = psProcedureBody);
end;

procedure TTokenBareIndent.OnFileStart;
begin
  inherited;
  fiStartIndent := 0;

  fwBlockStart := [wBegin];

  if Settings.Indent.TryLikeBegin then
    fwBlockStart := fwBlockStart + [wTry];

end;

function TTokenBareIndent.OnProcessToken(const pt: TToken): TToken;
var
  lt: TToken;
  liLoop, liEnd: integer;
begin
  Result := pt;

  { intent a bare block }
  if BareStatementStart(pt) then
  begin
    liEnd := BareStatementEnd(pt);

    for liLoop := 0 to liEnd do
    begin
      lt := BufferTokens(liLoop);
      lt.BareNestingLevel := lt.BareNestingLevel + 1;
    end;

    { resume on the next one,
      as the bare statmement can contain bare statements
      e.g. nested ifs }
    fiResume := pt.TokenIndex + 1;
  end;
end;

{ called when a colon is encountered 
  check if we are in an except block:
    otherwise a false positive on
  except
    on E: Exception do... }
function TTokenBareIndent.HasDo: Boolean;
var
  liIndex: integer;
  liSolid: integer;
  ptNext: TToken;
begin
  Result := False;

  { look for the 'do' 2 words after the colon }
  liIndex := 0;
  liSolid := 0;
  while liSolid < 2 do
  begin
    ptNext := BufferTokens(liIndex);
    if not (ptNext.TokenType in NotSolidTokens) then
      inc(liSolid);

    if ptNext.Word = wDo then
    begin
      Result := True;
      break;
    end;

    inc (liIndex);
  end;
end;

end.
