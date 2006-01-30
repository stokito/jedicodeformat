unit TestDelphiNetRecordProcs;

interface

type
  TSomeRecord = record
    i,j,k,l: integer;

    function Sum: integer;
    procedure Clear;

    constructor Create(iValue: integer);
  end;

  // a record with operator overloads
  TOpRecord = record
    i: integer;
    s: string;

    class operator Add(A,B: TOpRecord): TOpRecord;
    class operator Equal(A, B: TOpRecord) : Boolean;

    class operator Implicit(A: TOpRecord): Integer;
    class operator Implicit(A: integer): TOpRecord;
  end;

implementation


{ TSomeRecord }

procedure TSomeRecord.Clear;
begin
  i := 0;
  j := 0;
  k := 0;
  l := 0;
end;

constructor TSomeRecord.Create(iValue: integer);
begin
  Clear;
  i := iValue;
end;

function TSomeRecord.Sum: integer;
begin
  Result := i + j + k + l;
end;

{ TOpRecord }

class operator TOpRecord.Add(A, B: TOpRecord): TOpRecord;
begin
  Result.i := A.i + B.i;
  Result.s := a.s + b.s;
end;

class operator TOpRecord.Equal(A, B: TOpRecord): Boolean;
begin
  Result := (a.i = b.i) and (a.s = b.s);
end;

class operator TOpRecord.Implicit(A: integer): TOpRecord;
begin
  Result.i := A;
  Result.s := '';
end;

class operator TOpRecord.Implicit(A: TOpRecord): Integer;
begin
  Result := A.i;
end;

end.
