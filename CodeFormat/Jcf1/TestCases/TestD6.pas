unit TestD6;

{
 AFS 16 Sept 2001
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

  Test keywords & constructs new in Delphi 6
}

interface

function Foo: integer; deprecated;
function Bar: integer; //library;
function Baz: integer; platform;

type

TRThing1 = record
  foo: integer;
  bar: string;
end deprecated;

TRThing2 = record
  foo: integer;
  bar: string;
end platform;

TRThing3 = record
  foo: integer;
  bar: string;
end library;

TSomeOldClass = class
public
  function foo: integer;
end deprecated;

TSomeOtherClass = class(TSomeOldClass)
  function bar: integer;
end platform;

// enums with numbers
TCounters = (ni, spon, herring = 12, wibble, fish = 42);

implementation

function Foo: integer;
var
  li: integer library;
begin
  li := 3;
  Result := li;
end;

function Bar: integer;
var
  li: integer platform;
begin
  li := 4;
  Result := li;
end;

function Baz: integer;
var
  li: integer deprecated;
begin
  li := 5;
  Result := li;
end;

function TSomeOldClass.foo: integer;
begin
  result := 3;
end;

function TSomeOtherClass.bar: integer;
begin
  result := 4;
end;

procedure HasObsoleteRecords;
type
  TFoo = record
    liBar: integer;
    liBaz: string;
  end deprecated;
  TFoo2 = record
    Bar: integer;
    case Spon: boolean of
      True: (Baz: PChar);
      False: (Fred: integer);
  end platform;
begin
end;

end.















