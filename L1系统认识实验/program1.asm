SSTACK SEGMENT STACK        ;定义堆栈
           DW 32 DUP(?)
SSTACK ENDS

CODE SEGMENT
          ASSUME CS:CODE,SS:SSTACK
    START:
          PUSH   DS
          XOR    AX,AX
          MOV    SI,3000H             ;数据起始地址
          MOV    CX,16                ;循环次数，放置数据个数
    AA1:
          MOV    [SI],AL
          INC    SI                   ;地址自加
          INC    AL                   ;数据自加
          LOOP   AA1
    AA2:
          JMP    AA2
CODE ENDS
    END START