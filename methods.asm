.data
	sLN db 13,10,'$';ʳ���� ������
	sSlash db '\$'	
;����� ��� ������
	vFileHandle DW ?
	vFileName db "mp.txt",0
	vFileHandleTMP DW ?
	vFileNameTMP db "mp_tmp.txt",0	;��������� ����
;����
	vString20 db 20 dup (' ')
	vInt10	db 10 dup(' ')	
	vEmplIdent dw 0 ;Index
	vEmplCount	dw 0 ; Count
;����� ��� ����������
	sCode		db 5 dup(32),'CODE(4 numbers): $'
	sName		db 5 dup(32),'Name: $'
	sPosition		db 5 dup(32),'Position: $' ; ������
	sUnit	db 5 dup(32),'Unit: $' ; ϳ������
	sExperience		db 5 dup(32),'Experience: $'	
	sMoney		db 5 dup(32),'Salary: $'	
	sEmplIdent 		db 5 dup(32),'Index: $'	
	sEmplCount 		db 5 dup(32),'People count: $'
	schName db 5 dup(32),13,10,'$'
	sStat		 db 25 dup(32),"<<<  Total nubmer of employees >>>$"
	sScroll db 14 dup(32),"<<< Catalog of workers!Press 4/5 to change employe.. >>>$"
	sAddEmpl db 12 dup(32),"<<<  Add new employe! Type the parameters, please.. >>>$"	
	sDone	 db 13,10,"Done!$"
	sCanceled		 db 13,10,"Canceled!$"
	sErr db 13,10,"Employe not found!$"
	sEMopen db '***Error! Cannt open file!**',13,10,'$'
	sEMaxCNT DB	'***Error! Cannt add employe! There are to many of them!**',13,10,'$'
;C�������� �������
  mCode 	db 4 dup(32),13,10,'$'
  mName 	db 10 dup(32),13,10,'$'
  mPosition		db 10 dup(32),13,10,'$'
  mUnit	db 10 dup(32),13,10,'$'
  mExperience 	db 2 dup(32),13,10,'$'
  mMoney db 6 dup(32),13,10,'$'
  vStructSize dw 49 ;������ ���������
  vAllStruct  db 49 dup(?)


.code
Init PROC 
	mov AX, @data
	mov DS, AX
	mov ES, AX
; �������� ����
   	MOV  AL, 3		; AL - ��� ������ 80*25 (16 �������)
	 MOV  AH, 0		
   	 INT  10H 		
; ��������� ����, ��� ���� ����� �������
	mov  al,0    
	xor CX,CX    
	mov  dh,24
	mov  dl,79   
	mov bh,0F0h		; ��������
	 mov AH, 07h 	; �������� ����
	 INT 10h	 
; ���� ��������� ��������	 
	lea DX, sProgramTitle
	call write
; ������� �����
	call OpenFiles
	mov vEmplIdent,0
;���������� ������ ���� ������
	mov AL, 2	; ���� ���� ���� �����
	mov CX, 0
	mov DX, 0
	mov BX, vFileHandle
	 mov AH, 42h
	 INT 21h	
	div vStructSize
	mov vEmplCount, AX
ret
Init ENDP

Destr PROC 
; �������� �����
	call CloseFiles
ret
Destr ENDP

PrintStat PROC 
	lea DX, sStat
	call writeln
;���� �-�� ����������
	lea DX, sEmplCount
	call write
	mov AX, vEmplCount
	call WriteInt
	
ret
PrintStat ENDP


PrintEmployee PROC ;���� ������� ����������

	lea DX, sScroll
	call writeln	
	mov vEmplIdent,0
	call ShowEm
ret
PrintEmployee ENDP


PrevEmployee PROC 

	lea DX, sScroll
	call writeln
	DEC vEmplIdent
	call ShowEm
	cmp AX, 0FFFh
	je FirstE
ret
FirstE: ; ���� �� ��� ��� ������ �� �������� ����
	INC vEmplIdent
	call ShowEm
ret
PrevEmployee ENDP


ViewEmployee PROC 
	lea DX, sScroll
	call writeln
	
	call SrchEmProc
	cmp ax,0
	je SrchErr
	
	call ShowEm
ret
SrchErr:;�� �������
	lea dx, sErr
	call write
ret
ViewEmployee ENDP


NextEmployee PROC 
	lea DX, sScroll
	call writeln
	
	INC vEmplIdent
	call ShowEm
	cmp AX, 0FFFh
	je LastEm
ret
LastEm:	; ���� �� ��� ��� �������� ��������� �� �������� ����
	DEC vEmplIdent
	call ShowEm
ret
NextEmployee ENDP


AddEmployee PROC 
;��������� � ����� �����
	lea DX, sAddEmpl
	call writeln
	
	cmp vEmplCount,1100
	jg MaxCNT
	mov AX, vEmplCount
	mov vEmplIdent, AX
	call AddEdEmpl
ret
MaxCNT:
	lea DX, sEMaxCNT
	call writeln
ret
AddEmployee ENDP

RemoveEmployee PROC 
;-//- ��������� ��� ��������� ���������� �� ��������
; ������� � ���� ���� ��� ��� ���� �� ������� ���� ��������
	mov BX, vFileHandle
	mov AL, 0
	xor DX,DX
	xor CX,CX
	 mov AH, 42h
	 INT 21h

xor SI, SI
mov CX, vEmplCount
CopyCycle1:
	push CX
	;COPY
	mov CX, vStructSize
	mov BX, vFileHandle
	lea DX, vAllStruct
	 mov AH, 3fh
	 INT 21h

	cmp SI, vEmplIdent		;���� ����� � ��� ���� ������ ���������
	je nextEm				;�� �� �������� � ���� ����
	
	mov CX, AX
	mov BX, vFileHandleTMP
	lea DX, vAllStruct
	 mov AH, 40h
	 INT 21h	

	nextEm:
	INC SI
	pop CX
loop CopyCycle1
; � ���� ���� ���� ���, ����� ��������� ������� ������ �����, 
; �������� ����, ���� ���� ������������, � ������� �����
	call CloseFiles
	; ��������� ���� � ������������
	lea DX, vFileName
	 mov AH,41h 
	 INT 21h
	; ������������ ���� ����
	lea DX, vFileNameTMP
	lea DI, vFileName
	 mov AH, 56h
	 INT 21h
	call OpenFiles
	DEC vEmplCount
; ���� ���������� �����������
	lea DX, sDone
	call write	
ret
RemoveEmployee ENDP 

ShowEm PROC 
;-//- ��������� ������ �� ����� ����������
	call ReadEmloyee		;������ � ����� ���
	cmp AX, 6			;���� ���� ������ �� ����� �������� 
	je	PtrEm
mov AX, 0FFFh
ret
PtrEm:
;-//- �������� �� ��������� �� �����		
	lea DX, sEmplIdent
	 call write
	mov AX, vEmplIdent
	INC AX		; ��� ���������� ���� � "1"
	 call WriteInt
	lea DX,sLN
	 call Write
	
	lea DX, sName;Naoborot yaksho sho
	 call write
	lea DX, mName;Naoborot yaksho sho
	 call write
	 
	lea DX, sCode;Naoborot yaksho sho
	 call write
	lea DX, mCode;Naoborot yaksho sho
	 call write	
	 
	lea DX, sPosition
	 call write
	lea DX, mPosition
	 call write		 
	 
	lea DX, sUnit
	 call write
	lea DX, mUnit
	 call write	
	 
	lea DX, sExperience
	 call write
	lea DX, mExperience
	 call write	

	lea DX,sMoney
	call write
	lea DX,mMoney
	call write
		 
ret
ShowEm ENDP

AddEdEmpl PROC 
; ��������� ���������� ������ ����������

;-//- ��� ���������� 
	lea DX,sName
	call write
	
	call ReadString20
	cmp ax,0;���� ���������� ��� ����� ������ �� ��������
	jne NotCanceled
	
	lea DX, sCanceled
	call write	
ret
NotCanceled:

; ��������� � ���� ������
	xor SI, SI
	mov CX,10
To_mName:	
	mov AL,vString20[SI]
	mov mName[SI],AL
	INC SI
loop To_mName

;-//- ��� ����������
	lea DX, sLN
	call write
	lea DX, sCode
	 call write

	 mov AX,4
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,4
To_mCode:	
	mov AL,vInt10[SI]
	mov mCode[SI],AL
	INC SI
loop To_mCode

;-//- ������
	lea DX, sLN
	call write
	lea DX, sPosition
	 call write
	 
	 call ReadString20
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,10
To_mPosition:	
	mov AL,vString20[SI]
	mov mPosition[SI],AL
	INC SI
loop To_mPosition

;-//- ����� ��������
	lea DX, sLN
	call write
	lea DX, sUnit
	 call write
	 
	 call ReadString20
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,10
To_mUnit:	
	mov AL,vString20[SI]
	mov mUnit[SI],AL
	INC SI
loop To_mUnit

;-//- ����
	lea DX, sLN
	call write
	lea DX, sExperience
	 call write
	 
	 mov AX,2
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,2
To_mExperience:	
	mov AL,vInt10[SI]
	mov mExperience[SI],AL
	INC SI
loop To_mExperience
;-\\- �������� �����
	lea DX, sLN
	call write
	lea DX, sMoney
	 call write
	 
	 mov AX,6
	 call ReadInt10
; ��������� � ���� ������	 
	xor SI, SI
	mov CX,6
To_mMoney:	
	mov AL,vInt10[SI]
	mov mMoney[SI],AL
	INC SI
loop To_mMoney
; ������������� ����� � ����
	
	call WriteEmploy
	
	INC vEmplCount
	lea DX, sDone
	call write
ret
AddEdEmpl ENDP 

SrchEmProc PROC 
	mov AH,9
	mov dx,offset sName
	int 21h
;������� ��� 
	mov cx,20
	xor si,si
cycle_zanul:
	mov schName[si],' '
	inc si
loop cycle_zanul
	xor si,si
	xor AX,AX
	xor BX,BX
	
	mov AH,3fh
	mov dx,offset schName
	mov cx, 25
	int 21h
; ��������� ������ ��� ������ �������(13,10)
mov SI,ax
mov schName[si-2],32
mov schName[si-1],32
	
	cmp vEmplCount,0
	je msNotFound
	
	mov vEmplIdent,0
	mov cx, vEmplCount
	
SearchCycle:
push CX
		call ReadEmloyee
		xor si,si
	cmpEmployee:	
		mov al,schName[si]
		mov ah, mName[si]
		cmp ah,al
		 jne nextSrchEM
		inc si
		cmp si,10 ;!
		je msFound
	jmp cmpEmployee
nextSrchEM:
	inc vEmplIdent
pop CX	
loop SearchCycle

; ���� �� ��������
msNotFound:
mov ax, 0
ret
; ���� ��������
msFound:
pop cx
mov ax, 1
ret
SrchEmProc ENDP


ReadString20 PROC ;(out vString20)
; ��������� ��� ������� 20 �������
	xor SI, SI
	mov CX,20
zanulStr20:	
	mov vString20[SI],' '
	INC SI
loop zanulStr20
	xor SI, SI
readChar:
	call ReadKeyProc	; ������ ������
	 
	cmp AL, 8
	je BackSlash
	cmp AL, 13				; �� �� ��������� �����
	je returnStr20
	cmp AL, 32				; ���� ����������� �� ������ ������
	jl readChar
	cmp AL, 122
	jg readChar
	 
	cmp SI, 20				; ���� 20 ������	
	jge readChar			; �� ���������� ������ �� ���������� ������
	
	mov DL, AL
	mov AH,2h
	INT 21h
	

	mov vString20[SI], AL	; �������� � �����
	INC SI	
	jmp readChar
returnStr20:
	mov AX, SI
ret
BackSlash:; <- ������� �������� ������, �������� ������
	cmp SI,0
	je readChar
	
	mov vString20[SI],32
	dec SI	
	mov   bh, 0    ;³���������� 0
	 mov   ah, 3
	 int   10h
dec DL
	mov   bh, 0    ;³���������� 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-���  ������� 
mov  bh,0        ;   ³���������� 0 
mov  cx,1        ;   ˳�������  ���������� 
	  mov  ah, 0Ah
	  int  10h

jmp readChar
ReadString20 ENDP 


ReadInt10 PROC ;(out vString20)
; ��������� ��� ������� 10-�������� �����
	xor SI, SI
	push AX 	; �������� ���� �-��� ����
	mov CX, 10
zanulInt10:	
	mov vInt10[SI],' '
	INC SI
loop zanulInt10
	xor SI, SI
mReadInt:
	call ReadKeyProc	; ������ ������
	 
	cmp AL, 8
	je BackSlashI
	cmp AL, 13				; �� �� ��������� �����
	je returnInt10
	cmp AL, 30h				; ���� ����������� �� ������ ������
	jl mReadInt
	cmp AL, 39h
	jg mReadInt
	 
	pop BX
	push BX
	cmp SI, BX				; ���� 20 ������		
	jge mReadInt			; �� ���������� ������ �� ���������� ������
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	mov vInt10[SI], AL	; �������� � �����
	INC SI	
	jmp mReadInt
returnInt10:
	mov AX, SI
	pop SI
ret
BackSlashI:; <- ������� �������� ������, �������� ������
	cmp SI,0
	je mReadInt
	
	mov vInt10[SI],32
	dec SI	
;������� ��������� ������� �� ���� ����
	mov   bh, 0    ;³���������� 0
	 mov   ah, 3	
	 int   10h
dec DL
	mov   bh, 0    ;³���������� 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-���  ������� 
mov  bh,0        ;   ³���������� 0 
mov  cx,1        ;   ˳�������  ���������� 
	  mov  ah, 0Ah
	  int  10h

jmp mReadInt
ReadInt10 ENDP 


OpenFiles PROC 
; ��������� ��� ���������� �����
	lea SI, vFileName
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 1			; ³������ �������� ����
	 mov AX, 716Ch	 	 
	 INT 21h
	jc createFile		; ���� ��������� ������� �� ���������
mov vFileHandle, AX
jmp createTMPfile
createFile: ; ��������� ����� �����
	lea SI, vFileName
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 10h			; ��������� �����
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandle, AX
	
createTMPfile:
	lea DX, vFileNameTMP
	 mov AH,41h 
	 INT 21h

; ��������� ����� �����
	lea SI, vFileNameTMP
	mov BX, 2			; ������/�����
	mov CX, 0			; ��������� ����
	mov DX, 10h			; ��������� �����
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandleTMP, AX
	
ret
OpenFiles ENDP


CloseFiles PROC 
; ��������� ��� ���������� �����
	mov BX, vFileHandle
	 mov AH, 3eh
	 int 21h
	mov BX, vFileHandleTMP
	 mov AH, 3eh
	 int 21h	 
ret
CloseFiles ENDP

	 
ReadEmloyee PROC 

mov BX, vEmplIdent
mov AX, vStructSize
mul BX
mov DX, AX

mov BX, vFileHandle
mov CX, 0
mov AL, 0
 mov AH,42h
 INT 21h
 
 ; ������ 10 �������
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mName
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ 4 ������a
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mCode
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ 10 �������
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mPosition
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; ������ 10 �������
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mUnit
	 mov AH, 3fh
	 INT 21h
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ������ 2 �������
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mExperience
	 mov AH, 3fh
	 INT 21h 	 
	; ������� �� 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; ������ 6 �������
	mov CX, 6
	mov BX, vFileHandle
	lea DX, mMoney
	 mov AH, 3fh
	 INT 21h
	push AX
	; ������� �� 2 (13,10)
	mov AL, 1
	mov CX, 0	
	mov DX, 2	
	 mov AH, 42h
	 INT 21h		 
	 
	pop AX
ret
ReadEmloyee ENDP

WriteEmploy PROC 
; ��������� ��� ���������� ����� � ����
	mov AX, vStructSize
	mul vEmplIdent
	mov DX, AX
	
	mov AL, 0	; ���� ���� ������� �����	
	mov CX, 0
	mov BX, vFileHandle
	 mov AH, 42h
	 INT 21h	

	mov CX, 10
	mov BX, vFileHandle
	lea DX, mName

	 mov AH, 40h
	 INT 21h
	
	mov CX, 1		;/
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mCode
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;/
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mPosition
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;/
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	 
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mUnit
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;/
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h
	
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mExperience
	 mov AH, 40h
	 INT 21h

	mov CX, 1		;/
	mov BX, vFileHandle
	lea DX, sSlash
	 mov AH, 40h
	 INT 21h

	mov CX, 6
	mov BX, vFileHandle
	lea DX, mMoney
	 mov AH, 40h
	 INT 21h
	 	 
	mov CX, 2		;(13,10) (13,10) (13,10) (13,10)
	mov BX, vFileHandle
	lea DX, sLN
	 mov AH, 40h
	 INT 21h	 
ret
WriteEmploy ENDP
