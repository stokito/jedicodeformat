unit WarnAssignToFunctionName;

{ AFS 21 Sept 2001

 warn of assignment to function name in old TurboPascal code

 ie
  function Fred: integer;
  begin
    Fred := 3;
  end;

 should be

  function Fred: integer;
  begin
    Result := 3;
  end;
}

interface

uses
  {  delphi } Classes,
  {  local } TokenType, Token, Warn;

type
  TWarnAssignToFunctionName = class(TWarn)
  private
    // function names - need to cope with nested functions
    fsNameStack: TStringList;
    fbLastDot: boolean;
    fsUnitName: string;
    fsLastName: string;

    function TopName: string;
    procedure PopName;
  protected
    function OnProcessToken(const pt: TToken): TToken; override;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure OnFileStart; override;
  end;

implementation

uses
    { delphi } SysUtils,
    { local } WordMap;

constructor TWarnAssignToFunctionName.Create;
begin
  inherited;

  fsNameStack := TStringList.Create;
end;

destructor TWarnAssignToFunctionName.Destroy;
begin
  FreeAndNil(fsNameStack);
  inherited;
end;

procedure TWarnAssignToFunctionName.OnFileStart;
begin
  // reset state
  fsNameStack.Clear;
  fbLastDot := False;
  fsUnitName := '';
  fsLastName := '';
end;

function TWarnAssignToFunctionName.TopName: string;
begin
  if fsNameStack = nil then
    exit;

  if fsNameStack.Count < 1 then
    exit;

  Result := fsNameStack[fsNameStack.Count - 1];
end;

procedure TWarnAssignToFunctionName.PopName;
begin
  if fsNameStack = nil then
    exit;

  if fsNameStack.Count < 1 then
    exit;

  fsNameStack.Delete(fsNameStack.Count - 1);
end;


function TWarnAssignToFunctionName.OnProcessToken(const pt: TToken): TToken;
var
  ptNext, ptNextTest: TToken;
  lsNewName: string;
  lbIgnore: boolean;
begin
  Result := pt;

  if fsNameStack = nil then
    exit;

  {  look for:
    - in procedure header, a function/proc name
    - in following procedure body, that same name
  }
  if pt.ClassDefinitionSection <> cdNotInClassDefinition then
    exit;

  { record unit name }
  if pt.FileSection = fsBeforeInterface then
  begin
    if (pt.TokenType = ttWord) then
      fsUnitName := pt.SourceCode;
  end;

  case (pt.ProcedureSection) of
    psProcedureDefinition:
    begin
      fbLastDot := False;

      if (pt.Word in ProcedureWords) then
      begin
        ptNext := FirstSolidToken;
        { should be a name?
          could also be an anon fn type, e.g
          var fred: function(p: pointer): Boolean = nil;
        }
        lbIgnore := false;
        if (ptNext.RHSColon) then
          if (ptNext.TokenType in [ttColon, ttOpenBracket]) then
            lbIgnore := true;


        if (not lbIgnore) then
        begin
          assert((ptNext.TokenType in TextualTokens), 'Unexpected token: ' + ptNext.Describe);
          lsNewName := ptNext.SourceCode;

          { this could be a member fn, eg. function MyClass.GetSomevalue: integer;
            in which case the name we want is after a dot,
          }
          ptNextTest := NextSolidTokenAfter(ptNext);
          if ptNextTest.TokenType = ttDot then
          begin
            ptNextTest := NextSolidTokenAfter(ptNextTest);
            if ptNext.TokenType = ttWord then
              lsNewName := ptNextTest.SourceCode;
          end;

          fsNameStack.Add(lsNewName);
        end;
      end;
    end;

    psProcedureBody:
    begin
      // check if we have exited a contained procedure
      while pt.ProcedureNestingLevel < fsNameStack.Count do
        PopName;

      if (pt.TokenType = ttWord) and (pt.SourceCode = TopName) then
      begin
        { this is now assign to function name if
          - there is nothing before the fn name
            e.g. MyFn := 3;
          - there is something before the fn name, but it is the curent unit name
            e.g. MyUnit.MyFn := 3;
        }
        if (not fbLastDot) or AnsiSameText(fsLastName, fsUnitName) then
        begin
          LogWarning(pt,
            'Assignment to the function name "' + TopName +
            '" is deprecated, Use assignment to "Result"');
        end;
      end;

      fbLastDot := (pt.TokenType = ttDot);

      if (pt.TokenType = ttWord) then
        fsLastName := pt.SourceCode;

    end;
    psNotInProcedure:
    begin
      fsNameStack.Clear;
    end;
  end;

end;

end.
