unit BlockStyles;

{ AFS 22 April
  This unit handles the different styles of line breaking & spacing after the constructs
  if <expression> then
    statement;

  if <expression> then
  begin
     ..statements
  end;

  The styles are
  - never break line (subject to approval by the linebreaker.
    If the resulting line is too long, just after the then
    is a very good place to break and may be chosen. )
  - Leave as is
  - Always break line. This is the official style
    http://www.borland.com/techvoyage/articles/DelphiStyle/StyleGuide.html

  This style also applies to
    for <expression> do
  and
    while <expression> do
  and
    else
      <statement>

 to do:
 apply to

 case exp of
  value: statement;
  value: begin statements end;

 end;
}

interface

uses TokenType, Token, TokenSource;

type

  TBlockStyles = class(TBufferedTokenProcessor)
  private
    function GetStyle(const pt: TToken): TBlockNewLineStyle;
    procedure EnsureReturnAfter;
    procedure NoReturnAfter;
  protected
    function GetIsEnabled: boolean; override;
    function IsTokenInContext(const pt: TToken): boolean; override;
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;

  end;

implementation

uses
  { local } WordMap, FormatFlags;

const
  BreakWords: TWordSet = [wThen, wDo, wElse, wEnd];


{ TBlockStyles }

constructor TBlockStyles.Create;
begin
  inherited;
  FormatFlags := FormatFlags + [eBlockStyle, eAddReturn, eRemoveReturn];
end;

function TBlockStyles.GetIsEnabled: boolean;
begin
  Result := (not Settings.Obfuscate.Enabled);
end;

function TBlockStyles.IsTokenInContext(const pt: TToken): boolean;
begin
  Result := (pt.Word in BreakWords) or pt.IsLabelColon or pt.IsCaseColon;
end;

function TBlockStyles.OnProcessToken(const pt: TToken): TToken;
var
  leStyle: TBlockNewLineStyle;
begin
  Result := pt;

  leStyle := GetStyle(pt);

  case leStyle of
    eAlways: EnsureReturnAfter;
    eLeave:; // do nothing, leave as is
    eNever: NoReturnAfter;
  end;
end;

function TBlockStyles.GetStyle(const pt: TToken): TBlockNewLineStyle;
var
  lt: TToken;
begin
  lt := FirstSolidToken;

  { only do anything to an end if it is followed by an else }
  if pt.Word = wEnd then
  begin
    if lt.Word = wElse then
      Result := Settings.Returns.EndElseStyle
    else
      Result := eLeave;
  end
  else if pt.TokenType = ttColon then
  begin
  
    if pt.IsCaseColon then
    begin
      if lt.Word = wBegin then
        // always a return here
        Result := eAlways
      else
        Result := Settings.Returns.CaseLabelStyle;
    end
    else if pt.IsLabelColon then
    begin
      { otherwise, is there a begin next? }
      if lt.Word = wBegin then
        Result := Settings.Returns.LabelBeginStyle
      else
        Result := Settings.Returns.LabelStyle;
    end
    else
      // other type of colon? Shouldn't be here
      Result := eLeave;

  end
  else if (pt.Word = wElse) and (lt.Word = wIf) and (not pt.CaseLabelNestingLevel) then
  begin
    { though else normally starts a block,
     there is never a return in "else if"
     If this is an issue, make a config setting later

      **NB** rare exception: this does not apply when the if is not related to the else
      ie
       case (foo) of
         1:
          DoSomething;
         2:
          SoSomethingElse;
         else
           // this is the else case, not part of an if.
           // All statements from the 'else' to the 'end' form a block
           if (SomeCond) then // though the is is directly after the else, this is not an else-if
             DoSomething;
           if (SomeOtherCond) then
             DoSomeOtherThing;
       end;

       end;

     }
    Result := eNever;
  end
  else
  begin
    { otherwise, is there a begin next? }
    if lt.Word = wBegin then
      Result := Settings.Returns.BlockBeginStyle
    else
      Result := Settings.Returns.BlockStyle;
  end;
end;

procedure TBlockStyles.EnsureReturnAfter;
var
  liLoop: integer;
  lt:     TToken;
begin
  { if there is no return after the current token, make one }
  liLoop := 0;

  lt := BufferTokens(liLoop);
  while lt.TokenType = ttWhiteSpace do
  begin
    inc(liLoop);
    lt := BufferTokens(liLoop);
  end;

  { see NoReturnAfter for the reason why }
  if (lt.TokenType = ttComment) then
    exit;
    
  if lt.TokenType <> ttReturn then
    InsertTokenInBuffer(liLoop, NewReturnToken);
end;

procedure TBlockStyles.NoReturnAfter;
var
  lt: TToken;
begin
  lt := BufferTokens(0);
  { remove all spaces and returns }
  while lt.TokenType in [ttWhiteSpace, ttReturn] do
  begin
    RemoveBufferToken(0);
    lt := BufferTokens(0);
  end;

  { replace with a single space }
  InsertTokenInBuffer(0, NewToken(ttWhiteSpace));
end;

end.