.data
	sLN db 13,10,'$';Кінець строки
	sSlash db '\$'	
;Файли для роботи
	vFileHandle DW ?
	vFileName db "mp.txt",0
	vFileHandleTMP DW ?
	vFileNameTMP db "mp_tmp.txt",0	;Буфферний файл
;Змінні
	vString20 db 20 dup (' ')
	vInt10	db 10 dup(' ')	
	vEmplIdent dw 0 ;Index
	vEmplCount	dw 0 ; Count
;Текст для інтерфейсу
	sCode		db 5 dup(32),'CODE(4 numbers): $'
	sName		db 5 dup(32),'Name: $'
	sPosition		db 5 dup(32),'Position: $' ; Посада
	sUnit	db 5 dup(32),'Unit: $' ; Підрозділ
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
;Cтруктура системи
  mCode 	db 4 dup(32),13,10,'$'
  mName 	db 10 dup(32),13,10,'$'
  mPosition		db 10 dup(32),13,10,'$'
  mUnit	db 10 dup(32),13,10,'$'
  mExperience 	db 2 dup(32),13,10,'$'
  mMoney db 6 dup(32),13,10,'$'
  vStructSize dw 49 ;розміри структури
  vAllStruct  db 49 dup(?)


.code
Init PROC 
	mov AX, @data
	mov DS, AX
	mov ES, AX
; Очищення вікна
   	MOV  AL, 3		; AL - код режима 80*25 (16 кольори)
	 MOV  AH, 0		
   	 INT  10H 		
; Прокрутка вниз, для зміни байтів атрибут
	mov  al,0    
	xor CX,CX    
	mov  dh,24
	mov  dl,79   
	mov bh,0F0h		; атрибути
	 mov AH, 07h 	; прокручує вниз
	 INT 10h	 
; Вивід ЗАГОЛОВКА прогрпми	 
	lea DX, sProgramTitle
	call write
; відкритя файла
	call OpenFiles
	mov vEmplIdent,0
;визначення розміру бази данних
	mov AL, 2	; зсув щодо кінця файла
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
; закриття файла
	call CloseFiles
ret
Destr ENDP

PrintStat PROC 
	lea DX, sStat
	call writeln
;вивід к-сті працівників
	lea DX, sEmplCount
	call write
	mov AX, vEmplCount
	call WriteInt
	
ret
PrintStat ENDP


PrintEmployee PROC ;Вивід першого працівника

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
FirstE: ; якщо це вже був перший то виводимо його
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
SrchErr:;не найдено
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
LastEm:	; якщо це вже був останный працівник то виводимо його
	DEC vEmplIdent
	call ShowEm
ret
NextEmployee ENDP


AddEmployee PROC 
;додавання в кінець файлу
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
;-//- Процедура для видалення працівника під індексом
; копіюємо в темп файл все крім того що потрібно було видалити
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

	cmp SI, vEmplIdent		;якщо запис є той який потрібн овидалити
	je nextEm				;то не записуємо в темп файл
	
	mov CX, AX
	mov BX, vFileHandleTMP
	lea DX, vAllStruct
	 mov AH, 40h
	 INT 21h	

	nextEm:
	INC SI
	pop CX
loop CopyCycle1
; У темп файлі наші дані, тепер необхідно закрити обидва файли, 
; видалити файл, темп файл переіменувати, і відкрити файли
	call CloseFiles
	; видаляємо файл з працівниками
	lea DX, vFileName
	 mov AH,41h 
	 INT 21h
	; переіменовуємо темп файл
	lea DX, vFileNameTMP
	lea DI, vFileName
	 mov AH, 56h
	 INT 21h
	call OpenFiles
	DEC vEmplCount
; Вивід відповідного повідомлення
	lea DX, sDone
	call write	
ret
RemoveEmployee ENDP 

ShowEm PROC 
;-//- Процедура виводу на екран працівників
	call ReadEmloyee		;Читаємо з файлу дані
	cmp AX, 6			;якщо немає запису під таким індексом 
	je	PtrEm
mov AX, 0FFFh
ret
PtrEm:
;-//- виводимо із структури на екран		
	lea DX, sEmplIdent
	 call write
	mov AX, vEmplIdent
	INC AX		; щоб індексація була з "1"
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
; Процедура добавлення нового працівника

;-//- Імя працівника 
	lea DX,sName
	call write
	
	call ReadString20
	cmp ax,0;якщо користувач ввів пусту строку то виходимо
	jne NotCanceled
	
	lea DX, sCanceled
	call write	
ret
NotCanceled:

; копіювання в нашу строку
	xor SI, SI
	mov CX,10
To_mName:	
	mov AL,vString20[SI]
	mov mName[SI],AL
	INC SI
loop To_mName

;-//- Код працівника
	lea DX, sLN
	call write
	lea DX, sCode
	 call write

	 mov AX,4
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,4
To_mCode:	
	mov AL,vInt10[SI]
	mov mCode[SI],AL
	INC SI
loop To_mCode

;-//- Посада
	lea DX, sLN
	call write
	lea DX, sPosition
	 call write
	 
	 call ReadString20
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,10
To_mPosition:	
	mov AL,vString20[SI]
	mov mPosition[SI],AL
	INC SI
loop To_mPosition

;-//- Назва підрозділу
	lea DX, sLN
	call write
	lea DX, sUnit
	 call write
	 
	 call ReadString20
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,10
To_mUnit:	
	mov AL,vString20[SI]
	mov mUnit[SI],AL
	INC SI
loop To_mUnit

;-//- Стаж
	lea DX, sLN
	call write
	lea DX, sExperience
	 call write
	 
	 mov AX,2
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,2
To_mExperience:	
	mov AL,vInt10[SI]
	mov mExperience[SI],AL
	INC SI
loop To_mExperience
;-\\- Заробітна плата
	lea DX, sLN
	call write
	lea DX, sMoney
	 call write
	 
	 mov AX,6
	 call ReadInt10
; копіювання в нашу строку	 
	xor SI, SI
	mov CX,6
To_mMoney:	
	mov AL,vInt10[SI]
	mov mMoney[SI],AL
	INC SI
loop To_mMoney
; безпосередньо запис у файл
	
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
;вводимо дані 
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
; видаляємо останні два введені символи(13,10)
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

; якщо не знайдено
msNotFound:
mov ax, 0
ret
; якщо знайдено
msFound:
pop cx
mov ax, 1
ret
SrchEmProc ENDP


ReadString20 PROC ;(out vString20)
; Процедура для читання 20 символів
	xor SI, SI
	mov CX,20
zanulStr20:	
	mov vString20[SI],' '
	INC SI
loop zanulStr20
	xor SI, SI
readChar:
	call ReadKeyProc	; Читаємо символ
	 
	cmp AL, 8
	je BackSlash
	cmp AL, 13				; Чи не натиснуто ЕНТЕР
	je returnStr20
	cmp AL, 32				; Якщо заборонений то читаємо другий
	jl readChar
	cmp AL, 122
	jg readChar
	 
	cmp SI, 20				; Якщо 20 символ	
	jge readChar			; то продовжуємо читати до натиснення ЕНТЕРа
	
	mov DL, AL
	mov AH,2h
	INT 21h
	

	mov vString20[SI], AL	; Зберігаємо в змінну
	INC SI	
	jmp readChar
returnStr20:
	mov AX, SI
ret
BackSlash:; <- потрібно зменшити індекс, видалити символ
	cmp SI,0
	je readChar
	
	mov vString20[SI],32
	dec SI	
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 3
	 int   10h
dec DL
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-код  символу 
mov  bh,0        ;   Відеосторінка 0 
mov  cx,1        ;   Лічильник  повторення 
	  mov  ah, 0Ah
	  int  10h

jmp readChar
ReadString20 ENDP 


ReadInt10 PROC ;(out vString20)
; Процедура для читання 10-цфрового числа
	xor SI, SI
	push AX 	; зберігаємо макс к-сть цифр
	mov CX, 10
zanulInt10:	
	mov vInt10[SI],' '
	INC SI
loop zanulInt10
	xor SI, SI
mReadInt:
	call ReadKeyProc	; Читаємо символ
	 
	cmp AL, 8
	je BackSlashI
	cmp AL, 13				; Чи не натиснуто ЕНТЕР
	je returnInt10
	cmp AL, 30h				; Якщо заборонений то читаємо другий
	jl mReadInt
	cmp AL, 39h
	jg mReadInt
	 
	pop BX
	push BX
	cmp SI, BX				; Якщо 20 символ		
	jge mReadInt			; то продовжуємо читати до натиснення ЕНТЕРа
	
	mov DL, AL
	mov AH,2h
	INT 21h
	
	mov vInt10[SI], AL	; Зберігаємо в змінну
	INC SI	
	jmp mReadInt
returnInt10:
	mov AX, SI
	pop SI
ret
BackSlashI:; <- потрібно зменшити індекс, видалити символ
	cmp SI,0
	je mReadInt
	
	mov vInt10[SI],32
	dec SI	
;Змінюємо положення каретки на один вліво
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 3	
	 int   10h
dec DL
	mov   bh, 0    ;Відеосторінка 0
	 mov   ah, 2
	 int   10h
	 
mov  al, ' '     ;   ASCII-код  символу 
mov  bh,0        ;   Відеосторінка 0 
mov  cx,1        ;   Лічильник  повторення 
	  mov  ah, 0Ah
	  int  10h

jmp mReadInt
ReadInt10 ENDP 


OpenFiles PROC 
; Процедура для відкривання файла
	lea SI, vFileName
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 1			; Відкрити існуючий файл
	 mov AX, 716Ch	 	 
	 INT 21h
	jc createFile		; якщо неможливо відкрити то створюємо
mov vFileHandle, AX
jmp createTMPfile
createFile: ; Створення новго файла
	lea SI, vFileName
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 10h			; Створення новго
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandle, AX
	
createTMPfile:
	lea DX, vFileNameTMP
	 mov AH,41h 
	 INT 21h

; Створення новго файла
	lea SI, vFileNameTMP
	mov BX, 2			; Читаємо/Запис
	mov CX, 0			; Звичайний файл
	mov DX, 10h			; Створення новго
	 mov AX, 716Ch	 	 
	 INT 21h
	mov vFileHandleTMP, AX
	
ret
OpenFiles ENDP


CloseFiles PROC 
; Процедура для закривання файла
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
 
 ; ЧИтаємо 10 символів
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mName
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо 4 символa
	mov CX, 4
	mov BX, vFileHandle
	lea DX, mCode
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо 10 символів
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mPosition
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; ЧИтаємо 10 символів
	mov CX, 10
	mov BX, vFileHandle
	lea DX, mUnit
	 mov AH, 3fh
	 INT 21h
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
 ; ЧИтаємо 2 символа
	mov CX, 2
	mov BX, vFileHandle
	lea DX, mExperience
	 mov AH, 3fh
	 INT 21h 	 
	; зсуваємо на 1 (\)
	mov AL, 1
	mov CX, 0	
	mov DX, 1
	 mov AH, 42h
	 INT 21h
	 
; Читаємо 6 символів
	mov CX, 6
	mov BX, vFileHandle
	lea DX, mMoney
	 mov AH, 3fh
	 INT 21h
	push AX
	; зсуваємо на 2 (13,10)
	mov AL, 1
	mov CX, 0	
	mov DX, 2	
	 mov AH, 42h
	 INT 21h		 
	 
	pop AX
ret
ReadEmloyee ENDP

WriteEmploy PROC 
; Процедура для збереження даних в файл
	mov AX, vStructSize
	mul vEmplIdent
	mov DX, AX
	
	mov AL, 0	; зсув щодо початку файла	
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
