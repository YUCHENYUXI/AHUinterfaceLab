SSTACK SEGMENT STACK            ;堆栈段
             DW 32 DUP(?)
SSTACK ENDS
CODE SEGMENT
            ASSUME CS:CODE
      START:
            PUSH   DS

            MOV    AX, 0000H
            MOV    DS, AX

      ; 初始化中断向量表
      ; [IRQ7]:CS:MIR7
      ; IR7 低三位为111B，高5位为00001B
      ; 中断类型号为 00001111B
      ; 可算得中断向量表起始地址为 0011 1100B = 3CH
            MOV    AX, OFFSET MIR7      ;取中断入口地址
            MOV    SI, 003CH            ;中断矢量地址
            MOV    [SI], AX             ;填 IRQ7 的偏移矢量  OFFSET MIR7

            MOV    AX, CS               ;段地址
            MOV    SI, 003EH
            MOV    [SI], AX             ;填 IRQ7 的段地址矢量 CS
      ; 原子操作
      ; 初始化主片 8259
            CLI                         ;关中断

            POP    DS
            MOV    AL, 11H
            OUT    20H, AL              ;ICW1 = 11H = 0001 0001B
      ; 边沿触发模式，级联使用模式，设置ICW4

            MOV    AL, 08H
            OUT    21H, AL              ;ICW2
      ; 00001000B
      ; 00001为中断向量地址

            MOV    AL, 04H
            OUT    21H, AL              ;ICW3
      ; 00000100B
      ; IR2上接有一从片

            MOV    AL, 01H
            OUT    21H, AL              ;ICW4
      ; 0000 0001B
      ; 全嵌套方式，非缓冲方式，非自动结束中断，8086配置

            MOV    AL, 6FH              ;OCW1
            OUT    21H, AL
      ; 0110 1111B
      ; 使用IR7,4；其余中断信号接口在本次实验中屏蔽不用

            STI                         ; 开中断，完成主片初始化

      AA1:  NOP
      ; 结束NOP指令，等待中断信号，如果没有中断信号则继续循环
            JMP    AA1

      MIR7: STI                         ; 允许全嵌套（仅允许IR7被IR4嵌套，不允许同级嵌套）
            CALL   DELAY

            MOV    AX, 0137H
            INT    10H                  ; 显示字符 7

            MOV    AX, 0120H            ; space
            INT    10H

            MOV    AL, 20H
            OUT    20H, AL              ; 中断结束命令 EOI
            IRET                        ; 返回AA1

      DELAY:PUSH   CX
            MOV    CX, 0F00H

      ;等待嵌套
      AA0:  PUSH   AX
            POP    AX
      ; why?
            LOOP   AA0

            POP    CX

            RET
CODE ENDS
 END START