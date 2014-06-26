;*******************************************************************************
;*
;*  (c) Copyright 2005, Holtek Semiconductor Inc.
;* 
;******************************************************************************/
;*******************************************************************************
;MODULE:	main.asm

;INITIAL:	09/14/2006

;AUTHOR:	C351  Ansonku.

;NOTE:	 	HT82A821R , HT82A822R Main Function

;VERSION:	1.2
;Function:
;key debounced	N
;oled		N
;volume adjust	Y
;2005/05/13     Update Key Debounce
;2005/05/25	Modify Pop noise
;2005/06/06     Modify Send_Hand_Shake
;2005/06/10	判斷 token 時,假設遇到setup scmd,要在讀取8 bytes清除scmd與len0
;2005/12/20	USB 流程全改用 jmp 方式 implement
;2005/12/20	將 suspend 判斷修改至 main function 中
;*******************************************************************************

;***************************************************************
;Include File
;ht82a822.inc		ht82a822r register address defined
;const.inc		user defined
;macro.asm		macro function
;***************************************************************
#include		ht82a821r.inc
#include		const.inc
#include		macro.asm

#define			WaitBias	0

;====================================================================
;Variable Defined , DATA 從 40H 開始放
;====================================================================
DATA		.SECTION		AT	40H		'DATA'
#include		memory.inc
;***************************************************************
;		USB ISR Var (中斷時備份用)
;***************************************************************
isr_usb_acc		DB		?
isr_usb_status		DB		?
isr_usb_mp1		DB		?
isr_usb_mp0		DB		?
isr_usb_tblp		DB		?
;***************************************************************
;		Timer0 ISR Var (中斷時備份用)
;***************************************************************
;;isr_tmr0_acc		DB		?
;;isr_tmr0_status		DB		?
;;isr_tmr0_mp1		DB		?
;;isr_tmr0_mp0		DB		?
;;isr_tmr0_tblp		DB		?
;***************************************************************
;		Timer1 ISR Var (中斷時備份用)
;***************************************************************
;;isr_tmr1_acc		DB		?
;;isr_tmr1_status		DB		?
;;isr_tmr1_mp1		DB		?
;;isr_tmr1_mp0		DB		?
;;isr_tmr1_tblp		DB		?

;***************************************************************
;		Delay 變數
;***************************************************************
Delay_1			DB		?
Delay_2			DB		?
Delay_3			DB		?

;***************************************************************
;USB FIFO Variable
;USB_Interface : to save usb current interface number
;USB_Interface_Alt : to save usb current alternate of interface number
;USB_Configuration : to save USB configuration number
;FIFO_ADDR     : to save USB ADDRESS
;Loop_Counter , Data_Count , Data_Start : control_read variable
;***************************************************************
;For FIFO Access
FIFO_SIZE			db		?
FIFO_SendLen			db		?
FIFO_out1			label	byte
FIFO_Type			db		?
FIFO_out2			label	byte
FIFO_Request			db		?
FIFO_out3			label	byte
FIFO_wValueL			db		?
FIFO_out4			label	byte
FIFO_wValueH			db		?
FIFO_out5			label	byte
FIFO_wIndexL			db		?
FIFO_out6			label	byte
FIFO_wIndexH			db		?
FIFO_out7			label	byte
FIFO_wLengthL			db		?
FIFO_out8			label	byte
FIFO_wLengthH			db		?

FIFO_TEMP			db		?
;**************************************************************
;USB 狀態暫存
;
;
;**************************************************************
USB_Interface			db		?
USB_Interface_Alt		db		?
USB_Configuration		db		?
;//save usb address
FIFO_ADDR			db		?

Loop_Counter			db		?
Data_Count			db		?
Data_Start			db		?

;voice control
INC_Counter			db		?
DEC_Counter			db		?


;FIFO
bFlag_SetConfiguration_Ready	dbit		
bFlag_SetInterface_Ready	dbit		
bFlag_Real_Cmd			dbit		
bFlag_FIFO_Ready		dbit
bFlag_FIFO_LEN0			dbit
bFlag_RD_HTable			dbit
bFlag_wait_control_out		dbit
bFlag_SET_ADDRESS		dbit
bFlag_SCMD			dbit
bFlag_Enum_Ready		dbit
;Audio
PortC_data			db	?
bFlag_Audio_Mute		dbit
Volume1				db	?
Volume2				db	?

;Mute_Save			db	?
VolumeH_Save			db	?
VolumeL_Save			db	?

nCmdIndex1			db	?


;**************************************************************
;Key 狀態暫存
;
;
;**************************************************************

;;Key_Process			db	?
;;Key_CheckIn			db	?
;;Key_Counter			db	?
;;Key_Temp			db	?
;;Key_IncCounter			db	?
;;Key_DecCounter			db	?

;modify for Remote Wakeup
bRmtWakeup      		dbit
b_wakeup        		dbit
;modify 2007-06-27
b_forceresumeWakeup		dbit
;modify 2007-07-03
b_forusbRst                     dbit
bFlagTMR1				dbit

;;***********************************************

extern			control_read_table:NEAR        
extern			device_desc_table:NEAR         
extern			config_desc_table:NEAR         

extern			end_config_desc_table:NEAR  
extern			hid_report_desc_table:NEAR
extern			end_hid_report_desc_table:NEAR

extern			USBStringLanguageDescription:NEAR
extern			USBStringDescription1:NEAR
extern			USBStringDescription2:NEAR

extern			config_desc_length:NEAR
extern			report_desc_length:NEAR
;function
extern			Control_Read:NEAR
extern			FIFO0_RD_CHECK:NEAR
extern			FIFO1_RD_CHECK:NEAR
extern			FIFO2_RD_CHECK:NEAR
extern			FIFO3_RD_CHECK:NEAR
extern			FIFO4_RD_CHECK:NEAR
extern			FIFO5_RD_CHECK:NEAR
extern			FIFO0_WR_CHECK:NEAR
extern			FIFO1_WR_CHECK:NEAR
extern			FIFO2_WR_CHECK:NEAR
extern			FIFO3_WR_CHECK:NEAR
extern			FIFO4_WR_CHECK:NEAR
extern			FIFO5_WR_CHECK:NEAR
extern			Read_FIFO0:NEAR
extern			Read_FIFO1:NEAR
extern			Read_FIFO2:NEAR
extern			Read_FIFO3:NEAR
extern			Read_FIFO4:NEAR
extern			Read_FIFO5:NEAR
extern			Write_FIFO0:NEAR
extern			Write_FIFO1:NEAR
extern			Write_FIFO2:NEAR
extern			Write_FIFO3:NEAR
extern			Write_FIFO4:NEAR
extern			Write_FIFO5:NEAR
extern			Send_Hand_Shake:NEAR
extern			get_descriptor_length:NEAR

extern			SetAddress:NEAR
extern			SetConfiguration:NEAR
extern			SetInterface:NEAR
extern			GetInterface:NEAR
extern			GetDescriptor:NEAR
extern			SetIdle:NEAR
extern			GetDeviceDescriptor:NEAR
extern			GetConfigurationDescriptor:NEAR
extern			GetStringDescriptor:NEAR
extern			GetStatus:NEAR
;modify for Remote Wakeup
extern			GetStatus_Interface:NEAR
;----------------------------------------------
extern			SetFeature:NEAR
extern			ClearFeature:NEAR
extern			SetReport:NEAR
extern			Execute:NEAR
extern			SendStall0:NEAR
extern			Delay_3us:NEAR

extern			SetFeature_Endpoint:NEAR
extern			ClearFeature_Endpoint:NEAR
extern			GetStatus_Endpoint:NEAR

extern			Check_Real_Cmd:NEAR
extern			GetConfiguration:NEAR


;audio
extern		SetCur:NEAR
extern		GetMin:NEAR
extern		GetMax:NEAR
extern		GetRes:NEAR
extern		GetCur:NEAR

extern		GetPipeBit:NEAR
;***************************************************************
;		MCU Interrupt Table
;***************************************************************


CODE            .section        AT 00H 'code'
		ORG		00H
		jmp		Start
		ORG		04H
		jmp		USB_ISR
		ORG		08H
		jmp		Timer_0_ISR
		ORG		0CH
		jmp		Timer_1_ISR


	;-----------------------------------------------------------
	; Start : ORG 20H 避開前面 interrupt
	;-----------------------------------------------------------
ORG	20H
Start:

		call	System_Initial

	;-----------------------------------------------------------
	; Main LOOP Function  : 
	;-----------------------------------------------------------
Main:
	;-----------------------------------------------------------
	; Check Suspend Function  :
	; 第一次檢查到 suspend 應要再 delay 1 S 後再檢查一次 , 如果此時 suspend 訊號還在才進入 halt
	; 請檢查 timer 此時是否有開啟 , 若有應暫時關閉 , 待 resume 後再開啟 
	;-----------------------------------------------------------
		SNZ		USC.@USC_SUSP		;check SUSPEND ?
		JMP		Main_My_Function

		call		wait_about_1s
		SNZ		USC.@USC_SUSP
		JMP		Main_My_Function
	
ToSuspend_again:		
		clr wdt
;;		clr		TMR1C.4
		clr		USB_LED_ON
		clr		UCC.@UCC_USBCKEN
		clr	b_forceresumeWakeup
		;clr b_forusbRst
	;-----------------------------------------------------------
	; Resume  Function  : 
	; 在此 function 要把 halt 之前的 timer 狀態恢復 , 並且開啟 USBCKEN
	;-----------------------------------------------------------
		HALT
;;		set		TMR1C.4		
		set		USB_LED_ON
		set		UCC.@UCC_USBCKEN

		;modify 2007-06-28
		set     	AWR.@AWR_WKEN

		;sZ   b_forusbRst
       	;JMP  Start
        
		sz		b_forceresumeWakeup        
		jmp		RemoteWakeup

	 	snz     b_wakeup
    	jmp    RemoteWakeup_loop
	   	;clr    b_wakeup
   		snz     	bRmtWakeup                      ; 檢查USB device是否Enable RemoteWakeup能力
   		jmp     	ToSuspend_again                 ; 若bRmtWakeup=0,則再度回到suspend
		clr		bRmtWakeup
   		
;modify for Remote Wakeup
RemoteWakeup_loop:
      	clr    b_wakeup


       	;sz		b_forceresumeWakeup        
		;jmp		RemoteWakeup
	
		;sz     	USC.@USC_SUSP                   	;
        ;jmp     ToSuspend_again                 ; 
		;JMP		Main

RemoteWakeup:
		;modify 2007-06-27
		clr		b_forceresumeWakeup
        SET   		USC.@USC_RMWK    ; USC.RMWK=1
        nop
        nop
        nop
        nop
        nop
        nop
        CLR   		USC.@USC_RMWK     ; USC.RMWK=0
		;clr			AWR.@AWR_WKEN
        ;sZ   b_forusbRst
        ;JMP  Start

		SZ		USC.@USC_SUSP		;check SUSPEND ?
		JMP		Main

;-----------------------------------------------------
Main_My_Function:
	CLR	WDT
	SNZ	bFlag_SetConfiguration_Ready
	JMP	main					;;USB Not OK

;----------------------------------------------------	
	SZ	bIniFMOK
	JMP	L_MyFunction				;;IniFM OK
	
	MOV	A,cFreqDefL
	MOV	mFreqL,A
	MOV	A,cFreqDefH
	MOV	mFreqH,A
	CALL	QN8072Init				;;Init QN8072
	SET	bIniFMOK

	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
L_MyFunction:
		clr wdt	
		NOP		
		snz bFlagTMR1
;;		jmp Main_End
;;		IF	UseMediaKey
;;		call		Key_Debounced
;;		ENDIF
		call		Run_Volume_Step		

		clr bFlagTMR1

Main_End:

		JMP		Main

;***************************************************************
;		System Initial
;		1.ram_initial
;		1.Timer Initial
;		2.USB Config
;***************************************************************
System_Initial:
	;-----------------------------------------------------------
	; Debug
	;-----------------------------------------------------------


	;-----------------------------------------------------------
	; Modify Pop Noise
	; 送中間準位 code 至 DA
	;-----------------------------------------------------------
		clr wdt
		mov		a,WDTS
		mov		FIFO_TEMP,a

		mov		a,01010111b
		mov		WDTS,a

		clr		[02DH]

		
		mov		a,80H
		mov		[02EH],a
		nop
		nop
		set		[02FH].3
		nop
		nop
		clr		[02FH].3
		nop
		nop

		mov		a,FIFO_TEMP
		mov		WDTS,a
	;-----------------------------------------------------------
	; 此步驟為等待電容的上升時間
	; 測試時應該把 WaitBias 設為 0 , 非測試應該把 WaitBais 設為 1
	; Wait Bais and ROUT LOUT Capacity rise about 1.98ms
	; delay time = 255*255*30*3(sdz,jmp) cycle * 0.3333us/cycle = 1.98 ms
	;-----------------------------------------------------------
	IF	WaitBias
		clr		pac

		clr		FIFO_OUT1
		clr		FIFO_OUT2
		clr		FIFO_OUT3
		mov		a,9		
		mov		FIFO_OUT3,a
		clr		pa



	System_Initial_Loop:
		clr wdt
		sdz		FIFO_OUT1
		jmp		System_Initial_Loop
		sdz		FIFO_OUT2
		jmp		System_Initial_Loop		
		sdz		FIFO_OUT3
		jmp		System_Initial_Loop		
		nop
		set		pa
		clr wdt
	ENDIF
	;-----------------------------------------------------------
	; Codec Limit
	;-----------------------------------------------------------
		clr		[02DH]
		set		[02EH]

	;-----------------------------------------------------------
	; ram_initial : clear the ram of bank 0
	;-----------------------------------------------------------
	ram_initial:	;clear RAM (040H--0FFH)
		MOV		A,040H
		MOV		MP0,A
		MOV		A,192
	ram_initial_next_addr:
		clr wdt	
		CLR		R0
		INC		MP0
		SDZ		acc
		JMP		ram_initial_next_addr
		
		CLR		bFlag_RD_HTable
	;-----------------------------------------------------------
	; timer_initial : do timer initial
	;-----------------------------------------------------------
	timer_initial:
;;		MOV 		A,80H		; 設定 low 到 high 觸發並設為內部計時模式
;;		MOV		TMR0C,A		;
;;		MOV		A,00H		;
;;		MOV		TMR0L,A		
;;		MOV		A,000H		
;;		MOV		TMR0H,A		

		mov		a,80H
		mov		TMR1C,a
		mov		a,00H
		mov		TMR1L,a
		mov		TMR1H,a

	;-----------------------------------------------------------
	; config_io_port :
	;-----------------------------------------------------------
;;		clr		PA
	;-----------------------------------------------------------
	; config_io_port :(USB Audio)
	;-----------------------------------------------------------
		SET		P_LED
		CLR		P_LEDC
		SET		P_SDA
		CLR		P_SDAC
		SET		P_SCL
		CLR		P_SCLC
	
	;;Initial QN8072 Reg0~4	
		MOV		A,51H
		MOV		mQNReg[0],A
		MOV		A,18H
		MOV		mQNReg[1],A
		MOV		A,0B9H
		MOV		mQNReg[2],A
		MOV		A,50H
		MOV		mQNReg[3],A
		MOV		A,58H
		MOV		mQNReg[4],A
		
		
;;		IF 		UseMediaKey
;;			kmov		pac,Key_Defined
;;		ENDIF
;;		IFE		UseMediaKey
;;			kmov		pac,00000000b
;;		ENDIF
		
;;		clr		pb
;;		clr		pbc		;change to USB Len On
;;;		clr		pc		;for volume control
;;		set		pcc
;;		clr		pd
;;		clr		pdc
	;-----------------------------------------------------------
	; config_usb_speaker_register :
	;-----------------------------------------------------------
		clr		USVC		;mute & 0db
		clr		USF
	;-----------------------------------------------------------
	; reset variable :
	;-----------------------------------------------------------
		clr		bFlag_Audio_Mute
		clr		VolumeH_Save
		mov		a,Cur_Volume
		mov		VolumeL_Save,a
	;-----------------------------------------------------------
	; config_usb : do usb config
	;-----------------------------------------------------------
	config_usb:
		CLR		INTC0
		SET		INTC0.@INTC0_EEI		;enable USB
		SET		INTC0.@INTC0_EMI		;Global interrupt

		set		MISC.@MISC_ISOEN
		clr		STALL
		clr		UCC.@UCC_SUSP2
		
		;SYSCLK
		;set			UCC.6	//set to 6 MHz

		set 		UCC.@UCC_USBCKEN
		nop
		set		USC.@USC_V33C		;//pc 開始送 command 過來
		clr wdt
			;modify for Remote Wakeup
		clr     bRmtWakeup
    		clr     b_wakeup
		clr     b_forusbRst
		;clr     	AWR.@AWR_WKEN
		RET
		
;***************************************************************
;		Timer_0_ISR
;		1.Timer time = 21.2 ms
;		2.Do this procedure is 3.6ms
;***************************************************************
Timer_0_ISR:	
;;		clr		TMR0C.4
;;		MOV		isr_tmr0_acc,A		;save ACC
;;		MOV		A,STATUS
;;		MOV		isr_tmr0_status,A	;save status
;;		MOV		A,MP1
;;		MOV		isr_tmr0_mp1,A		;save mp1
;;		MOV		A,MP0
;;		MOV		isr_tmr0_mp0,A		;save mp0
;;		MOV		A,TBLP
;;		MOV		isr_tmr0_tblp,A		;save TBLP

Timer_0_My_Function:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
;;		NOP
;;		clr wdt
				
Timer_0_ISR_END:		
;;		MOV		A,isr_tmr0_tblp		;restore TBLP
;;		MOV		TBLP,A
;;		MOV		A,isr_tmr0_mp0		;restore MP0
;;		MOV		MP0,A
;;		MOV		A,isr_tmr0_mp1		;restore MP1
;;		MOV		MP1,A
;;		MOV		A,isr_tmr0_status	;restore STATUS
;;		MOV		STATUS,A
;;		MOV		A,isr_tmr0_acc		;restore ACC
;;		SET		TMR0C.4			;start timer0

		RETI

;***************************************************************
;		Timer_1_ISR
;		1.Timer time = 21.2 ms
;		2.Do this procedure is 3.6ms
;***************************************************************
Timer_1_ISR:
		CLR		TMR1C.4


;;		MOV		isr_tmr1_acc,A		;save ACC
;;		MOV		A,STATUS
;;		MOV		isr_tmr1_status,A	;save status
;;		MOV		A,MP1
;;		MOV		isr_tmr1_mp1,A		;save mp1
;;		MOV		A,MP0
;;		MOV		isr_tmr1_mp0,A		;save mp0
;;		MOV		A,TBLP
;;		MOV		isr_tmr1_tblp,A		;save TBLP
;;		clr wdt
		;IF	UseMediaKey
		;call		Key_Debounced
		;ENDIF
		;call		Run_Volume_Step
		set bFlagTMR1

;;		MOV		A,isr_tmr1_tblp		;restore TBLP
;;		MOV		TBLP,A
;;		MOV		A,isr_tmr1_mp0		;restore MP0
;;		MOV		MP0,A
;;		MOV		A,isr_tmr1_mp1		;restore MP1
;;		MOV		MP1,A
;;		MOV		A,isr_tmr1_status	;restore STATUS
;;		MOV		STATUS,A
;;		MOV		A,isr_tmr1_acc		;restore ACC

Timer_1_ISR_End:
		SET		TMR1C.4
		RETI

;***************************************************************
;		USB_ISR : USB Interrupt Routine
;		1.Back up every status register
;		2.check which endpoint is interrupt
;***************************************************************
USB_ISR:
		;CLR		INTC0.@INTC0_EEI	;disable USB interrupt
		;SET		INTC0.@INTC0_EMI

		MOV		isr_usb_acc,A		;save ACC
		MOV		A,STATUS
		MOV		isr_usb_status,A	;save status
		MOV		A,MP1
		MOV		isr_usb_mp1,A		;save mp1
		MOV		A,MP0
		MOV		isr_usb_mp0,A		;save mp0
		MOV		A,TBLP
		MOV		isr_usb_tblp,A		;save TBLP
		
		;modify 2007-07-03
      	SZ  	USC.@USC_URST
      	SET  	b_forusbRst        
      	CLR  	USC.@USC_URST
		
		;modify 2007-06-27
		SZ   		USC.@USC_RESUME
      		set  		b_forceresumeWakeup;;JMP  RemoteWakeup
		
		clr wdt
		;;Check Which FIFO is interrupt
		JMP		Check_Access_FIFO		



USB_ISR_END:
		MOV		A,isr_usb_tblp		;restore TBLP
		MOV		TBLP,A
		MOV		A,isr_usb_mp0		;restore MP0
		MOV		MP0,A
		MOV		A,isr_usb_mp1		;restore MP1
		MOV		MP1,A
		MOV		A,isr_usb_status	;restore STATUS
		MOV		STATUS,A
		MOV		A,isr_usb_acc		;restore ACC


		;CLR		INTC0.@INTC0_EMI
		;SET		INTC0.@INTC0_EEI


		RETI

;***************************************************************
;		USB_EPX_ISR
;		之前使用 USR@EP0IF EQU	[01BH].0 判別會偵測不到
;		更改成   USB_STATUS_CONTROL.@EP0IF
;***************************************************************
Check_Access_FIFO:
		clr wdt
		SZ		USR.@USR_EP0F
		JMP		USB_EP0_ISR
		SZ		USR.@USR_EP1F
		JMP		USB_EP1_ISR
		SZ		USR.@USR_EP2F
		JMP		USB_EP2_ISR
		JMP		USB_ISR_END

;-----------------------------------------------------
;EPNPOINT 0
;-----------------------------------------------------
USB_EP0_ISR:
		;CLR		USR.@USR_EP0F

;;case1
		SZ		MISC.@MISC_SCMD			;check setup token      
		JMP		USB_EP0_SETUP_TOKEN                                     
                
		SZ		MISC.@MISC_LEN0			;check out ack token    
		JMP		USB_EP0_OUT_ACK_TOKEN                                   

		CALL		FIFO0_RD_CHECK                                          
		SZ		bFlag_FIFO_Ready                                        
		JMP		USB_EP0_OUT_TOKEN 
		;clr		MISC.@MISC_REQ

		CALL		FIFO0_WR_CHECK                                          
		SZ		bFlag_FIFO_Ready                                        
		JMP		USB_EP0_IN_TOKEN		;else is in token       
		;clr		MISC.@MISC_REQ

		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
				
  		JMP		USB_EP0_ISR_END   


;;case2
;;		SZ		MISC.@MISC_SCMD			;check setup token      
;;		JMP		USB_EP0_SETUP_TOKEN                                     
;;                
;;		SZ		MISC.@MISC_LEN0			;check out ack token    
;;		JMP		USB_EP0_OUT_ACK_TOKEN                                   
;;
;;		CALL		FIFO0_RD_CHECK                                          
;;		SZ		bFlag_FIFO_Ready                                        
;;		JMP		USB_EP0_OUT_TOKEN 
;;		;clr		MISC.@MISC_REQ
;;
;;		CALL		FIFO0_WR_CHECK                                          
;;		SZ		bFlag_FIFO_Ready                                        
;;		JMP		USB_EP0_IN_TOKEN		;else is in token       
;;		;clr		MISC.@MISC_REQ
;;
;;
;;  		JMP		USB_EP0_ISR_END   


;;case3
;;		call		FIFO0_RD_CHECK
;;		sz		bFlag_FIFO_Ready
;;		jmp		Have_Data_Out
;;		
;;		call		FIFO0_WR_CHECK
;;		sz		bFlag_FIFO_Ready
;;		jmp		USB_EP0_IN_TOKEN
;;		
;;		jmp		USB_EP0_ISR_END
;;
;;Have_Data_Out:
;;		sz		MISC.@MISC_SCMD
;;		jmp		USB_EP0_SETUP_TOKEN
;;		sz		MISC.@MISC_LEN0
;;		jmp		USB_EP0_OUT_ACK_TOKEN
;;		
;;		jmp		USB_EP0_OUT_TOKEN





USB_EP0_SETUP_TOKEN:					;PARSE SETUP TOKEN
		clr wdt
		JMP		StageOne

USB_EP0_IN_TOKEN:
		clr wdt
		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
		CALL		control_read
		JMP		USB_EP0_ISR_END

USB_EP0_OUT_ACK_TOKEN:
		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
		clr wdt
		clr		MISC.@MISC_LEN0
		JMP		USB_EP0_ISR_END
		
;--------------------------------------------------------------
; Parser nCmdIndex1
;--------------------------------------------------------------
USB_EP0_OUT_TOKEN:
		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
		clr wdt
		clr		acc
		xor		a,nCmdIndex1
		sz		z
		jmp		USB_EP0_ISR_END
		
USB_EP0_OUT_TOKEN_Loop:
		clr wdt
		CALL		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		USB_EP0_OUT_TOKEN_End

		clr wdt
		CALL		FIFO0_RD_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		USB_EP0_OUT_TOKEN_Loop
		
		CALL		READ_FIFO0
		NOP
		CALL		Send_Hand_Shake

		;decode command
		;//parse Cmd , 21 = SetReport Out Data
		mov		a,21H
		xor		a,nCmdIndex1
		sz		z
		jmp		ProcessOutData

		;//parse Cmd , 18 = Mute Control
		mov		a,18H
		xor		a,nCmdIndex1
		sz		z
		jmp		Implement_Mute

		;//parse Cmd , 28 = Volume Control
		mov		a,28H
		xor		a,nCmdIndex1
		sz		z
		jmp		Implement_Volume

		;//unknow command
		jmp		USB_EP0_OUT_TOKEN_End
		
USB_EP0_OUT_TOKEN_End:
		clr		nCmdIndex1
		JMP		USB_EP0_ISR_END


Implement_Mute:
		clr wdt
		sz		FIFO_out1.0
		clr		USVC.7			;mute
		snz		FIFO_out1.0
		set		USVC.7			;unmute

		sz		FIFO_out1.0
		set		bFlag_Audio_Mute	;mute
		snz		FIFO_out1.0
		clr		bFlag_Audio_Mute	;unmute

		sz		FIFO_out1.0
		set		MUTE_LED_ON	;mute
		snz		FIFO_out1.0
		clr		MUTE_LED_ON	;unmute


		snz		bFlag_Audio_Mute
		jmp		Implement_Mute_1
		
		mov		a,Min_Volume
		mov		USVC,a
		
		clr		USVC.7
		
		
Implement_Mute_1:
		clr wdt
		;//kmov		Mute_Save,FIFO_out1
		jmp		USB_EP0_OUT_TOKEN_End
		

Implement_Volume:
		clr wdt
		kmov		VolumeH_Save,FIFO_out1
		kmov		VolumeL_Save,FIFO_out2
Implement_Volume_End:
		jmp		USB_EP0_OUT_TOKEN_End		

USB_EP0_ISR_END:
		;//CLR		USR.@USR_EP0F
		JMP		USB_ISR_END
;-----------------------------------------------------
;EPNPOINT 1 Interrupt
;-----------------------------------------------------
USB_EP1_ISR:
		CLR		USR.@USR_EP1F
		SNZ		bIniFMOK
		JMP		USB_EP1_ISR_END		;;FM Not initial OK,exit
		
		;check the data is in fifo ?
		CALL		FIFO1_RD_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		USB_EP1_ISR_END
		CALL		Read_FIFO1


		;;CALL		FIFO1_WR_CHECK
		;;SNZ		bFlag_FIFO_Ready
		;;JMP		USB_EP1_ISR_END
		;;MOV		A,00H
		;;MOV		FIFO_OUT1,A
		;;MOV		A,01H
		;;MOV		FIFO_SendLen,A
		;;CALL		WRITE_FIFO1	
		
		CALL		QN8027	



USB_EP1_ISR_END:
		JMP		USB_ISR_END
;-----------------------------------------------------
;EPNPOINT 2 Interrupt
;-----------------------------------------------------
USB_EP2_ISR:
		CLR		USR.@USR_EP2F
		;;SET		ET0I		;enable timer0
		;;SET		TMR0C.4		;致能  此時開始計數



		clr		MISC.@MISC_ISOEN		;關閉 ISO 中斷


USB_EP2_ISR_END:				
		JMP		USB_ISR_END


;***************************************************************
;		Stage  One  ....  Test bmRequestType
;		CALL   FIFO_RD_CHECK  will return bFlag_FIFO_Ready?(1=Ready,0=not ready)
;***************************************************************
StageOne:
		clr wdt
		CALL		FIFO0_RD_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		StageOne_End		; the EP0 FIFO RD is not ready 沒有data進來		
		CALL		Read_FIFO0		; Read EP0 Command
		clr		MISC.@MISC_SCMD
		clr		MISC.@MISC_LEN0
		
		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
		
		clr wdt
		nop

		MOV		A,FIFO_TYPE
		XOR		A,00H
		SZ		Z			;FIFO_TYPE=00H
		JMP		Request_Type00

		MOV		A,FIFO_TYPE
		XOR		A,01H
		SZ		Z			;FIFO_TYPE=01H
		JMP		Request_Type01

		MOV		A,FIFO_TYPE
		XOR		A,02H
		SZ		Z			;FIFO_TYPE=02H
		JMP		Request_Type02

		MOV		A,FIFO_TYPE
		XOR		A,80H
		SZ		Z			;FIFO_TYPE=80H
		JMP		Request_Type80

		MOV		A,FIFO_TYPE
		XOR		A,81H
		SZ		Z			;FIFO_TYPE=81H
		JMP		Request_Type81

		MOV		A,FIFO_TYPE
		XOR		A,82H
		SZ		Z			;FIFO_TYPE=82H
		JMP		Request_Type82

;===============================================================
;HID & Audio
;===============================================================
		MOV		A,FIFO_TYPE
		XOR		A,21H
		SZ		Z
		JMP		Request_Type21

;Volume Control
		clr wdt
		MOV		A,FIFO_TYPE
		XOR		A,0A1H
		SZ		Z
		JMP		Request_TypeA1

		JMP		SendStall0


StageOne_End:
		;modify 2007-06-20
		CLR		USR.@USR_EP0F	;Fix OHCI Volume
		RET


;***************************************************************
;		USB	 Stage2 
;		
;***************************************************************
;Device to Host with device as recipient
;===============================================================
;Request_Type00
;bRequest 	Function
; 1			Clear Feature
; 3			Set Feature
; 5			Set Address
; 7			not support
; 9			Set Configuration
;===============================================================
;===============================================================
Request_TYPE00:
;Set the device address to a non-zero value
;Set address
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,set_address
		SZ		Z
		JMP		SetAddress

;Set Configuration
		MOV		A,FIFO_REQUEST
		XOR		A,set_configuration
		SNZ		Z
		JMP		Request_TYPE00_NEXT

		SET		ET1I
		SET		TMR1C.4

		JMP		SetConfiguration

;Clear Feature
;The HT82A822R return ACK without ERROR
Request_TYPE00_NEXT:
		MOV		A,FIFO_REQUEST
		XOR		A,clear_feature
		SZ		Z
		JMP		ClearFeature

;Set Feature
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,set_feature
		SZ		Z
		JMP		SetFeature

		JMP		SendStall0
;===============================================================
Request_Type01:
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,set_interface
		SZ		Z
		JMP		SetInterface

		JMP		SendStall0		
;===============================================================
Request_Type02:
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,clear_feature
		SZ		Z
		JMP		ClearFeature_Endpoint

		MOV		A,FIFO_REQUEST
		XOR		A,set_feature
		SZ		Z
		JMP		SetFeature_Endpoint

		

		JMP		SendStall0		
	
		

;===============================================================
Request_TYPE80:
;Get Status
;Get Descriptor		80 06
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_descriptor
		SZ		Z
		JMP		GetDescriptor

;Get Configuration		80 08
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_configuration
		SZ		Z
		JMP		GetConfiguration

;Get Status(DEVICE)			80 00
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_status
		SZ		Z
		JMP		GetStatus

		JMP		SendStall0

;===============================================================
Request_TYPE81:
;get status
;get interface -> not support
;HID class defines one more request for bmRequestType=81
;get HID descriptor
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_descriptor
		SZ		Z
		JMP		GetDescriptor

;Get Interface
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_interface
		SZ		Z
		JMP		GetInterface

;Get Status(INTERFACE)			81 00
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_status
		SZ		Z
		JMP		GetStatus_Interface ;modify for Remote Wakeup

		JMP		SendStall0
;===============================================================
Request_TYPE82:
;get status
;Get Status(INTERFACE)			82 00
		clr wdt
		MOV		A,FIFO_REQUEST
		XOR		A,get_status
		SZ		Z
		JMP		GetStatus_Endpoint

		JMP		SendStall0
	
;===============================================================
;===============================================================
;Now parse HID class Descriptor Types
;===============================================================
;host to device with endpoint as recipient
Request_TYPE21:
		clr wdt
		;set report
		MOV		A,FIFO_REQUEST
		XOR		A,set_report
		SZ		Z
		JMP		SetReport

		;------------------------------------------------------
		;audio class-specific request code
		;------------------------------------------------------

		MOV		A,FIFO_REQUEST
		XOR		A,SET_CUR
		SZ		Z
		JMP		SetCur

Request_TYPE21_End:
		JMP		SendStall0	
		
Request_TypeA1:
		MOV		A,FIFO_REQUEST
		XOR		A,GET_MIN
		SZ		Z
		JMP		GetMin
		
		MOV		A,FIFO_REQUEST
		XOR		A,GET_MAX
		SZ		Z
		JMP		GetMax
		
		MOV		A,FIFO_REQUEST
		XOR		A,GET_RES
		SZ		Z
		JMP		GetRes

		MOV		A,FIFO_REQUEST
		XOR		A,GET_CUR
		SZ		Z
		JMP		GetCur
		

Request_TYPEA1_End:
		JMP		SendStall0
;===============================================================
ProcessOutData:
		sz		bFlag_Real_Cmd
		jmp		ProcessOutData_End
		
;;		clr wdt
;;		CALL		FIFO0_RD_CHECK
;;		SNZ		bFlag_FIFO_Ready
;;		JMP		ProcessOutData		; the EP0 FIFO RD is not ready 沒有data進來		

;;		CALL		Read_FIFO0
		CALL		QN8027
;;		nop
;;		call		FIFO1_WR_CHECK
;;		snz		bFlag_FIFO_Ready
;;		jmp		ProcessOutData_End
		
;;		call		Write_FIFO1
		

ProcessOutData_End:
		clr		nCmdIndex1
		jmp		USB_EP0_ISR_END	




Delay_20ms:
			clr wdt
			mov		a,075H
			mov		Delay_1,a
			mov		a,0FFH
			mov		Delay_2,a
Delay_20ms_Wait:
			clr wdt
			SDZ		Delay_2
			JMP		Delay_20ms_Wait
			SDZ		Delay_1
			JMP		Delay_20ms_Wait
			RET

Delay_5ms:
			clr wdt
			mov		a,03AH
			mov		Delay_1,a
			mov		a,0FFH
			mov		Delay_2,a
Delay_5ms_Wait:
			clr wdt
			SDZ		Delay_2
			JMP		Delay_5ms_Wait
			SDZ		Delay_1
			JMP		Delay_5ms_Wait
			RET


Delay 	PROC
		clr wdt	
		MOV		A,0FFH
		MOV		Delay_1,A
		MOV		Delay_2,A

Wait:
		clr wdt
		SDZ		Delay_2
		JMP		Wait
		SDZ		Delay_1
		JMP		Wait
		RET

Delay	ENDP



;***************************************************************
;		Run_Volume_Step Module
;		Volume1:Target
;		Volume2:Now
;***************************************************************
Run_Volume_Step:
		clr wdt
		;check mute?
		sz		bFlag_Audio_Mute
		jmp		Run_Volume_Step_End

	
		mov		a,VolumeL_Save
		mov		Volume1,a

		;check Volume1 = 080H ?
		mov		a,80H
		xor		a,Volume1
		sz		z
		jmp		Run_Volume_Step_Process_Min
		jmp		Run_Volume_Step_1

Run_Volume_Step_Process_Min:
		mov		a,Min_Volume
		mov		Volume1,a

		

Run_Volume_Step_1:		
		
		clr		Volume1.7

		mov		a,01111111b
		and		a,USVC
		mov		Volume2,a		;Volume2=now Volume1=target
		
		
		mov		a,Volume1
		xor		a,Volume2
		sz		z
		jmp		Run_Volume_Step_End	;target=now
		
		clr wdt
		mov		a,Volume1
		sub		a,Volume2		;target-now
		sz		C
		jmp		Run_Volume_1		;>0
		jmp		Run_Volume_2		;<0
		
Run_Volume_1:
		snz		Volume1.6
		jmp		Run_Volume_Step_Inc
		snz		Volume2.6
		jmp		Run_Volume_Step_Dec
		jmp		Run_Volume_Step_Inc
		
Run_Volume_2:
		snz		Volume2.6
		jmp		Run_Volume_Step_Dec
		snz		Volume1.6
		jmp		Run_Volume_Step_Inc
		jmp		Run_Volume_Step_Dec

		

Run_Volume_Step_Inc:
		INC		Volume2
		jmp		Run_Volume_Step_2
Run_Volume_Step_Dec:
		DEC		Volume2		
Run_Volume_Step_2:		
		sz		USVC.7
		set		Volume2.7
		snz		USVC.7
		clr		Volume2.7
		kmov		USVC,Volume2
		clr wdt		
Run_Volume_Step_End:				
		ret

;***************************************************************
;		Key_Debounced Module
;		Key_Defined : 欲偵測的 bit
;		Key_Process : 處理過後 請 set 此 bit
;		Key_CheckIn : 第一次偵測到需要 set 此 bit
;		Key_Counter : 儲存哪個 bit 為 1
;		如果需要連續動作則請勿 set Key_Process (如 INC,DEC Volume)
;		如果不需要連續動作請 set Key_Process (如 Mute,Play,Stop)
;***************************************************************
IF	UseMediaKey
Key_Debounced:
	       	clr wdt
	       	mov		a,VIOP
		cpl		acc
		mov		PortC_Data,a

		mov		a,Key_Defined
		andm		a,PortC_Data
		sz		z
		jmp		Key_Debounced_ClearReg	;//沒按鍵被按下


Key_Debounced_Detect_In:		
		kmov		Key_Temp,PortC_Data
		clr		Key_Counter
Key_Debounced_Detect:		
		clr		C
		RRC		Key_Temp
		sz		C
		jmp		Key_Debounced_Detect_End
		inc		Key_Counter
		mov		a,080H
		xor		a,Key_Temp
		sz		z
		jmp		Key_Debounced_Detect_End
		jmp		Key_Debounced_Detect
Key_Debounced_Detect_End:
		mov		a,Key_Counter
		call		GetPipeBit
		
		xor		a,Key_CheckIn
		snz		z
		jmp		Key_Debounced_SetCheckIn
		
		;check process
		mov		a,Key_Process
		xor		a,Key_CheckIn
		sz		z
		jmp		Key_Debounced_End
		jmp		Key_Debounced_Process		
		
;若不需要處理的請 jmp Key_Debounced_End
		nop
		nop
		nop
Key_Debounced_Process:
		clr wdt
		mov	a,Key_Counter
		addm	a,pcl
		jmp	Key_Debounced_Process_WindowsMediaPlayer
		jmp	Key_Debounced_Process_Mute
		jmp	Key_Debounced_Process_Dec
		jmp	Key_Debounced_Process_Inc
		jmp	Key_Debounced_Process_PlayPause
		jmp	Key_Debounced_Process_Stop
		jmp	Key_Debounced_Process_NextTrack
		jmp	Key_Debounced_Process_PreviousTrack

Key_Debounced_SetCheckIn:
		mov	Key_CheckIn,a
		clr	Key_Process
		kmov	Key_IncCounter,Const_Counter
		kmov	Key_DecCounter,Const_Counter
		jmp	Key_Debounced_End

Key_Debounced_ClearReg:
		clr		acc
		xor		a,Key_CheckIn
		sz		z
		jmp		Key_Debounced_End
		jmp		Key_Debounced_ClearReg_2
;		clr		acc
;		xor		a,Key_Process
;		snz		z
;		jmp		Key_Debounced_ClearReg_2
;		jmp		Key_Debounced_End

Key_Debounced_ClearReg_2:
		clr		Key_CheckIn
		clr		Key_Process

Key_Debounced_ClearReg_1:
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End

	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,00H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,00H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A		
	ENDIF
		CALL		WRITE_FIFO1
		;//write fifo
		nop				


Key_Debounced_My_Function:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		nop
		
		
		jmp		Key_Debounced_End	

Key_Debounced_End:
		clr wdt
		ret
;=========================Process
Key_Debounced_Process_Mute:
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End

	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,08H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,08H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn
		jmp	Key_Debounced_End
Key_Debounced_Process_Dec:
		clr wdt
		sdz	Key_DecCounter
		jmp	Key_Debounced_End

		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End
	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A	
		MOV		A,02H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE	
		MOV		A,02H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A		
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_DecCounter,Const_Counter
		nop
		jmp	Key_Debounced_End

Key_Debounced_Process_Inc:
		clr wdt
		sdz	Key_IncCounter
		jmp	Key_Debounced_End

		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End
	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	else	
		MOV		A,01H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A		
	ENDIF	
		CALL		WRITE_FIFO1
		nop
		kmov	Key_IncCounter,Const_Counter
		nop
		jmp	Key_Debounced_End

;===============================================================
;		User Add Some Key Debounced Code
;===============================================================
Key_Debounced_Process_WindowsMediaPlayer:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End

	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,04H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,04H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn
		jmp	Key_Debounced_End

Key_Debounced_Process_PlayPause:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End

	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,10H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,10H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn

		jmp	Key_Debounced_End

Key_Debounced_Process_Stop:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End
	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,20H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,20H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn

		jmp	Key_Debounced_End

Key_Debounced_Process_NextTrack:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End
	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,40H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,40H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn

		jmp	Key_Debounced_End

Key_Debounced_Process_PreviousTrack:
	;-----------------------------------------------------------
	; Here to add your another code !!
	;-----------------------------------------------------------
		clr wdt
		CALL		FIFO1_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		Key_Debounced_End
	IF	UseReportID
		MOV		A,01H		;REPORT ID
		MOV		FIFO_OUT1,A
		MOV		A,80H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A		
	ELSE
		MOV		A,80H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_SendLen,A				
	ENDIF
		CALL		WRITE_FIFO1
		nop
		kmov	Key_Process,Key_CheckIn

		jmp	Key_Debounced_End
ENDIF


wait_about_1s:
	;;;*******************************************
	;;;delay 1S 255*255*3*16*0.3333333=1.04S
	;;;*******************************************
		clr wdt
		clr		Delay_1
		clr		Delay_2
		kmov		Delay_3,16
	wait_about_1s_loop:
		clr wdt
		sdz		Delay_1
		jmp		wait_about_1s_loop
		sdz		Delay_2
		jmp		wait_about_1s_loop
		sdz		Delay_3
		jmp		wait_about_1s_loop
		clr wdt
		nop
	ret	



Public		FIFO_Size
Public		FIFO_SendLen

Public		FIFO_Type
Public		FIFO_Request
Public		FIFO_wValueL
Public		FIFO_wValueH
Public		FIFO_wIndexL
Public		FIFO_wIndexH
Public		FIFO_wLengthL
Public		FIFO_wLengthH

Public		FIFO_Out1
Public		FIFO_Out2
Public		FIFO_Out3
Public		FIFO_Out4
Public		FIFO_Out5
Public		FIFO_Out6
Public		FIFO_Out7
Public		FIFO_Out8

Public		USB_Interface
Public		USB_Interface_Alt
Public		USB_Configuration

Public		FIFO_ADDR



Public		nCmdIndex1


Public		Loop_Counter
Public		Data_Count
Public		Data_Start
Public		FIFO_TEMP
Public		bFlag_Real_Cmd
Public		bFlag_FIFO_Ready
Public		bFlag_FIFO_LEN0
Public		bFlag_RD_HTable
Public		bFlag_wait_control_out
Public		bFlag_SET_ADDRESS
Public		bFlag_SCMD
Public		bFlag_Enum_Ready
Public		bFlag_SetConfiguration_Ready
Public		bFlag_SetInterface_Ready


Public		USB_ISR_END
Public		USB_EP0_ISR_END
Public		StageOne



Public	VolumeH_Save
Public  VolumeL_Save
Public	bFlag_Audio_Mute
;modify for Remote Wakeup
public      bRmtWakeup
public      b_wakeup

;;-----------------------------------------------
#include	QN8027Driver.asm
#include	QN8072Sub.asm

END
