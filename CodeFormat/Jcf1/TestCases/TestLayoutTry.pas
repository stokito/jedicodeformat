unit TestLayoutTry;

{ AFS 16 Jan 2002

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests indentation around some try blocks under if statments
}


interface

implementation

uses Dialogs;

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


procedure Test2;
begin

  try
    TryProc;
  finally
    FinallyProc;
  end;

  try
    TryProc;
  except
    ShowMessage('Exception!');
  end;

end;


procedure Test3;
begin

  try
    begin
      TryProc;
    end
  finally
    begin
      FinallyProc;
    end
  end;

  try
    begin
      TryProc;
    end
  except
    begin
      ShowMessage('Exception!');
    end
  end;

end;

procedure Test4;
begin

  try
    begin

      try
        begin
          TryProc;
        end
        except
        begin
          ShowMessage('Exception!');
        end
      end;

    end
    finally
    begin
      FinallyProc;
    end
  end;

  try
    begin

      try
        begin
          TryProc;
        end
        finally
        begin
          FinallyProc;
        end
      end;

    end
    except
    begin
      ShowMessage('Exception!');
    end
  end;

end;

end.
