unit TestLayoutTry;

{ AFS 16 Jan 2002

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests indentation around some try blocks under if statments
}


interface

implementation

procedure TryProc;
begin
end;

procedure FinallyProc;
begin
end;

procedure test1;
var
  b: boolean;
begin
 b := true;

if b then
begin
try
TryProc;
finally
FinallyProc;
end;
end;


 // indent the try or treat it like a begin???
if b then
try
TryProc;
finally
FinallyProc;
end;

if b then
TryProc;

end;

end.
