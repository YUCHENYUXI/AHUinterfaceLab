SSTACK SEGMENT STACK            ;堆栈
             DW 32 DUP(?)
SSTACK ENDS
CODE SEGMENT
            ASSUME CS:CODE
      START:PUSH   DS                    ;保护DS

            MOV    AX, 0000H
            MOV    DS, AX
            MOV    AX, OFFSET MIR7       ;取中断服务子程序入口偏移地址送中断向量偏移地址003CH(111100B - 1 111B - 中断类型号7(MIR7))
            MOV    SI, 003CH             ;中断矢量地址
            MOV    [SI], AX              ;填 IRQ7 的偏移矢量
            MOV    AX, CS                ;段地址
            MOV    SI, 003EH
            MOV    [SI], AX              ;填 IRQ7 的段地址矢量
      ;or
      ;mov ax,cs
      ;mov ds,ax
      ;mov dx,offset mir7
      ;mov ah,25h
      ;mov al,1111B
      ;int 21h
            MOV    AX, OFFSET SIR1
            MOV    SI, 00C4H
            MOV    [SI], AX
            MOV    AX, CS
            MOV    SI, 00C6H
            MOV    [SI], AX

            CLI
            POP    DS
      ;初始化主片 8259
            MOV    AL, 11H
            OUT    20H, AL               ;ICW1
      ; ICW1 = 11H = 0001 0001B
      ; 边沿触发模式，级联使用模式，设置ICW4
            MOV    AL, 08H
            OUT    21H, AL               ;ICW2
      ; 00001000B
      ; 00001为中断类型高5位
            MOV    AL, 04H
            OUT    21H, AL               ;ICW3
      ; 00000100B
      ; IR2上接有一从片
            MOV    AL, 01H
            OUT    21H, AL               ;ICW4
      ; 0000 0001B
      ; 全嵌套方式，非缓冲方式，非自动结束中断，

      ;初始化从片 8259
            MOV    AL, 11H
            OUT    0A0H, AL              ;ICW1
            =      11H = 0001 0001B
      ; 边沿触发模式，级联使用模式，设置ICW4
            MOV    AL, 30H
            OUT    0A1H, AL              ;ICW2
      ; 0011 0xxxB

            MOV    AL, 02H
            OUT    0A1H, AL              ;ICW3
      ; 0010B
      ; 从片接在主片的IR2上
            MOV    AL, 01H
            OUT    0A1H, AL              ;ICW4
      ; 全嵌套方式，非缓冲方式，非自动结束中断，8086配置
      ;
            MOV    AL, 0FDH
            OUT    0A1H,AL               ;从OCW1 = 1111 1101
      ; 中断屏蔽,只允许 SIR 1 号中断通过
            MOV    AL, 6BH               ;0110 1011b
            OUT    21H, AL               ;主 8259 OCW1
      ; 中断屏蔽,只允许 MIR 2(从片 SIR 1 ),4(串口),7(中断) 通过
            STI
      ;-----
      AA1:  NOP
            JMP    AA1
      ;中断循环
      ; 主片 7号中断程序
      MIR7: CALL   DELAY
            MOV    AX, 014DH
            INT    10H                   ;M
            MOV    AX, 0137H
            INT    10H                   ;显示字符 7
            MOV    AX, 0120H
            INT    10H
            MOV    AL, 20H
            OUT    20H, AL               ;中断结束命令
            IRET
      ; 从片 SIR1(接主片MIR2)
      SIR1: CALL   DELAY
            MOV    AX, 0153H

            INT    10H                   ;S
            MOV    AX, 0131H
            INT    10H                   ;显示字符 1
            MOV    AX, 0120H
            INT    10H
            MOV    AL, 20H
            OUT    0A0H, AL
            OUT    20H, AL
            IRET

      DELAY:PUSH   CX
            MOV    CX, 0F00H
      AA0:  PUSH   AX
            POP    AX
            LOOP   AA0
            POP    CX
            RET

CODE ENDS
 END START