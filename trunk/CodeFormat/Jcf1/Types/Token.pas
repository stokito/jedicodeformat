{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is Token.pas, released April 2000.
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

unit Token;

{ Created AFS 29 Nov 1999
  Token  - element of source code for code formatting utility }


interface

uses
    { delphi } Windows,
    { local } TokenType, WordMap, FormatFlags;

type

  TToken = class(TObject)
  private
    { property implementation }
    fsSourceCode: string;
    feTokenType: TTokenType;
    feWord: TWord;

    fbCaseLabelNestingLevel: Boolean;
    fiBlockNestingLevel, fiBareNestingLevel: integer;
    fiProcedureNestingLevel: integer;
    fiBracketLevel, fiSquareBracketLevel: integer;
    fiCaseCount: integer;

    fiTokenIndex: integer;
    fiXPosition, fiYPosition: integer;
    fiIndexOnLine: integer; { this only counts non-whitespace tokens }

    feFileSection: TFileSection;
    feProcedureSection: TProcedureSection;
    feDeclarationSection: TDeclarationSection;
    feClassDefinitionSection: TClassDefinitionSection;
    feStructuredType: TStructuredType;

    fbInUsesClause: boolean;
    fbHasContext: boolean;

    { is the current token on the Right hand side of a = or :=
      this is used to distingish between different uses of the same token,

      for e.g. the use of the token 'interface' in

      unit Fred
      interface

      type TFred = interface
    }

    fbRHSEquals: boolean;
    fbRHSAssign: boolean;
    fbRHSIn: boolean;
    fbRHSOperand: boolean;
    fbASMBlock: boolean;

    { procedure has the 'forward' directive }
    fbForward: boolean;
    { or 'external' }
    fbExternal: boolean;

    { true in class function/proc def&body can be used to distinguish the meaning of the Word 'class' }
    fbClassFunction: boolean;

    feRHSofExpressionWord: TWord;
    //expression between if & then,  while & do,  case & of, until & ;

    fbRHSColon: boolean;
    fbInPropertyDefinition: boolean;
    fbInExports: boolean;
    feFormatFlags: TFormatFlags;


    { true in initialization, finalization & program/lib main body.
      These are code blocks that are like procs }

    fbImplicitBlock: boolean;

    feCommentStyle: TCommentStyle;
    fiRecordCount, fiRecordCases: integer;

    procedure SetBlockNestingLevel(const piValue: integer);
    procedure SetBareNestingLevel(const piValue: integer);
    procedure SetProcedureNestingLevel(const piValue: integer);

    function GetPosition: TPoint;
    function GetFirstTokenOnLine: boolean;
    function GetNestingLevel: integer;

  protected
  public
    constructor Create;

    function IsDirective: boolean;

    function IsClassDirective: boolean;
    function IsProcedureDirective: boolean;
    function IsExportsDirective: boolean;
    function IsPropertyDirective: boolean;
    function IsVariableDirective: boolean;

    function IsRunOnLIne: boolean;
    function InBrackets: Boolean;
    function RHSAnything: boolean;

    function ProcedureHasBody: boolean;
    function IsSeparatorSemicolon: boolean;
    function IsParamSemicolon: boolean;
    function IsHashLiteral: boolean;
    function IsSingleLineComment: Boolean;
    function IsLabelColon: Boolean;
    function IsCaseColon: Boolean;

    function InExpression: boolean;
    function InVarList: Boolean;
    function InProcedureParamList: Boolean;

    function InProcedureTypeDeclaration: Boolean;

    function Describe: string;


    { the idea behind this proc is that when a token is inserted into the stream,
      it has no context set up yet,
      but that context will be identical to that of it's neighbours, or nearly so. }
    procedure CopyContextFrom(const pt: TToken);

    property SourceCode: string read fsSourceCode write fsSourceCode;
    property TokenType: TTokenType read feTokenType write feTokenType;
    property Word: TWord read feWord write feWord;

    property CaseLabelNestingLevel: boolean read fbCaseLabelNestingLevel write fbCaseLabelNestingLevel;
    property BlockNestingLevel: integer read fiBlockNestingLevel write SetBlockNestingLevel;
    property BareNestingLevel: integer read fiBareNestingLevel write SetBareNestingLevel;
    property NestingLevel: integer read GetNestingLevel;

    property ProcedureNestingLevel: integer read fiProcedureNestingLevel write SetProcedureNestingLevel;
    property BracketLevel: integer read fiBracketLevel write fiBracketLevel;
    property SquareBracketLevel: integer read fiSquareBracketLevel write fiSquareBracketLevel;
    property CaseCount: integer read fiCaseCount write fiCaseCount;


    property FileSection: TFileSection read feFileSection write feFileSection;
    property ProcedureSection: TProcedureSection read feProcedureSection write feProcedureSection;
    property DeclarationSection: TDeclarationSection read feDeclarationSection write feDeclarationSection;
    property ClassDefinitionSection: TClassDefinitionSection read feClassDefinitionSection
      write feClassDefinitionSection;
    property StructuredType: TStructuredType read feStructuredType write feStructuredType;


    property InUsesClause: boolean read fbInUsesClause write fbInUsesClause;
    property RHSEquals: boolean read fbRHSEquals write fbRHSEquals;
    property RHSAssign: boolean read fbRHSAssign write fbRHSAssign;
    property RHSIn: boolean read fbRHSIn write fbRHSIn;
    property RHSColon: boolean read fbRHSColon write fbRHSColon;
    property RHSOperand: boolean read fbRHSOperand write fbRHSOperand;

    { type of proc }
    property HasForward: boolean read fbForward write fbForward;
    property HasExternal: boolean read fbExternal write fbExternal;

    property RHSOfExpressionWord: TWord read feRHSofExpressionWord write feRHSofExpressionWord;

    property InPropertyDefinition: boolean read fbInPropertyDefinition write
      fbInPropertyDefinition;
    property InExports: boolean read fbInExports write fbInExports;
    property FormatFlags: TFormatFlags read feFormatFlags write feFormatFlags;
    property ASMBlock: boolean read fbASMBlock write fbASMBlock;

    property ClassFunction: boolean read fbClassFunction write fbClassFunction;
    property ImplicitBlock: boolean read fbImplicitBlock write fbImplicitBlock;

    property HasContext: boolean read fbHasContext write fbHasContext;
    property TokenIndex: integer read fiTokenIndex write fiTokenIndex;
    property XPosition: integer read fiXPosition write fiXPosition;
    property YPosition: integer read fiYPosition write fiYPosition;
    property Position: TPoint read GetPosition;
    property FirstTokenOnLine: boolean read GetFirstTokenOnLine;

    { this only counts non-whitespace tokens }
    property IndexOnLine: integer read fiIndexOnLine write fiIndexOnLine;

    property CommentStyle: TCommentStyle read feCommentStyle write feCommentStyle;
    property RecordCount: integer read fiRecordCount write fiRecordCount;
    property RecordCases: integer read fiRecordCases write fiRecordCases;
  end;

  TTokenProcedure = procedure(const pt: TToken) of object;

function NewToken: TToken; overload;

function NewToken(tt: TTokenType): TToken; overload;

function NewReturnToken: TToken;

implementation

uses
    { delphi } Classes, SysUtils,
    { local } JclStrings;


function NewToken: TToken;
begin
  Result := TToken.Create;
end;

function NewToken(tt: TTokenType): TToken;
begin
  Result := NewToken;
  Result.TokenType := tt;

  case tt of
    ttReturn:
      Result.SourceCode := AnsiCrLf;
    ttWhiteSpace:
      Result.SourceCode := AnsiSpace;
  end;
end;

function NewReturnToken: TToken;
begin
  Result := NewToken(ttReturn);
end;

{-------------------------------------------------------------------------------
 TToken }


procedure TToken.CopyContextFrom(const pt: TToken);
begin
  BlockNestingLevel       := pt.BlockNestingLevel;
  BareNestingLevel := pt.BareNestingLevel;
  ProcedureNestingLevel := pt.ProcedureNestingLevel;
  SquareBracketLevel := pt.SquareBracketLevel;
  CaseCount := pt.CaseCount;

  FileSection      := pt.FileSection;
  ProcedureSection := pt.ProcedureSection;
  DeclarationSection := pt.DeclarationSection;
  ClassDefinitionSection := pt.ClassDefinitionSection;
  StructuredType   := pt.StructuredType;
  
  InUsesClause := pt.InUsesClause;
  RHSEquals    := pt.RHSEquals;
  RHSAssign    := pt.RHSAssign;
  RHSEquals    := pt.RHSEquals;
  RHSIn        := pt.RHSIn;
  RHSofExpressionWord := pt.feRHSofExpressionWord;

  InPropertyDefinition := pt.InPropertyDefinition;
  InExports            := pt.InExports;
  feFormatFlags           := pt.FormatFlags;

  ClassFunction := pt.ClassFunction;
  HasForward := pt.HasForward;
  HasExternal := pt.HasExternal;

  ImplicitBlock        := pt.ImplicitBlock;

  TokenIndex := pt.TokenIndex;

  HasContext   := True;
  XPosition    := pt.XPosition;
  YPosition    := pt.YPosition;
  IndexOnLine  := pt.IndexOnLine;
  CommentStyle := pt.CommentStyle;
  RecordCount := pt.RecordCount;
  RecordCases := pt.RecordCases;
end;

constructor TToken.Create;
begin
  inherited;

  feTokenType  := ttUnknown;
  feWord       := wUnknown;
  fsSourceCode := '';

  fiBlockNestingLevel       := 0;
  fiBareNestingLevel := 0;
  fiProcedureNestingLevel := 0;
  fiSquareBracketLevel := 0;
  fiCaseCount := 0;

  feFileSection      := fsBeforeInterface;
  feProcedureSection := psNotInProcedure;
  feDeclarationSection := dsNotInDeclaration;
  feStructuredType   := stNotInstructuredType;

  fbInUsesClause := False;
  fbRHSEquals    := False;
  fbRHSAssign    := False;
  fbRHSIn        := False;

  fbInPropertyDefinition := False;
  fbInExports            := False;
  feFormatFlags          := [];
  fbClassFunction        := False;
  fbImplicitBlock        := False;

  fiXPosition := -1;
  fiYPosition := -1;

  fbHasContext := False;
  fiTokenIndex := -1;
  CommentStyle := eNotAComment;
  RecordCount := 0;
  RecordCases := 0;
end;

function TToken.GetFirstTokenOnLine: boolean;
begin
  // comments count as significant tokens here as they are indented
  Result := (fiIndexOnLine = 1) and (not (TokenType in [ttWhiteSpace, ttReturn]));
end;

function TToken.GetPosition: TPoint;
begin
  Result := Point(XPosition, YPosition);
end;

function TToken.IsDirective: boolean;
begin
  Result := (TokenType = ttReservedWordDirective) and
    (IsProcedureDirective or IsClassDirective or IsPropertyDirective or
    IsVariableDirective or IsExportsDirective);
end;

function TToken.IsExportsDirective: boolean;
begin
  { exports clause can have index & name directives }
  Result := InExports and (BracketLevel = 0) and (Word in ExportDirectives);
end;

function TToken.IsVariableDirective: boolean;
begin
  Result := (DeclarationSection = dsVar) and RHSColon and (Word in VariableDirectives);
end;


function TToken.IsClassDirective: boolean;
begin
  { property Public: Boolean;
    function Protected: Boolean
    are both legal so have to check that we're not in a property or function def. }
  Result := (feStructuredType = stClass) and (Word in ClassDirectives)
    and (not InPropertyDefinition) and (ProcedureSection = psNotInProcedure);
end;

function TToken.IsProcedureDirective: boolean;
begin
  Result := (feProcedureSection = psProcedureDirectives) and
    (Word in ProcedureDirectives);
end;

function TToken.IsPropertyDirective: boolean;
begin
  Result := (InPropertyDefinition and RHSColon and (BracketLevel = 0) and
    (Word in PropertyDirectives));
end;

{ this check is valid if the token is first on the line
 e.g. a := First thing on a line means that it continues from the prev. line }

function TToken.IsRunOnLine: boolean;
const
  NotFirstTokens: TTokenTypeSet = [ttAssign, ttPunctuation, ttOperator,
    ttOpenBracket, ttCloseBracket, ttOpenSquareBracket, ttCloseSquareBracket, ttColon];
  NotFirstWords: TWordSet       = [wEquals];
begin
  Result := RHSAssign or RHSEquals or (RHSOfExpressionWord <> wUnknown) or
    InBrackets  or (TokenType in NotFirstTokens) or (Word in NotFirstWords);

  if Result then
    exit;

  { a literal string can start a case statement if it is a single char
    but otherwise is a not-first token }

  if (TokenType = ttLiteralString) and not CaseLabelNestingLevel then
    Result := True;

  if Result then
    exit;

  { colon only for var declarations }
  if ((DeclarationSection = dsVar) or (ProcedureSection = psProcedureDeclarations)) and (RHSColon) then
    Result := True;

end;

function TToken.InBrackets: Boolean;
begin
  Result := ((BracketLevel > 0) or (SquareBracketLevel > 0)) and
    not (TokenType in BracketTokens)
end;

function TToken.RHSAnything: boolean;
begin
  Result := RHSAssign or RHSColon or RHSEquals or (RHSOfExpressionWord <> wUnknown);
end;

{ this proc header should have a procedure body if
  - it doesn't  have the forward directive
  - it is in the implementation section
  - it is not in a type def
  - it is not in class def
}

function TToken.ProcedureHasBody: boolean;
begin
  Result := not HasForward;

  if Result then
    Result := (DeclarationSection = dsNotInDeclaration) and
      (feFileSection <> fsInterface) and
      (feClassDefinitionSection = cdNotInClassDefinition);
end;


function TToken.GetNestingLevel: integer;
begin
  Result := BlockNestingLevel + BareNestingLevel;
end;

procedure TToken.SetBlockNestingLevel(const piValue: integer);
begin
  fiBlockNestingLevel := piValue;
  if BlockNestingLevel < 0 then
    fiBlockNestingLevel := 0;
end;

procedure TToken.SetBareNestingLevel(const piValue: integer);
begin
  fiBareNestingLevel := piValue;
  if BareNestingLevel < 0 then
    fiBareNestingLevel := 0;
end;

procedure TToken.SetProcedureNestingLevel(const piValue: integer);
begin
  fiProcedureNestingLevel := piValue;
  if ProcedureNestingLevel < 0 then
    fiProcedureNestingLevel := 0;
end;

{ in a cost def of a record, semicolons are used internally to seperate fields }
function TToken.IsSeparatorSemiColon: boolean;
begin
  Result := (TokenType = ttSemiColon) and
    (DeclarationSection = dsConst) and
    RHSEquals and (BracketLevel > 0);
end;

{ separating the params of a fn in a type def }
function TToken.IsParamSemicolon: boolean;
begin
  Result := (TokenType = ttSemiColon) and
    (DeclarationSection = dsType) and
    RHSEquals and (BracketLevel > 0);
end;

function TToken.Describe: string;
const
  StructuredTokens: TTokenTypeSet =
    [ttComment, ttOperator, ttNumber, ttLiteralString, ttUnKnown];
begin
  Result := TokenTypeToString(TokenType);
  if (TokenType in (TextualTokens + StructuredTokens)) then
    Result := Result + ' ' + SourceCode;
end;

function TToken.IsHashLiteral: boolean;
begin
  Result := (TokenType = ttLiteralString) and (StrLeft(SourceCode, 1) = '#');
end;

function TToken.IsSingleLineComment: Boolean;
begin
  Result := False;

  if (TokenType <> ttComment) then
    exit;

  case CommentStyle of
    eDoubleSlash:
      Result := True;
    eBracketStar:
    begin
      Result := (StrLeft(SourceCode, 2) = '(*') and (StrRight(SourceCode, 2) = '*)')
    end;
    eCurly:
    begin
      Result := (StrLeft(SourceCode, 1) = '{') and (StrRight(SourceCode, 1) = '}')
    end;
  end;
end;

function TToken.IsLabelColon: boolean;
begin
  Result := False;

  if TokenType <> ttColon then
    exit;

  if ProcedureSection <> psProcedureBody then
    exit;

  if BracketLevel <> 0 then
    exit;

  if CaseLabelNestingLevel then
    exit;

  Result := true;
end;


// case colon (else case also counts)
function TToken.IsCaseColon: boolean;
begin
  Result := False;

  if (TokenType <> ttColon) and (Word <> wElse) then
    exit;

  if ProcedureSection <> psProcedureBody then
    exit;

  if BracketLevel > 0 then
    exit;

  if not CaseLabelNestingLevel then
    exit;

  Result := True;
end;


function TToken.InExpression: boolean;
begin
  Result := (ProcedureSection = psProcedureBody) and RHSAssign;
end;

function TToken.InProcedureParamList: Boolean;
begin
  Result := (ProcedureSection = psProcedureDefinition) and (BracketLevel = 1);
end;

function TToken.InProcedureTypeDeclaration: Boolean;
begin
  Result := (DeclarationSection in [dStype, dsVar]) and
    (ProcedureSection in [psProcedureDefinition, psProcedureDirectives]);
end;

function TToken.InVarList: Boolean;
begin
  Result := (ProcedureSection = psProcedureDeclarations) or (DeclarationSection in [dsConst, dsVar]);

  if Result then
    Result := (not RHSColon) and (RecordCount = 0);
end;

end.