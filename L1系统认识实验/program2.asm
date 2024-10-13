DATA SEGMENT
    SOURCE DB 8 DUP(?) ; 源数据区域，预留 8 个字节
    DESTINATION DB 8 DUP(?) ; 目标数据区域，预留 8 个字节
DATA ENDS

SSTACK SEGMENT STACK
    DW 32 DUP(?) ; 堆栈区
SSTACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, SS:SSTACK, DS:DATA
START:
    ; 初始化数据段
    MOV AX, DATA
    MOV DS, AX

    ; 设置源和目标地址
    MOV SI, 3500H ; 源地址
    MOV DI, 3600H ; 目标地址
    MOV CX, 8     ; 要复制的数据个数

COPY_LOOP:
    MOV AL, [SI]  ; 从源地址读取数据
    MOV [DI], AL  ; 写入目标地址
    INC SI        ; 源地址递增
    INC DI        ; 目标地址递增
    LOOP COPY_LOOP ; 循环直到 CX 减到 0

    ; 无限循环
END_LOOP:
    JMP END_LOOP

CODE ENDS
    END START