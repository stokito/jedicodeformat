{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is WordMap.pas, released April 2000.
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

unit WordMap;

{ AFS Dec 1999 convert a text word to a symbol }

interface

uses TokenType;

type

  { these are the categories of words

   - Unknown (ie either a var/procedure/other user-defined name,
              or the word map needs a new entry)
   - Reserved word (general language keyword)
   - Directive (keyword that specifies that attributes of a declaration)
   - Operator (an operation on vars)
   - Type (a built-in data type)

   This is a subrange of the kinds of tokens
   }

  TWordType = ttWord..ttOperator;

  { a value for each keyword in Delphi }
  TWord = ({ unknown }
    wUnknown,

    { built-in keywords }
    wArray,
    wAsm,
    wBegin,
    wCase,
    wClass,
    wConst,
    wConstructor,
    wDestructor,
    wDispinterface,
    wDo,
    wDownto,
    wElse,
    wEnd,
    wExcept,
    wExports,
    wFile,
    wFinalization,
    wFinally,
    wFor,
    wFunction,
    wGoto,
    wIf,
    wImplementation,
    wInherited,
    wInitialization,
    wInline,
    wInterface,
    wLabel,
    wLibrary,
    wObject,
    wOf,
    wOut,
    wPacked,
    wProcedure,
    wProgram,
    wProperty,
    wRaise,
    wRecord,
    wRepeat,
    wResourcestring,
    wSet,
    wThen,
    wThreadvar,
    wTo,
    wTry,
    wType,
    wUnit,
    wUntil,
    wUses,
    wVar,
    wWhile,
    wWith,
    wAt,
    wOn,

    { reserved words that are directives }
    wAbsolute,
    wExternal,
    wPascal,
    wSafecall,
    wAbstract,
    wFar,
    wPrivate,
    wStdcall,
    wAssembler,
    wForward,
    wProtected,
    wStored,
    wAutomated,
    wIndex,
    wPublic,
    wVirtual,
    wCdecl,
    wMessage,
    wPublished,
    wWrite,
    wDefault,
    wName,
    wRead,
    wWriteOnly,
    wDispid,
    wNear,
    wReadOnly,
    wDynamic,
    wNodefault,
    wRegister,
    wExport,
    wOverride,
    wOverload,
    wResident,
    wImplements,
    wReintroduce,

    { Delphi 6 directives }
    wDeprecated,
    wPlatform,

    { operators that are words not symbols }
    wAnd,
    wAs,
    wDiv,
    wIn,
    wIs,
    wMod,
    wNot,
    wOr,
    wShl,
    wShr,
    wXor,

    { built-in constants }
    wNil,
    wTrue,
    wFalse,

    { built in types }
    wBoolean,
    wByteBool,
    wWordBool,
    wLongBool,
    wInteger,
    wCardinal,
    wShortint,
    wSmallint,
    wLongint,
    wInt64,
    wByte,
    wWord,
    wLongword,
    wChar,
    wWidechar,
    wString,
    wWidestring,
    wSingle,
    wDouble,
    wExtended,
    wReal,
    wReal48,
    wComp,
    wCurrency,

    // symbol operators 
    wAtSign,
    wHat,
    wTimes,
    wFloatDiv,
    wPlus,
    wMinus,
    wEquals,
    wGreaterThan,
    wLessThan,
    wGreaterThanOrEqual,
    wLessThanOrEqual,
    wNotEqual);

  TWordSet = set of TWord;

procedure TypeOfWord(const psWord: string; var pWordType: TWordType; var pWord: TWord);

{ indentation alignment is done for
  begin
  end

  but also also for

  repeat
  until

  case
  end

  TMyType = class
  end

  TMyType = record
  end

  IMyType = interface
  end

  IMytype = dispinterface
  end

}


{ 'Class' is only sometimes an indent word so don't include it here }
const
  IndentWords: TWordSet = [wBegin, wRepeat, wRecord, wTry, wASM];
  { case is not included here,
 as we only want to start the indent from the 'of' in case...of
 otherwise if the condition is verbose and runs on to another line, it gets indented to much
}


  { if..then, until..; while..do case..of }
const
  PairedWords: TWordSet = [wIf, wUntil, wWhile, wFor, wCase];


const
  OutdentWords: TWordSet = [wEnd, wUntil];

  FileStartWords: TWordSet = [wUnit, wProgram, wLibrary];

  SectionWords: TWordSet = [wInterface, wImplementation,
    wInitialization, wFinalization, wProgram, wLibrary];

  { procedure can have local declarations of vars, const and yes, types }
  Declarations: TWordSet = [wConst, wResourceString, wVar, wThreadVar, wType, wLabel];

  ParamTypes = [wVar, wConst, wOut];

  PropertyDirectives: TWordSet =
    { the basics }
    [wRead, wWrite,
    { the advanced stuff  }
    wStored, wDefault, wNoDefault, wImplements,
    { for COM interface properties }
    wReadOnly, wWriteOnly, wDispId];

  ExportDirectives: TWordSet = [wIndex, wName];

  VariableDirectives: TWordSet = [wAbsolute, wRegister, wDeprecated, wLibrary, wPlatform];

  ProcedureDirectives: TWordSet = [wExternal, wPascal, wSafecall, wAbstract,
    wAutomated, wFar, wStdcall, wAssembler, wInline, wForward,
    wVirtual, wCdecl, wMessage, wName, wRegister, wDispid,
    wNear, wDynamic, wExport, wOverride, wResident, wOverload, wReintroduce,
    wDeprecated, wLibrary, wPlatform];

  ClassDirectives: TWordSet = [wPrivate, wProtected, wPublic, wPublished, wAutomated];
  HintDirectives: TWordSet = [wDeprecated, wLibrary, wPlatform];

  ProcedureWords: TWordSet = [wProcedure, wFunction, wConstructor, wDestructor];

  BlockEndWords = [wUntil, wElse, wFinally, wEnd];

  StructuredTypeWords = [wClass, wInterface, wDispinterface, wRecord];
  ObjectTypeWords     = [wClass, wObject, wInterface, wDispinterface];

  InterfaceWords = [wInterface, wDispinterface];

  ConstWords = [wConst, wResourceString];


  { these words are
  - operators
  - can be unary
  - have no alphabet chars in them }
  PossiblyUnarySymbolOperators = [wAtSign, wHat, wPlus, wMinus];


implementation

uses Sysutils;

type
  TRReservedWordMap = record
    sWord: string;
    eWordType: TWordType;
    eWord: TWord;
  end;

  {  This const data maps text to TWordType and TWord
   ie it determines that the ascii text "array" corresponds to
   a reserved word called with constant value wArray

  This data is in the implementation section of this unit
  the procedure TypeOfWord exposes it }

const
  KeywordMap: array [0..141] of TRReservedWordMap =
    ({ reserved words }
    (sWord: 'array'; eWordType: ttReservedWord; eWord: wArray),
    (sWord: 'asm'; eWordType: ttReservedWord; eWord: wAsm),
    (sWord: 'begin'; eWordType: ttReservedWord; eWord: wBegin),
    (sWord: 'case'; eWordType: ttReservedWord; eWord: wCase),
    (sWord: 'class'; eWordType: ttReservedWord; eWord: wClass),
    (sWord: 'const'; eWordType: ttReservedWord; eWord: wConst),
    (sWord: 'constructor'; eWordType: ttReservedWord; eWord: wConstructor),
    (sWord: 'destructor'; eWordType: ttReservedWord; eWord: wDestructor),
    (sWord: 'dispinterface'; eWordType: ttReservedWord; eWord: wDispinterface),
    (sWord: 'do'; eWordType: ttReservedWord; eWord: wDo),
    (sWord: 'downto'; eWordType: ttReservedWord; eWord: wDownTo),
    (sWord: 'else'; eWordType: ttReservedWord; eWord: wElse),
    (sWord: 'end'; eWordType: ttReservedWord; eWord: wEnd),
    (sWord: 'except'; eWordType: ttReservedWord; eWord: wExcept),
    (sWord: 'exports'; eWordType: ttReservedWord; eWord: wExports),
    (sWord: 'file'; eWordType: ttReservedWord; eWord: wFile),
    (sWord: 'finalization'; eWordType: ttReservedWord; eWord: wFinalization),
    (sWord: 'finally'; eWordType: ttReservedWord; eWord: wFinally),
    (sWord: 'for'; eWordType: ttReservedWord; eWord: wFor),
    (sWord: 'function'; eWordType: ttReservedWord; eWord: wFunction),
    (sWord: 'goto'; eWordType: ttReservedWord; eWord: wGoto),
    (sWord: 'if'; eWordType: ttReservedWord; eWord: wIf),
    (sWord: 'implementation'; eWordType: ttReservedWord; eWord: wImplementation),
    (sWord: 'inherited'; eWordType: ttReservedWord; eWord: winherited),
    (sWord: 'initialization'; eWordType: ttReservedWord; eWord: wInitialization),
    (sWord: 'inline'; eWordType: ttReservedWord; eWord: wInline),
    (sWord: 'interface'; eWordType: ttReservedWord; eWord: wInterface),
    (sWord: 'label'; eWordType: ttReservedWord; eWord: wLabel),
    (sWord: 'library'; eWordType: ttReservedWord; eWord: wLibrary),
    (sWord: 'object'; eWordType: ttReservedWord; eWord: wobject),
    (sWord: 'of'; eWordType: ttReservedWord; eWord: wOf),
    (sWord: 'out'; eWordType: ttReservedWord; eWord: wOut),
    (sWord: 'packed'; eWordType: ttReservedWord; eWord: wPacked),
    (sWord: 'procedure'; eWordType: ttReservedWord; eWord: wProcedure),
    (sWord: 'program'; eWordType: ttReservedWord; eWord: wProgram),
    (sWord: 'property'; eWordType: ttReservedWord; eWord: wProperty),
    (sWord: 'raise'; eWordType: ttReservedWord; eWord: wRaise),
    (sWord: 'record'; eWordType: ttReservedWord; eWord: wRecord),
    (sWord: 'repeat'; eWordType: ttReservedWord; eWord: wRepeat),
    (sWord: 'resourcestring'; eWordType: ttReservedWord; eWord: wResourceString),
    (sWord: 'set'; eWordType: ttReservedWord; eWord: wSet),
    (sWord: 'then'; eWordType: ttReservedWord; eWord: wThen),
    (sWord: 'threadvar'; eWordType: ttReservedWord; eWord: wThreadvar),
    (sWord: 'to'; eWordType: ttReservedWord; eWord: wTo),
    (sWord: 'try'; eWordType: ttReservedWord; eWord: wTry),
    (sWord: 'type'; eWordType: ttReservedWord; eWord: wType),
    (sWord: 'unit'; eWordType: ttReservedWord; eWord: wUnit),
    (sWord: 'until'; eWordType: ttReservedWord; eWord: wUntil),
    (sWord: 'uses'; eWordType: ttReservedWord; eWord: wUses),
    (sWord: 'var'; eWordType: ttReservedWord; eWord: wVar),
    (sWord: 'while'; eWordType: ttReservedWord; eWord: wWhile),
    (sWord: 'with'; eWordType: ttReservedWord; eWord: wWith),
    (sWord: 'at'; eWordType: ttReservedWord; eWord: wAt),
    (sWord: 'on'; eWordType: ttReservedWord; eWord: wOn),

    { reseved words that are directives }
    (sWord: 'absolute'; eWordType: ttReservedWordDirective; eWord: wAbsolute),
    (sWord: 'external'; eWordType: ttReservedWordDirective; eWord: wExternal),
    (sWord: 'pascal'; eWordType: ttReservedWordDirective; eWord: wPascal),
    (sWord: 'safecall'; eWordType: ttReservedWordDirective; eWord: wSafecall),
    (sWord: 'abstract'; eWordType: ttReservedWordDirective; eWord: wAbstract),
    (sWord: 'far'; eWordType: ttReservedWordDirective; eWord: wFar),
    (sWord: 'private'; eWordType: ttReservedWordDirective; eWord: wPrivate),
    (sWord: 'stdcall'; eWordType: ttReservedWordDirective; eWord: wStdCall),
    (sWord: 'assembler'; eWordType: ttReservedWordDirective; eWord: wAssembler),
    (sWord: 'forward'; eWordType: ttReservedWordDirective; eWord: wForward),
    (sWord: 'protected'; eWordType: ttReservedWordDirective; eWord: wProtected),
    (sWord: 'stored'; eWordType: ttReservedWordDirective; eWord: wStored),
    (sWord: 'automated'; eWordType: ttReservedWordDirective; eWord: wAutomated),
    (sWord: 'index'; eWordType: ttReservedWordDirective; eWord: wIndex),
    (sWord: 'public'; eWordType: ttReservedWordDirective; eWord: wPublic),
    (sWord: 'virtual'; eWordType: ttReservedWordDirective; eWord: wVirtual),
    (sWord: 'cdecl'; eWordType: ttReservedWordDirective; eWord: wCdecl),
    (sWord: 'message'; eWordType: ttReservedWordDirective; eWord: wMessage),
    (sWord: 'published'; eWordType: ttReservedWordDirective; eWord: wPublished),
    (sWord: 'write'; eWordType: ttReservedWordDirective; eWord: wWrite),
    (sWord: 'default'; eWordType: ttReservedWordDirective; eWord: wDefault),
    (sWord: 'name'; eWordType: ttReservedWordDirective; eWord: wName),
    (sWord: 'read'; eWordType: ttReservedWordDirective; eWord: wRead),
    (sWord: 'writeonly'; eWordType: ttReservedWordDirective; eWord: wWriteOnly),
    (sWord: 'dispid'; eWordType: ttReservedWordDirective; eWord: wDispId),
    (sWord: 'near'; eWordType: ttReservedWordDirective; eWord: wNear),
    (sWord: 'readonly'; eWordType: ttReservedWordDirective; eWord: wReadonly),
    (sWord: 'dynamic'; eWordType: ttReservedWordDirective; eWord: wDynamic),
    (sWord: 'nodefault'; eWordType: ttReservedWordDirective; eWord: wNoDefault),
    (sWord: 'register'; eWordType: ttReservedWordDirective; eWord: wRegister),
    (sWord: 'export'; eWordType: ttReservedWordDirective; eWord: wExport),
    (sWord: 'override'; eWordType: ttReservedWordDirective; eWord: wOverride),
    (sWord: 'overload'; eWordType: ttReservedWordDirective; eWord: wOverload),
    (sWord: 'resident'; eWordType: ttReservedWordDirective; eWord: wResident),
    (sWord: 'implements'; eWordType: ttReservedWordDirective; eWord: wImplements),
    (sWord: 'reintroduce'; eWordType: ttReservedWordDirective; eWord: wReintroduce),

    { D6 directives }
    (sWord: 'deprecated'; eWordType: ttReservedWordDirective; eWord: wDeprecated),
    (sWord: 'platform'; eWordType: ttReservedWordDirective; eWord: wPlatform),

    { operators that are words not symbols }
    (sWord: 'and'; eWordType: ttOperator; eWord: wAnd),
    (sWord: 'as'; eWordType: ttOperator; eWord: wAs),
    (sWord: 'div'; eWordType: ttOperator; eWord: wDiv),
    (sWord: 'in'; eWordType: ttOperator; eWord: wIn),
    (sWord: 'is'; eWordType: ttOperator; eWord: wIs),
    (sWord: 'mod'; eWordType: ttOperator; eWord: wMod),
    (sWord: 'not'; eWordType: ttOperator; eWord: wNot),
    (sWord: 'or'; eWordType: ttOperator; eWord: wOr),
    (sWord: 'shl'; eWordType: ttOperator; eWord: wShl),
    (sWord: 'shr'; eWordType: ttOperator; eWord: wShr),
    (sWord: 'xor'; eWordType: ttOperator; eWord: wXor),

    { built-in constants }
    (sWord: 'nil'; eWordType: ttBuiltInConstant; eWord: wNil),
    (sWord: 'true'; eWordType: ttBuiltInConstant; eWord: wTrue),
    (sWord: 'false'; eWordType: ttBuiltInConstant; eWord: wFalse),

    { built in types }
    (sWord: 'boolean'; eWordType: ttBuiltInType; eWord: wBoolean),
    (sWord: 'ByteBool'; eWordType: ttBuiltInType; eWord: wByteBool),
    (sWord: 'WordBool'; eWordType: ttBuiltInType; eWord: wWordBool),
    (sWord: 'LongBool'; eWordType: ttBuiltInType; eWord: wLongBool),
    (sWord: 'integer'; eWordType: ttBuiltInType; eWord: wInteger),
    (sWord: 'cardinal'; eWordType: ttBuiltInType; eWord: wCardinal),
    (sWord: 'shortint'; eWordType: ttBuiltInType; eWord: wShortInt),
    (sWord: 'smallint'; eWordType: ttBuiltInType; eWord: wSmallInt),
    (sWord: 'longint'; eWordType: ttBuiltInType; eWord: wLongInt),
    (sWord: 'int64'; eWordType: ttBuiltInType; eWord: wint64),
    (sWord: 'byte'; eWordType: ttBuiltInType; eWord: wByte),
    (sWord: 'word'; eWordType: ttBuiltInType; eWord: wWord),
    (sWord: 'longword'; eWordType: ttBuiltInType; eWord: wLongWord),
    (sWord: 'char'; eWordType: ttBuiltInType; eWord: wChar),
    (sWord: 'widechar'; eWordType: ttBuiltInType; eWord: wWideChar),
    (sWord: 'string'; eWordType: ttBuiltInType; eWord: wString),
    (sWord: 'widestring'; eWordType: ttBuiltInType; eWord: wWideString),
    (sWord: 'single'; eWordType: ttBuiltInType; eWord: wSingle),
    (sWord: 'double'; eWordType: ttBuiltInType; eWord: wDouble),
    (sWord: 'extended'; eWordType: ttBuiltInType; eWord: wExtended),
    (sWord: 'real'; eWordType: ttBuiltInType; eWord: wReal),
    (sWord: 'real48'; eWordType: ttBuiltInType; eWord: wReal48),
    (sWord: 'comp'; eWordType: ttBuiltInType; eWord: wComp),
    (sWord: 'currency'; eWordType: ttBuiltInType; eWord: wCurrency),

    { operators that are symbols }
    (sWord: '@'; eWordType: ttOperator; eWord: wAtSign),
    (sWord: '^'; eWordType: ttOperator; eWord: wHat),
    (sWord: '*'; eWordType: ttOperator; eWord: wTimes),
    (sWord: '/'; eWordType: ttOperator; eWord: wFloatDiv),
    (sWord: '+'; eWordType: ttOperator; eWord: wPlus),
    (sWord: '-'; eWordType: ttOperator; eWord: wMinus),
    (sWord: '='; eWordType: ttOperator; eWord: wEquals),
    (sWord: '>'; eWordType: ttOperator; eWord: wGreaterThan),
    (sWord: '<'; eWordType: ttOperator; eWord: wlessThan),
    (sWord: '>='; eWordType: ttOperator; eWord: wGreaterThanOrEqual),
    (sWord: '<='; eWordType: ttOperator; eWord: wLessThanOrEqual),
    (sWord: '<>'; eWordType: ttOperator; eWord: wNotEqual)
    );

procedure TypeOfWord(const psWord: string; var pWordType: TWordType; var pWord: TWord);
var
  liLoop: integer;
begin
  { if its not found in the list, it must be an identifier }
  pWordType := ttWord;
  pWord     := wUnknown;

  for liLoop := Low(KeywordMap) to High(KeywordMap) do
  begin
    if AnsiCompareText(KeywordMap[liLoop].sWord, psWord) = 0 then
    begin
      pWordType := KeywordMap[liLoop].eWordType;
      pWord     := KeywordMap[liLoop].eWord;
      break;
    end;
  end;
end;

end.