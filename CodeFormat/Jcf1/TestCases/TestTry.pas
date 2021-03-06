unit TestTry;

{ AFS March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests layout of try..except and try..finally blocks
}

interface

implementation

uses Dialogs, SysUtils;


procedure TestTryProc;
begin

try ShowMessage ('Start'); try ShowMessage ('trying');
try ShowMessage ('still trying'); finally ShowMessage ('going...'); end;
except ShowMessage ('except'); end;
finally ShowMessage ('Finally!'); end;

end;

procedure Simple;
begin

try
TesttryProc;
except
end;

try
TesttryProc;
except
SHowMessage('It Failed');
end;


end;


procedure ExceptBlock;
begin
try
TesttryProc;
except
on E: Exception do
begin
ShowMessage('There was an exception: ' + E.Message);
end;

end;
end;

procedure complex;
var
liLoop: integer;
begin
try
liLoop := 0;
while liLoop < 10 do
begin
TesttryProc;
inc(liloop);
end;
except
on E: Exception do
begin
ShowMessage('There was an exception: ' + E.Message);
end;

end;
end;



end.
