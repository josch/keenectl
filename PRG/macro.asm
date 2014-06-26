;*******************************************************************************
;*
;*  (c) Copyright 2004, Holtek Semiconductor Inc.
;* 
;******************************************************************************/
;*******************************************************************************
;MODULE:	main.asm

;INITIAL:	11/12/2004

;AUTHOR:	C351  Ansonku.

;NOTE:	 	HT48RB4 16 bit operation

;REVISION:	First issue
;*******************************************************************************
;*******************************************************************************
;		16 bit ADD with signed
;		use 	ADD16	XH,XL,YH,YL,ZH,ZL
;		operation
;			XH XL
;		       +YH YL
;		   --------------
;			ZH ZL
;*******************************************************************************
ADD16	MACRO	XH,XL,YH,YL,ZH,ZL
	MOV	A,XL
	ADD	A,YL
	MOV	ZL,A
	MOV	A,XH
	ADC	A,YH
	MOV	ZH,A
ENDM
;*******************************************************************************
;		16 bit ADD with unsigned
;		use 	ADD16	XH,XL,YL,ZH,ZL
;		operation
;			XH XL
;		       +   YL
;		   --------------
;			ZH ZL
;*******************************************************************************
ADD16U	MACRO	XH,XL,YL,ZH,ZL
	mov	a,xh
	mov	zh,a
	MOV	A,XL
	ADD	A,YL
	SZ	C
	INC	ZH
	MOV	ZL,A
ENDM


;*******************************************************************************
;		16 bit sub with signed
;		use 	SUB16	XH,XL,YH,YL,ZH,ZL
;		operation
;			XH XL
;		       -YH YL
;		   --------------
;			ZH ZL
;*******************************************************************************
SUB16	MACRO	XH,XL,YH,YL,ZH,ZL
	MOV	A,XL
	CLR	C
	SUB	A,YL
	MOV	ZL,A
	MOV	A,XH
	SBC	A,YH
	MOV	ZH,A

ENDM


;*******************************************************************************
;		16 bit shift right with signed
;		use 	RR16	XH,XL,ZH,ZL
;		operation
;*******************************************************************************
RR16	MACRO	XH,XL,ZH,ZL
	CLR	C
	MOV	A,XH
	AND	A,80H
	SNZ	Z
	SET	C
	RRCA	XH
	MOV	ZH,A
	RRCA	XL
	MOV	ZL,A
ENDM
;*******************************************************************************
;		16 bit shift left with signed
;		use 	RL16	XH,XL,ZH,ZL
;		operation
;*******************************************************************************
RL16	MACRO	XH,XL,ZH,ZL
	CLR	C
	SZ	XL.7
	SET	C

	RLCA	XH
	MOV	ZH,A
	CLR	C
	RLCA	XL
	MOV	ZL,A
ENDM
;*******************************************************************************
;		16 bit shift left with signed
;		use 	RL16N	XH,XL,ZH,ZL
;		operation
;*******************************************************************************
RL16N	MACRO	XH,XL,ZH,ZL,N
	;MOV	A,8
	;SUB	A,N
	;mov	a,Xl SHR A
	;mov	zh,a
	;mov	a,xh SHL N
	;orm	a,zh
ENDM
;*******************************************************************************
;		8 bit multiply with signed
;		use 	mul8	X,Y,ZH,ZL
;		operation
;*******************************************************************************
Mul8	MACRO	X,Y,ZH,ZL
	Local   Mul8_End
	CLR	operator1H	;sum
	CLR	operator1L
	CLR	operator2H	;multiply
	CLR	operator3H	;operator
	CLR	operator3L
	mov	A,Y
	mov	operator2L,A
	
	SZ	X.7
	SET	operator2H
Mul16_doloop:	
	MOV	A,6
	MOV	Counter3,A
	SDZ	Counter3
	JMP	Mul8_End
	SNZ	X.Counter3
	jmp	Mul18_Next_Bit
	RL16	operator2H,operator2L,operator3H,operator3L
	ADD16	operator3H,operator3L,operator1H,operaotr1L,operator1H,operator1L
	

Mul18_Next_Bit:
	JMP	Mul16_doloop
	

Mul8_End:


ENDM

;*******************************************************************************
;			8 bit macro
;*******************************************************************************
;*******************************************************************************
;		16 bit ADD with signed
;		use 	ADD16	X,Y,Z
;		operation
;			X
;		       +Y
;		   --------------
;			Z
;*******************************************************************************
ADD8	MACRO	X1,Y1,Z1
	MOV	A,X1
	ADD	A,Y1
	MOV	Z1,A
ENDM

;*******************************************************************************
;		16 bit sub with signed
;		use 	SUB16	X,Y,Z
;		operation
;			X
;		       -Y
;		   --------------
;			Z
;*******************************************************************************
SUB8	MACRO	X1,Y1,Z1
	MOV	A,X1
	SUB	A,Y1
	MOV	Z1,A
ENDM

;*******************************************************************************
;		8 bit shift right with signed
;		use 	RR8	X,Z
;		operation
;*******************************************************************************
RR8	MACRO	X,Y
	Local   RR8_End,RR8_Modify_FF,RR8_Modify_FF_End
	mov	a,X
	inc	acc
	SZ	Z
	jmp	RR8_Modify_FF
	jmp	RR8_Modify_FF_End	
RR8_Modify_FF:
	clr	Y
	jmp	RR8_End

RR8_Modify_FF_End:
	CLR	C
	MOV	A,X
	AND	A,80H
	SNZ	Z
	SET	C
	RRCA	X
	MOV	Y,A



RR8_End:
ENDM
;*******************************************************************************
;		8 bit shift left with signed
;		use 	RL16	X,Z
;		operation
;*******************************************************************************
RL8	MACRO	X,Y
	CLR	C
	RLCA	X
	MOV	Y,A
ENDM

;*******************************************************************************
;		8 bit abs
;		use 	ABS8	X,Y
;		operation
;*******************************************************************************
ABS8	MACRO	X,Y
	Local   ABS8_End

	kmov	y,x
	mov	a,x
	and	a,80H
	SZ	Z
	jmp	ABS8_End
	CPL	y
	INC	y

ABS8_End:

ENDM






;*******************************************************************************
;		kmov
;		use 	kmov	destination,source
;		operation
;*******************************************************************************
KMOV      MACRO   mem1,mem2
                mov     a,mem2
                mov     mem1,a
          ENDM

KOR       MACRO   mem1,mem2
                mov     a,mem2
                orm    a,mem1
          ENDM



;*******************************************************************************
;		make oled column address
;		use 	oled_make_col_add	source,MSB,LSB
;		
;*******************************************************************************
oled_make_col_add	macro	mem1,mem2,mem3
	mov	a,0FH
	AND	a,mem1
	mov	mem3,a
	mov	a,70H
	and	a,mem1
	mov	mem2,a
	clr	c
	rrc	mem2
	clr	c	
	rrc	mem2
	clr	c
	rrc	mem2
	clr	c
	rrc	mem2
	set	mem2.4

endm



;***************************************

XMOV        MACRO   mem2,mem1
                mov     a,mem1
                mov     mem2,a
            ENDM
;-------------------------------------
;;Move ARG2->ARG1(move by bit)
xmov1		MACRO	ARG1,ARG2
		LOCAL	xmov1_1,xmov1_end
		sz	ARG2
		jmp	xmov1_1
		clr	ARG1
		jmp	xmov1_end
xmov1_1:
		set	ARG1
xmov1_end:
		ENDM
;-------------------------------------
;;if MEM2=MEM1 =>Skip Next Instruction
EQUJMP      MACRO   MEM2,MEM1
                MOV     A,MEM1
                XOR     A,MEM2
                SNZ     Z
            ENDM
;;------------------------
            
;;if MEM2!=MEM1 =>Skip Next Instruction            
NEJMP       MACRO   MEM2,MEM1
                MOV     A,MEM1
                XOR     A,MEM2
                SZ      Z
            ENDM
;;------------------------
;;if (REG1==REG2) goto REG3
JLER		MACRO 	REG1,REG2,REG3
                mov	a,REG1
		sub	a,REG2
                sz	z
		jmp	REG3
            	ENDM
;**********************************************
;MACRO: JLNR
;PURPOSE: REG1 != REG2 goto REG3
;**********************************************
JLNR		MACRO 	REG1,REG2,REG3
                mov	a,REG1
		sub	a,REG2
                snz	z
		jmp	REG3
            	ENDM
;;------------------------
;;if MEM2>MEM1 =>Skip Next Instruction                      
LBRJ        MACRO   MEM2,MEM1
                MOV     A,MEM1
                SUB     A,MEM2
                SZ      C
            ENDM
;;------------------------

;;if MEM2<=MEM1 =>Skip Next Instruction                      
LSERJ       MACRO   MEM2,MEM1
                MOV     A,MEM1
                SUB     A,MEM2
                SNZ     C
            ENDM
;;------------------------

;;if MEM2<MEM1 =>Skip Next Instruction          
LSRJ        MACRO   MEM2,MEM1
                MOV     A,MEM2
                SUB     A,MEM1
                SZ      C
            ENDM
;;------------------------
            
;;if MEM2>=MEM1 =>Skip Next Instruction          
LBERJ        MACRO   MEM2,MEM1
                MOV     A,MEM2
                SUB     A,MEM1
                SNZ     C
            ENDM
;;------------------------

SWAPWORD     MACRO      DA
             EQU        (DA>>8)+(DA<<8)
             ENDM
;;------------------------
		