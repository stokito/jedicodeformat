{
 AFS 14 feb 2002
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

test cases submitted by Grahame Grieve
 failed badly in 0.62

 Since expanded upon
 with some variations of the theme of  vars of anonymous fn types


 }
unit Testgg;

interface

const
  Long_string =
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf'+
    'sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf';


type  TDiskSpacfn = function (Directory: PChar; var FreeAvailable,
    TotalSpace: integer; TotalFree: pointer): Boolean stdcall;
var
  GetDiskFreeSpaceEx: TDiskSpacfn = nil;


var
  GetDiskFreeSpaceEx2: function (Directory: PChar; var FreeAvailable,
    TotalSpace: integer; TotalFree: pointer): Boolean stdcall = nil;

var
 fred: function(p: pointer): Boolean;
 fred2: procedure(p: pointer);
 fred3: function: pointer;

 fredn: function(p: pointer): Boolean = nil;
 fredn2: procedure(p: pointer) = nil;
 fredn3: function: pointer = nil;


 fredx: function(p:
  pointer): Boolean = nil;
 fredx2: procedure(p:
  pointer) = nil;
 fredx3: function:
  pointer = nil;


procedure Test;

implementation

uses dialogs, sysutils;

procedure Test1;
begin
  showmessage('hi');
end;

procedure Test;
begin
{$IFDEF WIN32}
  try
    Test1;
  except
    on e:exception do
      begin
      end;
  end;
{$ELSE}
  TestForward;
{$ENDIF}
end;

procedure Test2;
begin
  showmessage('hi');
end;


end.

