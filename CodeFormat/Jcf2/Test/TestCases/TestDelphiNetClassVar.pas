unit TestDelphiNetClassVar;

{ AFS 9 Sept 2005
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code tests Delphi.Net use of "var" in a clas declaration
}

interface

type
  TEOMReport = class(TObject)
  private
    { Private declarations }
    var
      rTop20ClRefer,
      rPstOfTotalCR,
      rTop20SL,
      rPstOfTotalSL,
      rTop20CA,
      rPstOfTotalCA   : Real;
    procedure FetchTop20CurrentAccount;
  public
    procedure TransferTop20CurrentAccount;
  end;

type
  TFooReport = class(TObject)
  private
    var
      foo, bar: string;
      fish, boo: integer;

    function Wibble: integer;

    var
      goo, gar, gib: integer;
    var
      soo, dar: integer;
      thing: string;

  end;


  TFooClass = Class
  var
    a1: integer;
  private
    var
    b2: string;
    b3: integer;
  protected
    var
    c3, c4, c5: boolean;
  public
    var
    d6: TObject;

  end;

implementation

procedure TEOMReport.FetchTop20CurrentAccount;
begin
  // test
end;

procedure TEOMReport.TransferTop20CurrentAccount;
begin
  // test
end;


{ TFooReport }

function TFooReport.Wibble: integer;
begin
  result := 3;
end;

end.
