unit frAbout;

interface

uses
  { delphi }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  { local }
  SettingsFrame;

type
  TFrameAbout = class(TfrSettingsFrame)
    Panel1: TPanel;
    imgOpenSource: TImage;
    mWarning: TMemo;
    mWhat: TMemo;
    lblMPL: TStaticText;
    lblHomePage: TStaticText;
    procedure lblHomePageClick(Sender: TObject);
    procedure imgOpenSourceClick(Sender: TObject);
    procedure lblMPLClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;

    procedure Read; override;
    procedure Write; override;

  end;

  
implementation

{$R *.DFM}

uses
  { delphi } URLMon,
  { jcl } JclStrings,
  { local } ConvertTypes;

procedure ShowURL(const ps: string);
var
  lws: WideString;
begin
  lws := ps;
  HLinkNavigateString(nil, pWideChar(lws));
end;

constructor TFrameAbout.Create(AOwner: TComponent);
var
  ls: string;
begin
  inherited;

  // show the version from the program constant
  ls := mWhat.Text;
  StrReplace(ls, '%VERSION%', PROGRAM_VERSION);
  StrReplace(ls, '%DATE%', PROGRAM_DATE);
  mWhat.Text := ls;
end;

procedure TFrameAbout.Read;
begin
  // do nothing
end;

procedure TFrameAbout.Write;
begin
  // do nothing
end;

procedure TFrameAbout.lblHomePageClick(Sender: TObject);
begin
  ShowURL(lblHomePage.Caption);
end;

procedure TFrameAbout.imgOpenSourceClick(Sender: TObject);
begin
  ShowURL('http://www.delphi-jedi.org')
end;

procedure TFrameAbout.lblMPLClick(Sender: TObject);
begin
  ShowURL(lblMPL.Caption)
end;

end.
