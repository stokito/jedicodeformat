unit TestDelphiNetWebService;

{ AFS March 2006
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }

interface

uses
  System.Collections, System.ComponentModel,
  System.Data, System.Diagnostics, System.Web,
  System.Web.Services;

type
  /// <summary>
  /// Summary description for WebService1.
  /// </summary>
  TWebService1 = class(System.Web.Services.WebService)
  {$REGION 'Designer Managed Code'}
  strict private
    /// <summary>
    /// Required designer variable.
    /// </summary>
    components: IContainer;
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    procedure InitializeComponent;
  {$ENDREGION}
  strict protected
    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    procedure Dispose(disposing: boolean); override;
  private
    { Private Declarations }
  public
    constructor Create;

    // Sample Web Service Method
    [WebMethod(Description='A Sample Web Method')]
    function HelloWorld: string;

  end;

implementation

{$REGION 'Designer Managed Code'}
/// <summary>
/// Required method for Designer support - do not modify
/// the contents of this method with the code editor.
/// </summary>
procedure TWebService1.InitializeComponent;
begin

end;
{$ENDREGION}

constructor TWebService1.Create;
begin
  inherited;
  //
  // Required for Designer support
  //
  InitializeComponent;
  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

/// <summary>
/// Clean up any resources being used.
/// </summary>
procedure TWebService1.Dispose(disposing: boolean);
begin
  if disposing and (components <> nil) then
    components.Dispose;

  inherited Dispose(disposing);
end;

// Sample Web Service Method
// The following method is provided to allow for testing a new web service.
(*
function TWebService1.HelloWorld: string;
begin
  Result := 'Hello World';
end;
*)

function TWebService1.HelloWorld: string;
begin
  Result := 'Hello, interweb';
end;

end.

