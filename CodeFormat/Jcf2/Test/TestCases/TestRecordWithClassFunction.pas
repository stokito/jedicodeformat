unit TestRecordWithClassFunction;

{ AFS July 2008

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 Test a class function on a record type
}

interface

type
  TTestRecord = record
  private
    _lo: UInt64;
    _hi: int64;
  public
    class function Create(low: UInt64; high : Int64): TTestRecord; static;
  end;

implementation


class function TTestRecord.Create(low: UInt64; high: Int64): TTestRecord;
begin
   Result._lo := low;
   Result._hi := high;
end;

end.
