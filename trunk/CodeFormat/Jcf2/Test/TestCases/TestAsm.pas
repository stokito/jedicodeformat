unit TestASM;

{ AFS 27 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This code test ASM blocks
 Since I don't know any ASM
 I lifted this code from the Delphi VCL source
 I deleted bits until it compiled, then randomised a few lines so
 it's not like I'm redistributing thier source.
}

interface

procedure ProcASM1;
procedure ProcASM2;
procedure ProcASM3;


implementation

uses Dialogs;

{ proc with embedded ASM }
procedure ProcASM1;
var
  li1, li2: integer;
  lb: Boolean;
begin
  li1 :=  Random (10);
  li2 := Random (10);

  asm

    MOV     EAX,li1
          PUSH    DWORD PTR [EDX]
        MOV     EDX,[EBP+8]
ADD     ESP,4
CALL    DWORD PTR ProcASM2
    MOV     lb,AL
  end;

  li1 := li1 + li2;

end;

{ proc that is all ASM }
procedure ProcASM2;
asm
        TEST    CL,CL
        JNE     @@isDll
  MOV     EAX,[EDX+EAX*4]
    MOV     CL,ModuleIsLib
          MOV     EAX,TlsIndex
        RET

@@initTls:
        CALL    ProcASM3
        MOV     EAX,TlsIndex
        JE      @@RTM32
CALL    ProcASM1
PUSH    EAX
        TEST    EAX,EAX
        RET

@@RTM32:
        RET

@@isDll:
        PUSH    EAX
         TEST    EAX,EAX
          CALL    ProcASM3
          JE      @@initTls
end;


{ proc with more than one ASM }
procedure ProcASM3;
var
  li1, li2: integer;
begin
  li1 :=  Random (10);
  li2 := Random (10);

  asm
    MOV   ECX, [EDX]
    XCHG  ECX, [EAX]
    CALL    ProcASM2
    XCHG  ECX, [EAX]
    MOV   [EDX], ECX
  end;

  li1 := li1 + li2;
  li2 := Random (10);

  if li2 > 5 then
  begin
    ShowMessage ('More Asm');

    asm
      MOV   [EDX], ECX
      MOV   ECX, [EDX]
      PUSH    EAX
      XCHG  ECX, [EAX]
    end;

    li2 := li1 + li2;
  end;

end;

end.
