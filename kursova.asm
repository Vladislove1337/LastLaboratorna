.model small
.stack 100h
.code

START:      
    call Init           ; i�i�i��i���i�
    call ShowMainMenu   ; ���� ��������   
    ReadUserAction:
    mov al, 25
    call CursorToLine       ; ������ � �����ii �� ���� ������� (25 ����� ����� ����)
    call ReadKeyProc        ; ������� � ���������
      
    sub AL, 30h
;�������� ��������� ������
    cmp AL,0
    jl ReadUserAction
    cmp AL,9
    jg ReadUserAction
    
    call ClrPartScr
;��� �����������( ����)
    cmp AL, 1
     je ACTION_stat     
     
    cmp AL, 3
     je ACTION_print    
     
    cmp AL, 4
     je ACTION_prev     
     
    cmp AL, 6
     je ACTION_view     
     
    cmp AL, 5
     je ACTION_next    
     
    cmp AL, 2  
     je ACTION_add     
     
    cmp AL, 7        
     je ACTION_remove   
     
    cmp AL, 0   
     je EXIT            
     
jmp ReadUserAction; �������� ��������� ������

ACTION_stat:
    call PrintStat
    jmp ReadUserAction

ACTION_print:
    call PrintEmployee
    jmp ReadUserAction
    
ACTION_prev:
    call PrevEmployee
    jmp ReadUserAction
    
ACTION_view:
    call ViewEmployee
    jmp ReadUserAction
    
ACTION_next:
    call NextEmployee
    jmp ReadUserAction
    
ACTION_add:
    call AddEmployee
    jmp ReadUserAction
    
ACTION_remove:
    call RemoveEmployee
    jmp ReadUserAction
    
; �����
EXIT:
    call Destr          

    mov AX, 4C00h
    INT 21h

include inter.asm       ; ���������
include methods.asm     ; ������

end start
