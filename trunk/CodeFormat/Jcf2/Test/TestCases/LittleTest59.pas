unit LittleTest59;

{ AFS 19 Nov 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 Adem Baba's ifdef uses clause example
}
interface

const
  FOO = 2;

implementation

uses
 {$IF FOO=1}Classes{$ELSE}SysUtils{$IFEND},
  DB;

end.