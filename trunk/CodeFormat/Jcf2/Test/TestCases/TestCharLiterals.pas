unit TestCharLiterals;

{ AFS 30 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests chars and strings }


interface

implementation

procedure Chars;
const
Fred = #80;
LineBreak = #13#10;
SomeChars = #78#79#80;
HEXCHARS = #$12#$2E#60;
var
ls:string;
ls2: string;
begin
ls:=#90+LineBreak+#90#91+SomeChars+#90;
ls2:= #$F#$A;
ls2 := ls + #$1F + HEXCHARS;
end;

procedure Stringchars;
const
  Boo = 'Boo';
  HELLO = 'Hello'#13;
  OLLA = #10'Olla!';
var
  ls: string;
begin
  ls := 'Fred';
  ls := #13;
  ls := #12'Fred'#32'Fred'#22;
end;

{ hat char literals.
  Undocumented, but works.
  Described as "Old-style" - perhaps a Turbo-pascal holdover
 Pointed out by Dimentiy }

const
 str1 = ^M;

  HAT_FOO = ^A;
  HAT_BAR = ^b;
  HAT_FISH = ^F;
  HAT_WIBBLE = ^q;
  HAT_SPON = ^Z;

  HAT_AT = ^@;

  HAT_FROWN = ^[;
  HAT_HMM = ^\;
  HAT_SMILE = ^];
  HAT_HAT = ^^;
  HAT_UNDER = ^_;

var
  hat1: char = ^h;
  hat2: char = ^j;
  hat3: char = ^m;

procedure HatBaby;
var
 str: string;
 ch: char;
begin
  str := HAT_FOO + ^M;
  ch := ^N;

  str := HAT_FOO + ^@ + ^] + ^^ + ^- + ^\ + ^[;
end;


end.
