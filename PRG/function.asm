;*********************************************************************
;	Functin Library
;	Author : Ansonku
;	EMail  : ansonku@holtek.com.tw
;	Date   : 2005/01/11
;*********************************************************************
#include		ht82a821R.inc
#include		const.inc
;=====================================================================
;	Descriptor Label
;=====================================================================
;2005/11/01  ClearFeature_Endpoint add Send_Hand_Shake 
;
;2006/02/16  更改 Sned_Hand_Shake 避免產生不正常 stack 
;2006/02/16  更改 control_read , 加入避免 descriptor 為八的倍數時所會產生的問題
;            若是descirptor 已回完還收到 in token , 那麼一律回 send_hand_shake
;
;
;
;





extern			control_read_table:NEAR        
extern			device_desc_table:NEAR         
extern			config_desc_table:NEAR         

extern			end_config_desc_table:NEAR  
extern			hid_report_desc_table:NEAR
extern			end_hid_report_desc_table:NEAR

extern			USBStringLanguageDescription:NEAR
extern			USBStringDescription1:NEAR
extern			USBStringDescription2:NEAR
extern			USBStringDescription3:NEAR
extern			HID_Desc:NEAR

extern			config_desc_length:NEAR
extern			hid_desc_length:NEAR
extern			report_desc_length:NEAR


extern			USB_EP0_ISR_END:NEAR

;=====================================================================
;	External Variable
;=====================================================================
extern		FIFO_Size:byte
extern		FIFO_SendLen:byte
extern		FIFO_Type:byte
extern		FIFO_Request:byte
extern		FIFO_wValueL:byte
extern		FIFO_wValueH:byte
extern		FIFO_wIndexL:byte
extern		FIFO_wIndexH:byte
extern		FIFO_wLengthL:byte
extern		FIFO_wLengthH:byte

extern		FIFO_Out1:byte
extern		FIFO_Out2:byte
extern		FIFO_Out3:byte
extern		FIFO_Out4:byte
extern		FIFO_Out5:byte
extern		FIFO_Out6:byte
extern		FIFO_Out7:byte
extern		FIFO_Out8:byte

extern		USB_Interface:byte
extern		USB_Interface_Alt:byte
extern		USB_Configuration:byte

extern		FIFO_ADDR:byte



extern		Loop_Counter:byte
extern		Data_Count:byte
extern		Data_Start:byte


extern		nCmdIndex1:byte

extern		VolumeH_Save:byte
extern		VolumeL_Save:byte
extern		bFlag_Audio_Mute:bit
;modify for Remote Wakeup
extern    	bRmtWakeup  :bit
extern    	b_wakeup    :bit

;=====================================================================
;	FIFO Status
;=====================================================================

;FIFO
extern		FIFO_TEMP:byte
extern		bFlag_Real_Cmd:bit
extern		bFlag_FIFO_Ready:bit
extern		bFlag_FIFO_LEN0:bit
extern		bFlag_RD_HTable:bit
extern		bFlag_wait_control_out:bit
extern		bFlag_SET_ADDRESS:bit
extern		bFlag_SCMD:bit
extern		bFlag_Enum_Ready:bit
extern		bFlag_SetConfiguration_Ready:bit
extern		bFlag_SetInterface_Ready:bit

extern		StageOne:NEAR
extern		USB_ISR_END:NEAR
;********************************************************************
;		USB	 LIB  
;		1.CHECK FIFOX RD READEY? bFlag_FIFO_Ready = 1:bFlag_FIFO_Ready = 0
;********************************************************************
FIFO0_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111000b
		MOV		UCC,A
		
		MOV		A,00000000b
		JMP		FIFO_CHECK
FIFO1_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111001b
		MOV		UCC,A

		MOV		A,00000000b
		JMP		FIFO_CHECK
FIFO2_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111010b
		MOV		UCC,A

		MOV		A,00000000b
		JMP		FIFO_CHECK
FIFO3_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111011b
		MOV		UCC,A
		
		MOV		A,00000000b
		JMP		FIFO_CHECK
FIFO4_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111100b
		MOV		UCC,A
		
		MOV		A,00000000b
		JMP		FIFO_CHECK

FIFO5_RD_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111101b
		MOV		UCC,A
		
		MOV		A,00000000b
		JMP		FIFO_CHECK
;********************************************************************
;		USB	 LIB  
;		1.CHECK FIFOX WR READEY ?  bFlag_FIFO_Ready = 1:bFlag_FIFO_Ready = 0
;********************************************************************

;LEN0 ready to write??
LEN0_WR_CHECK:
;CHECK FIFOX ready to write?
FIFO0_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111000b
		MOV		UCC,A
		
		MOV		A,00000010b
		JMP		FIFO_CHECK
FIFO1_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111001b
		MOV		UCC,A

		MOV		A,00000010b
		JMP		FIFO_CHECK
FIFO2_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111010b
		MOV		UCC,A

		MOV		A,00000010b
		JMP		FIFO_CHECK
FIFO3_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111011b
		MOV		UCC,A
		
		MOV		A,00000010b
		JMP		FIFO_CHECK
FIFO4_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111100b
		MOV		UCC,A
		
		MOV		A,00000010b
		JMP		FIFO_CHECK

FIFO5_WR_CHECK:
		MOV		A,UCC
		OR		A,00000111b
		AND		A,11111101b
		MOV		UCC,A
		
		MOV		A,00000010b
		JMP		FIFO_CHECK

FIFO_CHECK:
		clr wdt
		MOV		FIFO_TEMP,A
		MOV		A,USB_MISC
		MOV		MP1,A
		MOV		A,R1
		AND		A,11111000b
		OR		A,FIFO_TEMP
		MOV		R1,A
		CALL		Delay_3us
		SET		R1.@MISC_REQ			;set request
		CALL		Delay_28us
		SET		bFlag_FIFO_Ready
		SNZ		R1.@MISC_Ready
		CLR		bFlag_FIFO_Ready	;if MISC.Ready = 1 -> bFlag_FIFO_Ready = 1
		SET		bFlag_FIFO_LEN0
		SNZ		R1.@MISC_LEN0
		CLR		bFlag_FIFO_LEN0

		;;SZ		bFlag_FIFO_Ready
		clr		MISC.@MISC_REQ
		clr wdt
		RET


ReadLen0:
		MOV		A,USB_FIFO0
		MOV		MP1,A
		MOV		A,R1
		NOP
		JMP		Read_FIFO_END
Read_FIFO0:
		MOV		A,USB_FIFO0_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO0
		JMP		Read_FIFO
Read_FIFO1:
		MOV		A,USB_FIFO1_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO1
		JMP		Read_FIFO
Read_FIFO2:
		MOV		A,USB_FIFO2_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO2
		JMP		Read_FIFO
Read_FIFO3:
		MOV		A,USB_FIFO3_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO3
		JMP		Read_FIFO
Read_FIFO4:
		MOV		A,USB_FIFO4_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO4
		JMP		Read_FIFO
Read_FIFO5:
		MOV		A,USB_FIFO5_SIZE
		MOV		FIFO_SIZE,A
		MOV		A,USB_FIFO5
		JMP		Read_FIFO

Read_FIFO:
		SET		MISC.@MISC_REQ

		MOV		FIFO_TEMP,A		;FIFO_TEMP SAVE FIFOX ADDRESS
		CLR		FIFO_SendLen
		MOV		A,OFFSET FIFO_Type
		MOV		MP0,A
Read_FIFO_Loop:
		MOV		A,FIFO_TEMP
		MOV		MP1,A
		MOV		A,R1
		MOV		R0,A
		INC		FIFO_SendLen
		INC		MP0
		MOV		A,FIFO_SIZE
		XOR		A,FIFO_SendLen
		SZ		Z				;1=FIFO_SIZE=FIFO_SendLen
		JMP		Read_FIFO_End
		MOV		A,USB_MISC
		MOV		MP1,A
		CALL		Delay_28us
		SZ		R1.@MISC_Ready
		JMP		Read_FIFO_LOOP
		JMP		Read_FIFO_End

Send_Hand_Shake:
Send_Hand_Shake_wait:
		; protect die loop
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		;jmp		USB_EP0_ISR_END
		ret				;modify by 2006-02-16

		CALL		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready             ; acai remark 2007-1-23
		JMP		Send_Hand_Shake_wait

		set		MISC.@MISC_REQ
WriteLen0:
Write_FIFO_OK:
Read_FIFO_End:
		MOV		A,USB_MISC
		MOV		MP1,A
		MOV		A,(01H SHL @MISC_TX)		;Change TX State
		;CLR		INTC0.0
		XORM		A,R1
		CALL		Delay_3us
		CLR		R1.@MISC_REQ
		;SET		INTC0.0
		RET

;============================================================
;Function:Write FIFOx from FIFO_OUTx
;============================================================
Write_FIFO0:
		MOV		A,USB_FIFO0
		JMP		Write_FIFO
Write_FIFO1:
		MOV		A,USB_FIFO1
		JMP		Write_FIFO
Write_FIFO2:
		MOV		A,USB_FIFO2
		JMP		Write_FIFO
Write_FIFO3:
		MOV		A,USB_FIFO3
		JMP		Write_FIFO
Write_FIFO4:
		MOV		A,USB_FIFO4
		JMP		Write_FIFO
Write_FIFO5:
		MOV		A,USB_FIFO5
		JMP		Write_FIFO

Write_FIFO:
		clr wdt
		SET		MISC.@MISC_REQ

		MOV		FIFO_TEMP,A		;FIFO NO Address
		MOV		A,OFFSET FIFO_OUT1
		MOV		MP0,A
Write_FIFO_Loop:
		clr wdt
		MOV		A,FIFO_SendLen
		XOR		A,00H
		SZ		Z
		JMP		Write_FIFO_End
		
		MOV		A,FIFO_TEMP
		MOV		MP1,A
		MOV		A,R0
		MOV		R1,A
		DEC		FIFO_SendLen
		MOV		A,FIFO_SendLen
		XOR		A,00H
		SZ		Z
		JMP		Write_FIFO_End		;FIFO_SendLen=0 代表傳完了
		INC		MP0
		MOV		A,USB_MISC
		MOV		MP1,A
		call		Delay_28us
		SZ		R1.@MISC_Ready
		JMP		Write_FIFO_Loop
Write_FIFO_End:
		clr wdt
		JMP		Write_FIFO_OK


get_descriptor_length:
		clr wdt
		MOV		A,FIFO_WLENGTHH
		XOR		A,0
		SNZ		Z
		JMP		use_actual_length
		MOV		A,FIFO_WLENGTHL
		XOR		A,0
		SZ		Z
		JMP		use_actual_length
		MOV		A,FIFO_WLENGTHL
		SUB		A,data_count
		SZ		C			;if(FIFO_LENGTHL>data_count) c=1
		JMP		use_actual_length
		MOV		A,FIFO_WLENGTHL
		MOV		data_count,A
use_actual_length:
		RET
;===============================================================
;		Function : Control_read
;		Purpose  : Performs the control read operation as
;				   defined by the USB specification
;				   setup-in-in-in-....-out
;		data_start:must be set to the descriptors info as an offset
;				   from the beginning of the control read table
;				   data count holds the
;		data_count:must beset to the size of the descriptor
;		bFlag_RD_HTable==1 ==> Must be read Hight Bytes
;		TBLP	  :Table Index
;===============================================================
control_read:
		clr wdt
		MOV		A,data_start
		MOV		TBLP,A
control_read_data_stage:
		clr wdt
		MOV		A,00H
		MOV		Loop_Counter,A
		MOV		FIFO_SendLen,A


		SZ		MISC.@MISC_SCMD
		JMP		control_read_status_stage_end
		clr wdt
		
		MOV		A,OFFSET FIFO_TYPE
		MOV		MP0,A

		MOV		A,data_count
		XOR		A,00H
		SZ		Z
		JMP		dma_load_done			;A=00H

dma_load_loop:
		clr wdt
		SNZ		bFlag_RD_HTable
		JMP		Read_Low_Bytes
Read_High_Bytes:
		clr wdt
		CLR		bFlag_RD_HTable
		TABRDL		R0
		INC		TBLP
		INC		data_start
		MOV		A,TBLH
		AND		A,00111111b
		MOV		R0,A
		XOR		A,3FH
		SZ		Z
		JMP		dma_load_loop

		JMP		Check_Read_Length

Read_Low_Bytes:
		clr wdt
		SET		bFlag_RD_HTable
		TABRDL		R0
		MOV		A,R0
Check_Read_Length:
		clr wdt
		INC		MP0
		INC		loop_counter
		INC		FIFO_SendLen
		DEC		data_count
		SZ		Z
		JMP		wait_control_read
		MOV		A,loop_counter
		XOR		A,EP0_FIFO_SIZE
		SNZ		Z
		JMP		dma_load_loop
		jmp		wait_control_read
dma_load_done:
		clr wdt
		;SZ		MISC.@MISC_SCMD
		;JMP		control_read_status_stage_end
		CALL		Send_Hand_Shake
		jmp		control_read_status_stage_end		

wait_control_read:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		control_read_status_stage_end		
		
		clr wdt
		CALL		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		wait_control_read	;wait FIFO0 Ready
		CALL		Write_FIFO0
control_read_status_stage_end:	
		clr wdt			
		NOP
		RET		


;-----------------------------------------------------------
; Check_Real_Cmd : if have new cmd , set bFlag_Real_Cmd else clr bFlag_Real_Cmd
;-----------------------------------------------------------
Check_Real_Cmd:
		clr wdt
		clr		bFlag_Real_Cmd
		SZ		MISC.@MISC_SCMD
		set		bFlag_Real_Cmd
		SZ		MISC.@MISC_LEN0
		set		bFlag_Real_Cmd
		RET

;***************************************************************
;		USB	 Stage3 
;		Process the request
;***************************************************************
;Set the device address to the wValue in the SETUP packet at the completion
;of the current transaction
;-----------------------------------------------------------
; Set Address
;-----------------------------------------------------------
SetAddress:
		clr wdt
		MOV		A,FIFO_WVALUEL		;save address to FIFO_ADDR
		MOV		FIFO_ADDR,A
		MOV		FIFO_TEMP,A		

		MOV		A,USB_SIES
		MOV		MP1,A
		MOV		A,00000001b
		ORM		A,R1
		RLA		FIFO_TEMP
		AND		A,0FEH
		MOV		FIFO_TEMP,A
		
		MOV		A,USB_AWR
		MOV		MP1,A
		MOV		A,FIFO_TEMP
		MOV		R1,A
		NOP

		CALL		Send_Hand_Shake		;send a handshake with host
		
		SET		bFlag_Set_Address
		;;RET					;for test
		JMP		USB_EP0_ISR_END

;-----------------------------------------------------------
; Set Configuration
;-----------------------------------------------------------
SetConfiguration:
		clr wdt
		set		USVC.7			;unmute		

		MOV		A,FIFO_WVALUEL	
		MOV		USB_Configuration,A
		CLR		STALL
		;MOV		A,USB_STALL
		;MOV		MP1,A
		;CLR 		R1					;not stall
		set		bFlag_SetConfiguration_Ready
SetConfiguration_wait:
		CALL		Send_Hand_Shake
		JMP		USB_EP0_ISR_END

;-----------------------------------------------------------
; Set Interface
;-----------------------------------------------------------
SetInterface:
		clr wdt
		MOV		A,FIFO_WVALUEL
		MOV		USB_Interface_Alt,A
		MOV		A,FIFO_WINDEXL
		MOV		USB_Interface,A
		set		bFlag_SetInterface_Ready
		set		USB_LED_ON
SetInterface_wait:
		CALL		Send_Hand_Shake
		JMP		USB_EP0_ISR_END

;-----------------------------------------------------------
; Get Interface
;-----------------------------------------------------------
GetInterface:
		clr wdt
		mov		A,USB_Interface_Alt
		mov		FIFO_OUT1,A
		
		mov		A,01H
		mov		FIFO_SendLen,A
		
GetInterface_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetInterface_End
		clr wdt
		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetInterface_Loop

		CALL		Write_FIFO0
		
GetInterface_End:
		JMP		USB_EP0_ISR_END

;-----------------------------------------------------------
; Get Status
; For Get Status (DEVICE,INTERFACE,ENDPOINT) , if self-powered and remote wakeup need to modify
; return 2 bytes (00 00)
;-----------------------------------------------------------
GetStatus:
		clr wdt	
		mov		a,02H
		mov		FIFO_SendLen,a
		
		;Modify for Remote Wakeup		
		mov		a,02H
		snz   		bRmtWakeup
		;------------------------
		mov		a,00H
		mov		FIFO_Out1,a
		clr		FIFO_Out2
		
GetStatus_Loop:
		clr wdt	
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetStatus_End
		clr wdt	
		
		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetStatus_Loop

		CALL		Write_FIFO0
		
GetStatus_End:
		JMP		USB_EP0_ISR_END

;-----------------------------------------------------------
; Get Status (Endpoint)
;-----------------------------------------------------------
;-----------------------------------------------------------
; Get Status (Interface)
; return 2 bytes (00 00)
;-----------------------------------------------------------
;Modify for Remote Wakeup
GetStatus_Interface:
		clr wdt	
		mov		a,02H
		mov		FIFO_SendLen,a
		
		
		mov		a,00H
		mov		FIFO_Out1,a
		clr		FIFO_Out2
		
GetStatus_Inerface_Loop:
		clr wdt	
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetStatus_End
		clr wdt	
		
		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetStatus_Inerface_Loop

		CALL		Write_FIFO0
		
GetStatus_Inerface_Loop_End:
		JMP		USB_EP0_ISR_END
;-----------------------------------------------------------
; Get Status (Endpoint)
;-----------------------------------------------------------
GetStatus_Endpoint:
		clr wdt
		mov		a,02H
		mov		FIFO_SendLen,a

		mov		a,07FH
		and		a,FIFO_wIndexL
		
		call		GetPipeBit
		mov		FIFO_TEMP,a
		mov		a,STALL
		and		a,FIFO_TEMP
		mov		FIFO_TEMP,a

		clr		FIFO_Out1		
		sz		FIFO_TEMP
		set		FIFO_Out1.0
		
		clr		FIFO_Out2
		
		jmp		GetStatus_Loop
		

GetStatus_Endpoint_End:
		JMP		USB_EP0_ISR_END
;-----------------------------------------------------------
; Clear Feature : The HT82A822R return ACK without ERROR
; bmRequest: 00  	Device
;	     02	 	EndPoint
; bRequest   01  	CLEAR_FEATURE
; wValue     0000 	clear ENDPOINT0 HALT
;	     0001	clear REMOTE_WAKEUP
; wIndex     0000
; wLength    0000
;-----------------------------------------------------------
ClearFeature:
;;----2007-01-10 for Vista DTM----
    mov     a,FIFO_wValueL
    xor		a,01H
		snz		z
		JMP		SendStall0
    ;set     b_wakeup
    ;clr     bRmtWakeup
;;------------------------------    
		clr wdt
		;Modify for Remote Wakeup	
		set     b_wakeup
    		clr     bRmtWakeup 
    		;-----------------------
		CALL		Send_Hand_Shake		
ClearFeature_Loop:
ClearFeature_End:
		JMP		USB_EP0_ISR_END
;-----------------------------------------------------------
; Clear Feature (Endpoint)
;-----------------------------------------------------------
ClearFeature_Endpoint:
		clr wdt
		
		
		snz		bFlag_SetConfiguration_Ready
		JMP		SendStall0

		mov		a,07FH
		and		a,FIFO_wIndexL

		call		GetPipeBit
		
		mov		FIFO_TEMP,a
		CPL		FIFO_TEMP
		mov		a,STALL
		AND		a,FIFO_TEMP
		mov		STALL,a

		CALL		Send_Hand_Shake		
		
		
ClearFeature_Endpoint_End:
		JMP		USB_EP0_ISR_END		

;-----------------------------------------------------------
; Set Feature
;-----------------------------------------------------------
SetFeature:
;;----2007-01-10 for Vista DTM----
    		mov   		a,FIFO_wValueH
    		xor		a,00H
		sz		z
		JMP		SetFeature_1
		
    		mov		a,FIFO_wValueH
		sub		a,81H		;target-now
		snz		C
		jmp		SendStall0	;<81H
		                    ;>=81H
		mov		a,FIFO_wValueH
		sub		a,84H		;target-now
		sz		C
		jmp		SendStall0	;>=84H
		
		mov     	a,FIFO_wValueL
    		xor		a,00H
		snz		z
		JMP		SendStall0
		jmp		SetFeature_2		
		
SetFeature_1:    
   		mov     	a,FIFO_wValueL
    		xor		a,01H
		snz		z
		JMP		SendStall0

SetFeature_2:

;;----------------------------------
		;Modify for Remote Wakeup
		set     b_wakeup
   		set     bRmtWakeup
   		;----------------------- 
		CALL		Send_Hand_Shake
SetFeature_Loop:
SetFeature_End:
		JMP		USB_EP0_ISR_END
;-----------------------------------------------------------
; Set Feature (Endpoint)
;-----------------------------------------------------------
SetFeature_Endpoint:
		clr wdt
		snz		bFlag_SetConfiguration_Ready
		JMP		SendStall0
		
		mov		a,07FH
		and		a,FIFO_wIndexL

		call		GetPipeBit
		
		mov		FIFO_TEMP,A
		mov		a,STALL
		or		a,FIFO_TEMP
		mov		STALL,a
		
		CALL		Send_Hand_Shake

SetFeature_Endpoint_End:
		JMP		USB_EP0_ISR_END
;-----------------------------------------------------------
; Get Descriptor
;-----------------------------------------------------------
GetDescriptor:
		clr wdt
		CLR		bFlag_RD_HTable
		CLR		bFlag_wait_control_out

		MOV		A,FIFO_WvalueH		;80 06 00 01
		XOR		A,device
		SZ		Z
		JMP		GetDeviceDescriptor

		MOV		A,FIFO_WvalueH		;80 06 00 02
		XOR		A,configuration
		SZ		Z
		JMP		GetConfigurationDescriptor

		MOV		A,FIFO_WvalueH		;80 06 00 03
		XOR		A,string
		SZ		Z
		JMP		GetStringDescriptor


		;------------------------------------------------------
		;Then test for HID class Descriptor
		;------------------------------------------------------

		MOV		A,FIFO_WvalueH		;81 06 00 22
		XOR		A,report
		SZ		Z
		JMP		GetReportDescriptor

		MOV		A,FIFO_WvalueH		;81 06 00 21
		XOR		A,HID
		SZ		Z
		JMP		GetHIDDescriptor
		


		JMP		SendStall0			;can't parser

;-----------------------------------------------------------
; GetConfiguration
;-----------------------------------------------------------
GetConfiguration:
		clr wdt
		mov		a,01H
		mov		FIFO_SendLen,a
		
		mov		a,USB_Configuration
		mov		FIFO_OUT1,a
GetConfiguration_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetConfiguration_End
		clr wdt
		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetConfiguration_Loop

		CALL		Write_FIFO0
GetConfiguration_End:
		JMP		USB_EP0_ISR_END
		


;------------------------------------------------------
;Report
;------------------------------------------------------
SetReport:
		clr wdt
		mov		a,FIFO_wValueH
		xor		a,set_output_report
		sz		z
		jmp		SetOutputReport
		
		JMP		USB_EP0_ISR_END
SetReport_End:

SetOutputReport:
		clr wdt
		;check interface
		mov		a,FIFO_wIndexL
		xor		a,02H
		snz		z
		jmp		SendStall0
		;check length
		mov		a,FIFO_wLengthL
		xor		a,08H
		snz		z
		jmp		SendStall0
		
		mov		a,21H
		mov		nCmdIndex1,a
		
		
SetOutputReport_End:
		JMP		USB_EP0_ISR_END
;------------------------------------------------------
;Audio class 
;------------------------------------------------------
;21 01
SetCur:
		clr wdt
		MOV		A,FIFO_WVALUEH
		XOR		A,MUTE_CONTROL
		SZ		Z
		JMP		MuteControl

		MOV		A,FIFO_WVALUEH
		XOR		A,VOLUME_CONTROL
		SZ		Z
		JMP		VolumeControl

		JMP		SendStall0			;can't parser

;21 01 00 01
MuteControl:			;(if have more feature , the state must be modify!!)
		clr wdt
		mov		a,18h
		mov		nCmdIndex1,a

		;;RET
		;;modify 2005-12-13
		jmp		USB_EP0_ISR_END
;21 01 00 02
VolumeControl:
		clr wdt
		mov		a,28h
		mov		nCmdIndex1,a		
		;;RET
		;;modify 2005-12-13
		jmp		USB_EP0_ISR_END

;return D2 00 = -46 db
;return BC 00 = -32 db (原本為 E0)
GetMin:
		clr wdt
		MOV		A,00H
		MOV		FIFO_OUT1,A
;;		MOV		A,0E0H
		MOV		A,Min_Volume
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A
GetMin_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetMin_End
		clr wdt
		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetMin_Loop
		
		CALL		Write_FIFO0
GetMin_End:		
		;;RET
		;;2005-12-13 modify
		jmp		USB_EP0_ISR_END


;return 0x0C00
GetMax:
		clr wdt
		MOV		A,00H
		MOV		FIFO_OUT1,A
;;		MOV		A,0CH
		MOV		A,Max_Volume
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A
GetMax_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetMax_End
		clr wdt

		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetMax_Loop
		
		
		CALL		Write_FIFO0
GetMax_End:
;		RET
		;;2005-12-13 modify
		jmp		USB_EP0_ISR_END





;return 0x0100 1db		
GetRes:
		clr wdt
		MOV		A,00H
		MOV		FIFO_OUT1,A
		MOV		A,01H
		MOV		FIFO_OUT2,A
		MOV		A,02H
		MOV		FIFO_SendLen,A
GetRes_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetRes_End

		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetRes_Loop
		
		CALL		Write_FIFO0
GetRes_End:
;		RET
		;;2005-12-13 modify
		jmp		USB_EP0_ISR_END


GetCur:
;;		call		Check_Real_Cmd
;;		sz		bFlag_Real_Cmd
;;		jmp		GetCur_End
;;
;;
;;		call		FIFO0_WR_CHECK
;;		SNZ		bFlag_FIFO_Ready
;;		JMP		GetCur

;;		
;;		MOV		A,FIFO_wLengthL
;;		MOV		FIFO_SendLen,A
;;		
;;		MOV		FIFO_TEMP,A
;;		MOV		A,OFFSET FIFO_OUT1
;;		MOV		MP1,A
;;GetCur_Fill0:
;;		MOV		A,00H
;;		MOV		R1,A
;;		INC		MP1
;;		DEC		FIFO_TEMP
;;		MOV		A,00H
;;		XOR		A,FIFO_TEMP
;;		SNZ		Z
;;		JMP		GetCur_Fill0
;;		CALL		Write_FIFO0
		clr wdt
		MOV		A,FIFO_wLengthL
		MOV		FIFO_SendLen,A
		
		MOV		A,01H
		XOR		A,FIFO_SendLen
		sz		z
		jmp		GetCur_Mute

		MOV		A,02H
		XOR		A,FIFO_SendLen
		sz		z
		jmp		GetCur_Volume
		jmp		GetCur_End

GetCur_Mute:
		clr wdt
		MOV		A,00H
		sz		bFlag_Audio_Mute
		MOV		A,01H
		mov		FIFO_OUT1,A
GetCur_Mute_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetCur_End


		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetCur_Mute_Loop

		call		Write_FIFO0
		jmp		GetCur_End
GetCur_Volume:
		clr wdt
		MOV		A,VolumeH_Save
		mov		FIFO_OUT1,A

		MOV		A,VolumeL_Save
		mov		FIFO_OUT2,A
GetCur_Volume_Loop:
		clr wdt
		call		Check_Real_Cmd
		sz		bFlag_Real_Cmd
		jmp		GetCur_End


		call		FIFO0_WR_CHECK
		SNZ		bFlag_FIFO_Ready
		JMP		GetCur_Volume_Loop

		call		Write_FIFO0
		jmp		GetCur_End
GetCur_End:
;		RET
		;;2005-12-13 modify
		jmp		USB_EP0_ISR_END

;--------------------------------------------------------------
; 未完成
SetIdle:
		JMP		SendStall0			;can't parser

;==============================================================
;Standard Get Descriptor routines
;
;Return the device descriptor to the host
GetDeviceDescriptor:
		clr wdt
		MOV		A,LOW device_desc_table
		MOV		TBLP,A
		TABRDL		data_count
		;modify 2005-12-02
		CALL		Execute
		jmp		USB_EP0_ISR_END

GetConfigurationDescriptor:
		clr wdt
		MOV		A,LOW config_desc_length
		MOV		TBLP,A
		TABRDL		data_count
		MOV		A,LOW config_desc_table
		;modify 2005-12-02
		call		Execute		
		jmp		USB_EP0_ISR_END
;Not Ready!!!!!!!!!
GetStringDescriptor:
		clr wdt
		MOV		A,FIFO_WVALUEL
		XOR		A,00H
		SZ		Z
		JMP		LanguageString

		MOV		A,FIFO_WVALUEL
		XOR		A,01H
		SZ		Z
		JMP		ManufacturerString

		MOV		A,FIFO_WVALUEL
		XOR		A,02H
		SZ		Z
		JMP		ProductString

		MOV		A,FIFO_WVALUEL
		XOR		A,03H
		SZ		Z
		JMP		SerialNumberString
	
	
		JMP		SendStall0			;other no support

LanguageString:
		clr wdt
		MOV		A,LOW USBStringLanguageDescription
		MOV		TBLP,A
		TABRDL		data_count
		MOV		A,LOW USBStringLanguageDescription
		;modify 2005-12-02
		call		execute
		jmp		USB_EP0_ISR_END
ManufacturerString:
		clr wdt
		MOV		A,LOW USBStringDescription1
		MOV		TBLP,A
		TABRDL		data_count
		MOV		A,LOW USBStringDescription1
		;modify 2005-12-02
		call		execute
		jmp		USB_EP0_ISR_END
ProductString:
		clr wdt
		MOV		A,LOW USBStringDescription2
		MOV		TBLP,A
		TABRDL		data_count
		MOV		A,LOW USBStringDescription2
		;modify 2005-12-02
		call		execute
		jmp		USB_EP0_ISR_END


SerialNumberString:
		clr wdt
		MOV		A,LOW USBStringDescription3
		MOV		TBLP,A
		TABRDL		data_count
		MOV		A,LOW USBStringDescription3
		;modify 2005-12-02
		call		execute
		
		jmp		USB_EP0_ISR_END

		

;--------------------------------------------------
;HID class Get Descriptor routines
;return the HID descriptor and enable endpoint one
;--------------------------------------------------
GetReportDescriptor:
		clr wdt
		MOV		A,LOW report_desc_length
		MOV		TBLP,A
		TABRDL		data_count			;Report length = Low byte of Report_Size
		MOV		A,LOW hid_report_desc_table
		CALL		execute			;send descriptor to host
		;
		;Enumeration is complete!!
		;
		set		bFlag_Enum_Ready		;set Enumeration flag
		;modify 2005-12-02
		jmp		USB_EP0_ISR_END		

GetHIDDescriptor:
		clr wdt
		MOV		A,LOW hid_desc_length
		MOV		TBLP,A
		TABRDL		data_count			;Report length = Low byte of Report_Size
		MOV		A,LOW HID_Desc
		;modify 2005-12-02
		CALL		execute			;send descriptor to host
		jmp		USB_EP0_ISR_END		

Execute:
		clr wdt
		MOV		data_start,A
		call		get_descriptor_length
		call		control_read
		RET				

;===============================================================
SendStall0:
		SET		STALL.@STALL_STL0
		JMP		USB_EP0_ISR_END		
						;return to USB_EP0_ISR		













;***************************************************************
;		Delay Test Function
;		Most instructions Timing is one cycles = 0.33333 us
;		call , jmp , ret is 2 cycles
;***************************************************************

Delay_28us:
			mov		a,1EH	
Delay_28us_cont:
			clr wdt
			sdz		acc
			jmp		Delay_28us_cont
Delay_3us:
			clr wdt
			NOP
			NOP
			NOP
			NOP
			clr wdt
			ret


;----BEGIN (Get pipe bit)
;Input : ACC pipe number
;Output: ACC pip bit (D0:pipe 0, D1:pipe 1...)
GetPipeBit:		 		
                INC     ACC
                MOV     FIFO_TEMP,A
                MOV     A,80H
GetPipeBitLoop:
				clr wdt
                RL      ACC
                SDZ     FIFO_TEMP 
                JMP     GetPipeBitLoop
                RET
;----END (Get pipe bit)


		
		
Public		Control_Read
Public		FIFO0_RD_CHECK
Public		FIFO1_RD_CHECK
Public		FIFO2_RD_CHECK
Public		FIFO3_RD_CHECK
Public		FIFO4_RD_CHECK
Public		FIFO5_RD_CHECK
Public		FIFO0_WR_CHECK
Public		FIFO1_WR_CHECK
Public		FIFO2_WR_CHECK
Public		FIFO3_WR_CHECK
Public		FIFO4_WR_CHECK
Public		FIFO5_WR_CHECK
Public		Read_FIFO0
Public		Read_FIFO1
Public		Read_FIFO2
Public		Read_FIFO3
Public		Read_FIFO4
Public		Read_FIFO5
Public		Write_FIFO0
Public		Write_FIFO1
Public		Write_FIFO2
Public		Write_FIFO3
Public		Write_FIFO4
Public		Write_FIFO5
Public		Send_Hand_Shake
Public		get_descriptor_length



Public		SetAddress
Public		SetConfiguration
Public		SetInterface
Public		GetInterface
Public		GetDescriptor
Public		SetIdle
Public		GetDeviceDescriptor
Public		GetConfigurationDescriptor
Public		GetStringDescriptor
Public		GetStatus
;modify for Remote Wakeup
Public		GetStatus_Interface
;---------------------------------
Public		SetFeature
Public		ClearFeature
Public		SetFeature_Endpoint
Public		ClearFeature_Endpoint
Public		GetStatus_Endpoint

Public		SetReport

Public		Check_Real_Cmd

Public		Execute
Public		SendStall0

Public		GetConfiguration

Public		Delay_3us


Public		SetCur
Public		GetMin
Public		GetMax
Public		GetRes
Public		GetCur
Public		GetPipeBit
