{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is TokenContext.pas, released April 2000.
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

unit TokenContext;

{ AFS 23 Dec 1999
 Describe the whereabouts of the token
 and put this data on each token
 so all processors will know where it came from

 }

interface

uses TokenType, Token, TokenSource, WordMap, IntList, FormatFlags;

type

  TTokenContext = class(TBufferedTokenProcessor)
  private
    feFileSection: TFileSection;
    feProcedureSection: TProcedureSection;
    feDeclarationSection: TDeclarationSection;
    feClassDefinitionSection: TClassDefinitionSection;
    feStructuredType: TStructuredType;

    { nesting level counts how much to indent, ie
      Block nesting level: inside how many begin..end blocks are we?
      Procedure nestring level: inside how many procedure bosdies are we
       (Pascal alows nested procedures)
    }
    fiBlockNestingLevel, fiProcedureNestingLevel: integer;

    fiBracketLevel, fiSquareBracketLevel: integer;
    fiCount: integer;  // count of tokens.

    // keep track of  the levels at which case statements occcut
    fcCaseLabelLevels: TIntList;

    bInUsesClause: boolean;
    fbRHSEquals: boolean;
    fbRHSAssign: boolean;
    fbRHSColon: boolean;
    fbRHSIn: boolean;
    feRHSofExpressionWord: TWord;

    fbRHSOperand: boolean;
    fbASMBlock: boolean;

    fbInPropertyDefinition: boolean;
    fbInExports: boolean;

    feFormatFlags: TFormatFlags;

    { true in class function/proc def&body can be used to distinguish the meaning of the word 'class' }

    fbClassFunction: boolean;

    { true in initialization, finalization & program/lib main body.
      These are code blocks that are like procs }

    fbImplicitBlock: boolean;

    // true if the 'forward' directive is found, meaning that this procedure header has no body
    fbForward: boolean;
    // likewise 'external' directive
    fbExternal: boolean;

    { record defs can be nested }
    fiRecordCount: integer;

    { in a record type def, a count of the number of times the word 'case'
     has been encountered }
    fiRecordCases: integer;

    { checks before token gets context }
    procedure CheckInUsesClause(const pt: TToken);
    procedure CheckFileSection(const pt: TToken);
    procedure CheckProcedureSection(const pt: TToken);
    procedure CheckDeclarationSection(const pt: TToken);
    procedure CheckClassDefinitionSection(const pt: TToken);
    procedure CheckBracketLevel(const pt: TToken);
    procedure CheckASM(const pt: TToken);
    procedure CheckForward(const pt: TToken);
    procedure CheckCaseLevel(const pt: TToken);
    procedure CheckRecordCount(const pt: TToken);

    procedure SetContextOnToken(const pt: TToken);

      { checks after token gets context }
    procedure CheckProcedureSectionAfterToken(const pt: TToken);
    procedure CheckOperand(const pt: TToken);
    procedure CheckClassHeader(const pt: TToken);
    procedure CheckEndRHS(const pt: TToken);
    procedure StartProcNestingLevel(const pt: TToken);
    procedure CheckImplicitBlocks(const pt: TToken);
    procedure CheckNestingLevel(const pt: TToken);
    procedure CheckNoFormat(const pt: TToken);
    procedure CheckRHSExpression(const pt: TToken);
    procedure CheckUsesClauseAfter(const pt: TToken);

    procedure ResetState;
    function NoBodyToProc: boolean;
    procedure SetImplicitBlock;
    function CaseCount: integer;

  protected
    { this one must be ProcessToken, not OnProcessToken
      as it sets up data needed by OnProcessToken }

    function ProcessToken(pt: TToken): TToken; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure OnFileStart; override;

  end;

implementation

uses
    { delphi } SysUtils, Dialogs;

{ TTokenContext }

constructor TTokenContext.Create;
begin
  inherited;
  fcCaseLabelLevels := TIntList.Create;
end;

destructor TTokenContext.Destroy;
begin
  FreeAndNil(fcCaseLabelLevels);
  inherited;
end;

{-------------------------------------------------------------------------------
  overrides }


procedure TTokenContext.OnFileStart;
begin
  feFileSection := fsBeforeInterface;
  ResetState;
  fiCount      := 0;
  fbClassFunction := False;
  feFormatFlags := [];
end;


function TTokenContext.ProcessToken(pt: TToken): TToken;
begin
  // things to do before setting context on this token
  CheckInUsesClause(pt);
  CheckFileSection(pt);
  CheckProcedureSection(pt);

  CheckDeclarationSection(pt);
  CheckClassDefinitionSection(pt);
  CheckBracketLevel(pt);
  CheckASM(pt);

  CheckForward(pt);
  CheckCaseLevel(pt);
  CheckRecordCount(pt);

  SetContextOnToken(pt);

  {things to do after setting up the token
  i.e. the effect that this token has on subsequent tokens }

  CheckProcedureSectionAfterToken(pt);
  CheckOperand(pt);
  CheckNestingLevel(pt);
  CheckEndRHS(pt);
  CheckClassHeader(pt);
  CheckNoFormat(pt);
  StartProcNestingLevel(pt);
  CheckRHSExpression(pt);
  CheckImplicitBlocks(pt);
  CheckUsesClauseAfter(pt);

  inc(fiCount);
  Result := pt;
end;

{-------------------------------------------------------------------------------
  worker procs }


procedure TTokenContext.ResetState;
begin
  feProcedureSection       := psNotInProcedure;
  feDeclarationSection     := dsNotInDeclaration;
  feClassDefinitionSection := cdNotInClassDefinition;
  feStructuredType         := stNotInStructuredType;

  fiBlockNestingLevel       := 0;
  fiProcedureNestingLevel := 0;
  fiBracketLevel       := 0;
  fiSquareBracketLevel := 0;

  bInUsesClause := False;
  fbRHSEquals   := False;
  fbRHSAssign   := False;
  feRHSofExpressionWord := wUnknown;
  fbRHSOperand  := False;

  fbASMBlock := False;

  fbInExports     := False;
  fbClassFunction := False;
  fbImplicitBlock := False;

  fbForward := False;
  fbExternal := False;
  fiRecordCount := 0;
  fiRecordCases := 0;

  fcCaseLabelLevels.Clear;
end;

procedure TTokenContext.SetImplicitBlock;
begin
  fbImplicitBlock    := True;
  feProcedureSection := psProcedureBody;
  fiBlockNestingLevel     := 1;
  fiProcedureNestingLevel := 1;
end;

{  How to tell if there is should be no procedure body?
    - In the interface file section there is no body
    - In a class/interface def there is no body
    - If the there was a 'forward' directive there is no body
    - If the there was a 'external' directive there is no body
    Otherwise, there must be
}

function TTokenContext.NoBodyToProc: boolean;
begin
  Result := ((feFileSection = fsInterface) or
    (feStructuredType <> stNotInStructuredType) or fbForward or fbExternal);
end;

function TTokenContext.CaseCount: integer;
begin
  Result := fcCaseLabelLevels.Count;
  if (fcCaseLabelLevels.Top > (fiBlockNestingLevel)) then
    dec(Result);
end;

{-------------------------------------------------------------------------------
  checks that happen before the token is given context }


procedure TTokenContext.CheckInUsesClause(const pt: TToken);
begin
  { uses clause stretches from the word 'uses' to the next semicolon }
  if (pt.TokenType = ttReservedWord) and (pt.Word = wUses) then
    bInUsesClause := True;

  { the word 'in' is used in uses clauses }
  if bInUsesClause then
  begin
    if pt.Word = wIn then
      fbRHSIn := True;
  end;
end;

procedure TTokenContext.CheckFileSection(const pt: TToken);
var
  leOldSection: TFileSection;
begin
  if pt.TokenType <> ttReservedWord then
    exit;

  leOldSection := feFileSection;

  { change section on these keywords }
  case pt.Word of
    wInterface:
    begin
      { interface on the RHS of an equals sign is a COM type def not a file section }
      if not fbRHSEquals then
        feFileSection := fsInterface;
    end;
    wImplementation:
      feFileSection := fsImplementation;
    wInitialization:
      feFileSection := fsInitialization;
    wFinalization:
      feFileSection := fsFinalization;
    wProgram:
      feFileSection := fsProgram;
    wLibrary:
    begin
      { curse D6 for giving this word two meanings!
        This only introduces a code lib when it is the 1st word in the unit }
      if feFileSection = fsBeforeInterface then
        feFileSection := fsLibrary;
    end;
    else
      // do nothing;
  end;

  if leOldSection <> feFileSection then
    ResetState;
end;

function InProcedureDirectives(const pt: TToken): boolean;
const
  // you can legally find these inamongst the directives 
  DirectiveTokens: TTokenTypeSet = [ttWhiteSpace, ttReturn, ttComment,
    ttReservedWordDirective, ttSemiColon, ttNumber];
begin
  { not a token or assocated white space & fomatting }
  Result := (pt.TokenType in DirectiveTokens);

  { a directive, but not one for a proc }
  if (pt.TokenType = ttReservedWordDirective) and
    (not (pt.Word in ProcedureDirectives)) then
    Result := False;
end;

procedure TTokenContext.CheckProcedureSection(const pt: TToken);

  function EndRHS: Boolean;
  begin
    Result := False;

    if (pt.Word in BlockEndWords) then
    begin
      Result := True;
      exit;
    end;

    if (pt.TokenType = ttSemiColon) and (fiBracketLevel = 0) then
    begin
      Result := True;
      exit;
    end;
  end;


begin
  if (feProcedureSection = psProcedureMap) and (pt.TokenType = ttSemiColon) then
    feProcedureSection := psNotInProcedure;

  { after procedure name (and dot), can be an equals sign
    but an equals sign inside the backets is just a default apram value }
  if (feProcedureSection = psProcedureDefinition) and (pt.Word = wEquals)
    and (fiBracketLevel = 0) then
    feProcedureSection := psProcedureMap;

  {
    after the directives (ie as soon as there is a non-directive token)
    and not expecting procedure body, end the procedure def.

    note that not all directives are for procedures.
    Particularly "private", "public" et all are not
    e.g. in the case of a class that has the text
    procedure Fred; virtual; public
    'public' is a directive but not part of the proc's directives
    }

  if (feProcedureSection = psProcedureDirectives) and
    (not InProcedureDirectives(pt)) then
  begin
    if NoBodyToProc then
    begin
      // end of proc def, no body
      feProcedureSection := psNotInProcedure;
      // rest flags that applied to that proc
      fbClassFunction    := False;
      fbForward          := False;
      fbExternal         := False;
      fiProcedureNestingLevel := 0;
    end
    else
    begin
      feProcedureSection := psProcedureDeclarations;
    end;
  end;

  { function/procedure definition/header
    stretches from that keyword to the semicolon
    (And not a semicolon in the parameter list in the brackets) }

  if (pt.Word in ProcedureWords) and ((not fbRHSEquals) or
    (feStructuredType in ObjectTypes)) then
  begin
    feProcedureSection := psProcedureDefinition;
  end;

  if (feProcedureSection = psProcedureDefinition) and (pt.TokenType = ttSemiColon) and
    (fiBracketLevel = 0) then
  begin
    feProcedureSection := psProcedureDirectives;
  end;

  if (feProcedureSection = psProcedureDirectives) and (pt.Word in Declarations) then
  begin
    { in the interface section the var & const are not part of the procedure - they are freestanding
     !! must also happen in implementation classes }

    if (feFileSection = fsImplementation) and
      (feStructuredType = stNotInStructuredType) then
      feProcedureSection := psProcedureDeclarations
    else
    begin
      feProcedureSection := psNotInProcedure;
      fbClassFunction    := False;
    end;
  end;

  { enter a procedure body on the word begin after a procedure header + local consts and vars }

  if (feProcedureSection in [psProcedureDirectives, psProcedureDeclarations]) and
    (feStructuredType = stNotInStructuredType) and
    (pt.Word in [wBegin, wASM]) and (fiBlockNestingLevel = 0) then
  begin
    feProcedureSection   := psProcedureBody;
    feDeclarationSection := dsNotInDeclaration;
    fiRecordCases := 0;
  end;

  { Must do this before conext is put onto the token }

  {a misc. test that fits into no greater scheme :(
  catch the construct
     repeat a := a + 1 until CowsComeHome;
  or even
     if fred then bVal = (a or b) else GoHomeInstead;
  or
    for e.g. if a > 12 then b := True else CallAProc;

     RHSAssign and RHSEquals stops with the else/Until/Finally/end keyword,
  }

  if EndRHS then
  begin
    fbRHSAssign := False;
    fbRHSEquals := False;
  end;
end;

procedure TTokenContext.CheckDeclarationSection(const pt: TToken);
begin
  if pt.TokenType = ttReservedWord then
  begin
    { change section on these keywords }
    case pt.Word of
      wType:
        feDeclarationSection := dsType;
      wLabel:
        feDeclarationSection := dsLabel;
      wConst:
        { const declares constants
        unless it is in a param list() or array property []
        in which case it is a var calling convention  }
        if (fiBracketLevel = 0) and (fiSquareBracketLevel = 0) then
          feDeclarationSection := dsConst;
     wResourceString:
          feDeclarationSection := dsConst;
       wVar, wThreadVar:
        if fiBracketLevel = 0 then
          feDeclarationSection := dsVar;
      wProcedure, wFunction, wConstructor, wDestructor:
      begin
        { encountering the word function/procedure ends a type/const decalration section
          except when
          - it is on the RHS of an equals sign, e.g type TFredProc = procedure (x:Integer);
          - it is in a class or interface def
        }

        if (not fbRHSEquals) and (feStructuredType = stNotInStructuredType) then
          feDeclarationSection := dsNotInDeclaration;
      end;
      wBegin:
        feDeclarationSection := dsNotInDeclaration;
    end
  end;

  { very specialised test - look for cases in anonymous records
    e.g. var
          lRec: record
            Foo: integer;
            case Spon: boolean of
              True: (Baz: PChar);
            False: (Fred: TFoo);
          end;  }
  if (feDeclarationSection = dsVar) and (fiRecordCount > 0) and (pt.Word = wCase) then
  begin
    inc(fiRecordCases);
  end;
end;

procedure TTokenContext.CheckBracketLevel(const pt: TToken);
begin
  case pt.TokenType of
    ttOpenBracket: Inc(fiBracketLevel);
    ttCloseBracket: Dec(fiBracketLevel);
    ttOpenSquareBracket: Inc(fiSquareBracketLevel);
    ttCloseSquareBracket: Dec(fiSquareBracketLevel);
  end;

  if fiBracketLevel < 0 then
    fiBracketLevel := 0;
  if fiSquareBracketLevel < 0 then
    fiSquareBracketLevel := 0;
end;

procedure TTokenContext.CheckASM(const pt: TToken);
begin
  if pt.Word = wASM then
    fbASMBlock := True;

  if fbASMBlock and (pt.Word = wEnd) then
    fbASMBlock := False;
end;


procedure TTokenContext.CheckClassDefinitionSection(const pt: TToken);
begin
  // look for the word 'class' here for class functions
  if feDeclarationSection = dsNotIndeclaration then
  begin
    if (pt.Word = wClass) and (feFileSection = fsImplementation) and
      (feDeclarationSection = dsNotInDeclaration) then
      fbClassFunction := True;
  end;

  // in a class body already, the word 'class' means a class fn declaration
  if (feClassDefinitionSection in AccessSpecifierSections) then
  begin
    if (pt.Word = wClass) then
      fbClassFunction := True;
  end;

  { the rest only applies to structured type definitions }
  if (feDeclarationSection = dsType) then
  begin
    if (feStructuredType = stNotInStructuredType) then
    begin
      { beginning of class definition ? }

      {this could be a class def or a forward.
       The difference is that a forward ends with a semicolon, e.g.
       TMark = class;
       so can only start class if there is no Semicolon Next

       could be a class ref type (e.g. type TClassRef = class of TObject;)
       so look for the of next
       }

      if fbRHSEquals and not (TokenNext(wOf)) then
      begin
        if (pt.Word = wClass) then
        begin
          feStructuredType := stClass;
          feClassDefinitionSection := cdHeader;
        end;

        { old TP style objects }
        if (pt.Word = wObject) then
        begin
          feStructuredType := stClass; // new type for this?!
          feClassDefinitionSection := cdHeader;
        end;

        if (pt.Word = wRecord) then
        begin
          feStructuredType := stRecord;
          fiRecordCases    := 0;
        end;

        if (pt.Word in InterfaceWords) then
        begin
          feStructuredType := stInterface;
          feClassDefinitionSection := cdHeader;
        end;
      end;
    end
    { not in structured type }
    else if (feStructuredType in ObjectTypes) then
    begin
      if (feClassDefinitionSection = cdHeader) and (pt.TokenType = ttOpenBracket) then
        feClassDefinitionSection := cdHeritage;

      { in class/record/interface definition already
        This code here allows records & interfaces with access level specifiers
        But hey, if the input file compiles then why should I sweat it?
      }

      case pt.Word of
        wPrivate:
          feClassDefinitionSection := cdPrivate;
        wProtected:
          feClassDefinitionSection := cdProtected;
        wPublic:
          feClassDefinitionSection := cdPublic;
        wPublished:
          feClassDefinitionSection := cdPublished;
        wEnd:
        { only one other use of 'end' in class/interface def: anon record type
          e.g.
          frFred: record ... end;
         }
        begin
          if fiRecordCount > 0 then
            fiRecordCases := 0
          else
          begin
            feClassDefinitionSection := cdNotInClassDefinition;
            feStructuredType         := stNotInStructuredType;
            fbClassFunction          := False;
            // this is done elsewhere in generic processing of 'end' fiNestingLevel := 0;
          end;
        end;
      end;
    end
    else
    { in a strucured type, but not an object type }
    begin
      if pt.Word = wEnd then
      begin
        { in records, any variant parts (case keyword) increment the nesting level
          reset all that at the end of the record }
        fiBlockNestingLevel := fiBlockNestingLevel - fiRecordCases;
        fiRecordCases := 0;
        if (fiRecordCount <= 1) and (feStructuredType = stRecord) then
          feStructuredType := stNotInStructuredType;
      end;
    end;
  end;
end;

procedure TTokenContext.CheckForward(const pt: TToken);
const
  // words that end a proc declaration. Any more?
  EndingWords: TWordSet = [// these are expected
    wBegin, wConst, wResourceString, wVar, wThreadVar, wType,
    wForward, wExternal,
    // these will stop us if we run on too far
    wProcedure, wFunction, wConstructor, wDestructor, wEnd];
var
  lt:    TToken;
  bDone: boolean;
  liIndex, liBracketLevel: integer;
begin
  { is this a procedure? }
  if not (pt.Word in ProcedureWords) then
    exit;

  { is it a proc type def? }
  if pt.RHSEquals then
    exit;

  { if it's already known not to have a bosy (eg in interface) then don't bother }
  if not pt.ProcedureHasBody then
    exit;

  { the procedure may actually have a 'forward' or 'external' directive
    that means it has no body:
    take a FastForward through the tokens to come & look for the directives
    The difficulty will be in knowing when to stop - we cannot depend on context :0 }

  fbForward := False;
  fbExternal := False;

  liIndex := 0;
  liBracketlevel := 0;
  bDone   := False;

  while not bDone do
  begin
    lt := BufferTokens(liIndex);
    inc(liIndex);

    { stop trying on an unexpected EOF }
    if lt.TokenType = ttEOF then
      bDone := True;

    { keep track of brackets to ignore procedure params -
      var & const in here do not denote the end of the proc header }

    if lt.TokenType = ttOpenBracket then
      inc(liBracketLevel);

    if liBracketLevel > 0 then
    begin
      { ignore it all until the close bracket }
      if lt.TokenType = ttCloseBracket then
        dec(liBracketlevel);
      continue;
    end;

    if lt.Word = wForward then
    begin
      fbForward := True;
      bDone := True;
    end;

    if lt.Word = wExternal then
    begin
      fbExternal := True;
      bDone := True;
    end;

    if lt.Word in EndingWords then
      bDone := True;
  end; { while loop }
end;

procedure TTokenContext.CheckCaseLevel(const pt: TToken);
begin
  { fcCaseLabelLevels are used as a stack
  to keep track of the block indent levels
  at which there are case statemtns in this proc

  That way we can tell if a token has any chance of being a case label }

  { if we're not in a proc then there should be no case labels }
  if feProcedureSection <> psProcedureBody then
  begin
    fcCaseLabelLevels.Clear;
  end
  else
  begin
    { start of case }
    if pt.Word = wCase then
    begin
      fcCaseLabelLevels.Add(fiBlockNestingLevel + 1);
    end
    {  matching end }
    else if (pt.Word = wEnd) and (fcCaseLabelLevels.Top = fiBlockNestingLevel) then
    begin
      fcCaseLabelLevels.Pop;
    end;
  end;
end;

procedure TTokenContext.CheckRecordCount(const pt: TToken);
begin
  if pt.Word = wRecord then
    inc(fiRecordCount);

  if (pt.Word = wEnd) and (fiRecordCount > 0) then
  begin
    dec(fiRecordCount);
    fiRecordCases := 0
  end;
end;

{-------------------------------------------------------------------------------
  the divisor - equip the token with the current state }


procedure TTokenContext.SetContextOnToken(const pt: TToken);
begin
  pt.FileSection      := feFileSection;
  pt.ProcedureSection := feProcedureSection;
  pt.DeclarationSection := feDeclarationSection;
  pt.ClassDefinitionSection := feClassDefinitionSection;
  pt.StructuredType   := feStructuredType;

  pt.CaseLabelNestingLevel := (fiBlockNestingLevel = fcCaselabelLevels.Top);
  pt.BlockNestingLevel       := fiBlockNestingLevel;
  pt.BareNestingLevel       := 0; // this is set by another class - TokenBareIndent

  pt.ProcedureNestingLevel := fiProcedureNestingLevel;
  pt.BracketLevel       := fiBracketLevel;
  pt.SquareBracketLevel := fiSquareBracketLevel;
  pt.CaseCount := CaseCount;

  pt.InUsesClause := bInUsesClause;
  pt.RHSEquals    := fbRHSEquals;
  pt.RHSAssign    := fbRHSAssign;
  pt.RHSColon     := fbRHSColon;
  pt.RHSIn        := fbRHSIn;
  pt.RHSofExpressionWord := feRHSofExpressionWord;
  pt.ASMBlock     := fbASMBlock;
  pt.RHSOperand   := fbRHSOperand;
  pt.HasForward   := fbForward;
  pt.HasExternal  := fbExternal;  

  pt.InPropertyDefinition := fbInPropertyDefinition;
  pt.InExports            := fbInExports;
  pt.FormatFlags           := feFormatFlags;
  pt.ClassFunction        := fbClassFunction;
  pt.RecordCount := fiRecordCount;
  pt.RecordCases := fiRecordCases;

  pt.HasContext := True;
  pt.TokenIndex := fiCount;
end;

{-------------------------------------------------------------------------------
  checks that happen after the token has context }


procedure TTokenContext.CheckProcedureSectionAfterToken;
begin
  { end a procedure  - do this after token? }
  if (fiBlockNestingLevel <= 1) and (pt.Word = wEnd) and
    (feProcedureSection = psProcedureBody) then
  begin
    dec(fiProcedureNestingLevel);
    if (fiProcedureNestingLevel < 0) then
      fiProcedureNestingLevel := 0;

    if fiProcedureNestingLevel = 0 then
    begin
      feProcedureSection := psNotInProcedure;
      fbClassFunction    := False;
    end
    else
      { exit nested procedure body, back to declarations }
      feProcedureSection := psProcedureDeclarations
  end;
end;

{ used to distinguish unary operators from binary operators
 as they have different spacing
 it is simple in the exp.  'a := 1 - 2;' the '-' has a 1 on the left,
 ie it is on the RHS of an operand
 as opposed to a :=  -2;

 Can distingish between unary and binary, as a binary operator
 is always on the RHS of the first operand
 }

procedure TTokenContext.CheckOperand(const pt: TToken);
begin
  case pt.TokenType of
    ttSemiColon, ttAssign, ttReservedWord,
    ttOpenBracket, ttOpenSquarebracket, ttOperator:
      fbRHSOperand := False;
    ttNumber, ttLiteralString, ttWord,
    ttCloseBracket, ttCloseSquareBracket:
      fbRHSOperand := True;
  end;
end;

procedure TTokenContext.CheckNestingLevel(const pt: TToken);
begin
  { nesting level incremented from here onwards, not including the begin token }
  if (pt.Word in IndentWords) then
    inc(fiBlockNestingLevel);

  { case .. of indent start with the of }
  if (pt.Word = wOf) and (pt.RHSOfExpressionWord = wCase) then
    inc(fiBlockNestingLevel);

  { nesting level decremented from here onwards, not including the end token }
  if pt.Word in OutdentWords then
  begin
    // Assert(fiNestingLevel >= 0, 'Nesting level below zero in ' + OriginalFileName);
    if (fiBlockNestingLevel < 0) then
    begin
      ShowMessage('Nesting level of ' + IntToStr(fiBlockNestingLevel) + ' is below zero in ' + OriginalFileName);
      fiBlockNestingLevel := 0;
    end;

    dec(fiBlockNestingLevel);

    { just in case there is an asign statement with no semicolon,
    eg  begin a:= 12 end }

    fbRHSAssign := False;
  end;

  {  'class' is only sometimes an indent word -
     indent when starting a class def but not on 'class' for a proc
     interface and dispinterface }
  if (feDeclarationSection = dsType) and (feStructuredType <> stNotInStructuredType) and
    (pt.Word in ObjectTypeWords) and (not pt.ClassFunction) and fbRHSEquals then
    fiBlockNestingLevel := 1;

{
  THis test produces many errors here
  but the equivalent one produces none in the indenter???
  if fiNestingLevel < 0 then
  begin
    Log.LogError('Nesting level is ' + IntToStr(fiNestingLevel) +
      ' Resetting to zero in ' + FilePlace(pt) +  ' near ' +
        pt.Describe);
    fiNestingLevel := 0;
  end;
}
end;

procedure TTokenContext.CheckEndRHS(const pt: TToken);
var
  ptNext: TToken;
begin
  { tokens *after* the = sign have the flag set }
  if pt.Word = wEquals then
    fbRHSEquals := True;

  if pt.TokenType = ttAssign then
    fbRHSAssign := True;

  if pt.TokenType = ttColon then
    fbRHSColon := True;

  if (pt.Word = wProperty) and (pt.StructuredType in ObjectTypes) then
    fbInPropertyDefinition := True;

  if (pt.Word = wExports) then
    fbInExports := True;

  if pt.TokenType = ttSemiColon then
  begin
    { const record defs don't end at the first semicolon. Semicolons seperate fields }
    if (not pt.IsSeparatorSemiColon) and (not pt.IsParamSemicolon) then
      fbRHSEquals := False;

    fbRHSAssign := False;
    fbRHSColon  := False;
    feRHSofExpressionWord := wUnknown;
    { property def doesn't end if there is the word default after the semicolon :(
     used to declare a default array property }

    if fbInPropertyDefinition then
    begin
      ptNext := FirstSolidToken;
      { still in the property def *only* if 'default' is next }
      fbInPropertyDefinition := (ptNext.Word = wDefault);
    end;
    fbInExports := False;
  end;

  { in "while a = b do"
   at the word "do" we are no longer on the rhs of equals
   similarly if a = b then
   lack of this caused Ray Malone's bug in 0.52
  }
  if (pt.Word in [wDo, wThen]) and (pt.ProcedureSection = psProcedureBody) then
  begin
    fbRHSEquals := False;
  end;

end;

procedure TTokenContext.CheckClassHeader(const pt: TToken);
  procedure EndOfClassHeritage;
  begin
    // end of heritage
    fbRHSEquals := False;

    if SemiColonNext then
    begin
      // type TFred = class(TJim);
      feClassDefinitionSection := cdNotInClassDefinition;
      feStructuredType         := stNotInStructuredType;
      fiBlockNestingLevel           := 0; // as end;
    end
    else
      feClassDefinitionSection := cdPublic; // public by default AFAIK
  end;
begin
  { End the class/interface heritage and start the body
    Signaled either by the close bracket or the lack of open bracket, e.g.
      type
        TFred = class
          function Fred11;
        end;

    Also end the RHSEquals, as there is no semicolon to end it otherwise e.g.
    type
      TMyClass = class (TObject)
        procedure Foo (pi: integer); // this line should not be considered RHSEqals

      TMyOtherClass = class
        procedure Foo (pi: integer); // this line should not be considered RHSEqals

    and it must be false before the procs start

    also class with no body -
      type TFoo = class; is a forward, but type TBar = class(TObject); is a subclass
    but in both cases the def. ends with the semicolon
    }

  if fbRHSEquals and (feClassDefinitionSection in ClassStartSections) then
  begin
    if (feClassDefinitionSection = cdHeader) and (pt.Word in ObjectTypeWords)
      and not TokenNext(ttOpenBracket) then
      EndOfClassHeritage;

    if (feClassDefinitionSection = cdHeritage) and (pt.TokenType = ttCloseBracket) then
    begin
      EndOfClassHeritage;
    end;
  end;
end;

procedure TTokenContext.CheckNoFormat(const pt: TToken);
var
  lsError: string;
begin
  { don't format specifers
   I am using the same signals as Egbert van Nes's program
   and some others
   }
  if (pt.TokenType = ttComment) then
  begin
    feFormatFlags := ReadComment(feFormatFlags, pt.SourceCode, lsError);
    if lsError <> '' then
      Log.LogError(lsError);
  end;


end;

procedure TTokenContext.StartProcNestingLevel(const pt: TToken);
begin
  if (pt.Word in ProcedureWords) and (pt.ProcedureHasBody) then
    inc(fiProcedureNestingLevel);
end;

procedure TTokenContext.CheckRHSExpression(const pt: TToken);
begin
  if (feProcedureSection = psProcedureBody) then
  begin
    { end a Word pair }
    if (pt.Word = wThen) and (pt.RHSOfExpressionWord = wIf) then
    begin
      feRHSOfExpressionWord := wUnknown;
      // if..then frequently involves a =
      fbRHSEquals           := False;
    end;
    if (pt.TokenType = ttSemiColon) and (pt.RHSOfExpressionWord = wUntil) then
      feRHSOfExpressionWord := wUnknown;
    if (pt.Word = wDo) and (pt.RHSOfExpressionWord = wWhile) then
      feRHSOfExpressionWord := wUnknown;
    if (pt.Word = wOf) and (pt.RHSOfExpressionWord = wCase) then
      feRHSOfExpressionWord := wUnknown;
    if (pt.Word = wDo) and (pt.RHSOfExpressionWord = wFor) then
    begin
      feRHSOfExpressionWord := wUnknown;
      { for loop has 'for liVar := liStart to liEnd do ... '
       so we are RHSAssign here, stop that at the do }

      fbRHSAssign := False;
    end;

    { start a word pair }
    if (pt.Word in PairedWords) then
      feRHSOfExpressionWord := pt.Word;
  end;

  { you get case in records }
  if (feDeclarationSection = dsType) and (feStructuredType = stRecord) then
  begin
    if pt.Word = wCase then
    begin
      feRHSOfExpressionWord := wCase;
      inc(fiRecordCases);
    end;
  end;
end;

procedure TTokenContext.CheckImplicitBlocks(const pt: TToken);
begin
  { intialization and finalization sections are just code
  ie they are implicitly procs
    enter an implicit block when entering them
  }

  if (feFileSection in CodeSections) and (pt.Word in SectionWords) and
    (pt.ProcedureSection = psNotInProcedure) then
    SetImplicitBlock;

  { program and library sections have a begin..end. at the bottom of the unit
    which is the top of the executable progam
    start indenting *after* the begin
  }

  if (feFileSection in ProgramDefSections) and (pt.Word = wBegin) and
    not (fbImplicitBlock) and (pt.ProcedureSection = psNotInProcedure) then
    SetImplicitBlock;
end;

procedure TTokenContext.CheckUsesClauseAfter(const pt: TToken);
begin
  { uses clause termination stuff }
  if pt.TokenType = ttSemiColon then
  begin
    bInUsesClause := False;
    fbRHSIn       := False;
  end;
  if (pt.TokenType = ttComma) and bInUsesClause then
    fbRHSIn := False;
end;

end.