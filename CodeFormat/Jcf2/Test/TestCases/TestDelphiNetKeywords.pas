unit TestDelphiNetKeywords;

interface

implementation

procedure DelphiNetKeywordAbuse;
var
  operator: integer;
  helper: string;
  sealed, static: char;
begin
  operator := 12;
  sealed := 'A';
  static := 'b';
  helper := sealed + static;
  inc(operator);
end;

end.
