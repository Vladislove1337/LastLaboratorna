.data
;Змінні для позначення початку/кінця програми
	sProgramTitle db 22 dup(32),'       Accounting employess ',13,10 ;Облік працівників підприємства
	db 80 dup('_'),'$'
	WIbuff db 80 dup(?)
;Змінні для меню	                          
	sMenu 	 db 20 dup(32),'-1-  Total nubmer of employees           		 ',13,10  ; Статистика
			 db 20 dup(32),'-2-  Add new empoye    			 ',13,10  ; Добавити
			 db 20 dup(32),'-3-  Print employess       		 ',13,10  ; Переглянути каталог
			 db 20 dup(32),'-4-  Previous empoye		 ',13,10  ; Попередній 		 
			 db 20 dup(32),'-5-  Next empoye   			 ',13,10  ; Наступний	
			 db 20 dup(32),'-6-  Search empoye   			 ',13,10  ; пошук
			 db 20 dup(32),'-7-  Remove empoye   			 ',13,10  ; Видалити
 			 db 20 dup(32),'-0-  Exit                          			 ',13,10  ; Вихід
.code


ShowMainMenu PROC 
;Вивід на екран ПУНКТІВ меню
	lea DX, sMenu
	 call write
ret 
ShowMainMenu ENDP

ClrPartScr PROC 
push AX 
push BX 
push CX
	mov  al,0    
	mov  ch,15
	mov  cl,0     
	mov  dh,24   
	mov  dl,79   
	mov bh,0F0h
	 mov AH, 07h ; прокручує вниз
	 INT 10h
	 
	mov al,15
	call CursorToLine	; переміщає курсор
pop CX 
pop BX 
pop AX
ret
ClrPartScr ENDP	 

CursorToLine PROC 
push DX
	mov dL, 0		; стовпець 0
	mov dH, al		; В дЛ записуємо номер рядка
	mov bH, 0  		; сторінка
	 mov aH, 02h	; ЗМІНА ПОЛОЖЕННЯ КУРСОРА
	 INT 10h 
pop DX
ret
CursorToLine ENDP
 
ReadKeyProc PROC 
	 mov AH, 00h	; Читання введеного користувачем символу
	 INT 16h
ret 
ReadKeyProc ENDP 

 write PROC 
; Процедура виведення рядка символів
   push AX
	mov AH, 09h
	INT 21h
   pop AX
ret
write ENDP

 writeln PROC 
   push AX
   push DX
	mov AH, 09h
	 INT 21h
	lea DX, sLN
	 INT 21h	
   pop DX
   pop AX
ret
writeln ENDP

WriteInt PROC ;(AX)
	mov si,0
	mov cx,25
zanul:
	mov WIbuff[si],0
	add si,1
	loop zanul
	mov si,0
	mov cx,10
dill:
	cmp ax,10
	jl last
	xor dx,dx
	div cx 		; Ділимо DX:AX на CX (10),
	xchg ax,dx 	; Міняємо їх містами
	add al,'0' 	; Получимо в AL символ десяткової цифри
	mov WIbuff[si],al
	add si,1
	xchg ax,dx
	cmp ax,10
	jge dill
last:
	add al,'0'
	mov WIbuff[si],al
	add si,1

	mov si,24
	mov cx,25
vuv:
	cmp WIbuff[si],0
	jne cifr

	sub si,1
	loop vuv
cifr:
	mov dl,WIbuff[si]
	mov ah,02h
	int 21h
	sub si,1
	loop vuv
ret
WriteInt ENDP

ReadInt PROC 
		
	xor AX, AX
	xor BX, BX
	xor CX, CX
	xor DX, DX
	
	call ReadString20
	
	StrToIntLoop:
			mov cx,ax ; в CX кількість цифр
			mov si,0 ; лічильник
			xor AX,AX ; в AX будем записувати число

	cycle: ;цикл переводу
		mov bL, vString20(si)
		sub bL,30h
		add AX,BX
		add si,1
		cmp cx,1
		jne mnoj ;якщо CX<>1 (не остання цифра)

			
	ret ; повернення з функції в програму
	 mnoj:
			mov BL,10
			mul BL; Ax*10
	loop cycle
ReadInt ENDP

