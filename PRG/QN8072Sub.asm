;;-----------------------------------------------
;;function:	QN8072Init
;;in:		mFreqL,mFreqH
;;out:		NULL
;;description:	Initial QN8027 Configer
;;-----------------------------------------------
QN8072Init:
;;
	MOV	A,03H
	MOV	mFMAddr,a			;;crystal
	MOV	A,mQNReg[3]			;;50H
	MOV	mFMData,A			;;digital clock for XTAL1
	CALL	QN8027_I2C_Write_Data
;;
	MOV	A,04H
	MOV	mFMAddr,a			;;VGA
	MOV	A,mQNReg[4]			;;58H
	MOV	mFMData,A			;;12M/101/2db/5k
	CALL	QN8027_I2C_Write_Data
	
	CALL	Delay20ms
;;	
	MOV	A,00H
	MOV	mFMAddr,a			;;SYSTEM
	MOV	A,mQNReg[0]			;;51H
	MOV	mFMData,A			;;MONO/NO MUTE
	CALL	QN8027_I2C_Write_Data
	
	CALL	Delay20ms
;;
	CLR	mQNReg[0].6
	MOV	A,00H
	MOV	mFMAddr,a			;;SYSTEM
	MOV	A,mQNReg[0]			;;51H
	MOV	mFMData,A			;;MONO/NO MUTE
	CALL	QN8027_I2C_Write_Data
	
	MOV	A,18H
	MOV	mFMAddr,A
	MOV	A,0E4H
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	MOV	A,1bH
	MOV	mFMAddr,A
	MOV	A,0f0H
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	SET	mQNReg[0].5			;;Enter transmit mode
	CALL	QN8072FreqSet			;;Set fre
	
	MOV	A,02H
	MOV	mFMAddr,A
	MOV	A,0e9H
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	MOV	A,04H
	MOV	mFMAddr,A
	MOV	A,42H
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	RET
	
;;-----------------------------------------------
;;function:	QN8072FreqSet
;;in:		mFreqL,mFreqH
;;out:		NULL
;;description:	Set QN8072 Freq
;;		Frf = (76 + 0.05*Channel) -> Channel = (Frf-76)/0.05
;;-----------------------------------------------	
QN8072FreqSet:
;;	CLR	INTC0.@INTC0_EMI		;Global interrupt
;;	CLR	data0
;;	CLR	data1
;;	
;;	MOV	A,mFreqL
;;	SUB	A,0B0H
;;	MOV	data0,A
;;	MOV	A,mFreqH
;;	SBC	A,1DH
;;	MOV	data1,A				;;(Freq - 7600)
;;	
;;	MOV	A,05H
;;	MOV	data5,A
;;	CLR	data4
;;	CALL	unbin_div_16			;;(Freq - 7600)/5 -> to1to0
;;	
;;	MOV	A,03H
;;	ANDM	A,to1
;;	MOV	A,0FCH
;;	ANDM	A,mQNReg[0]
;;	MOV	A,to1
;;	ORM	A,mQNReg[0]
;;	MOV	A,to0
;;	MOV	mQNReg[1],A
;;	

	MOV	A,cFreqDefL
	MOV	mQNReg[1],A
	MOV	A,mQNReg[0]
	AND	A,0FCH
	OR	A,cFreqDefH
	MOV	mQNReg[0],A			;;Set define freq

	MOV	A,00H
	MOV	mFMAddr,A
	MOV	A,mQNReg[0]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	MOV	A,01H
	MOV	mFMAddr,A
	MOV	A,mQNReg[1]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
;;	SET	INTC0.@INTC0_EMI		;Global interrupt
	RET

;;-----------------------------------------------
;;function:	Delay20ms
;;in:		NULL
;;out:		NULL
;;description:	Delay 20ms
;;-----------------------------------------------	
Delay20ms:
	MOV	A,200D
	MOV	mMK1,A

L_Dly20ms_1:
	MOV	A,100D
	MOV	mMK0,A
	CLR	WDT

	SDZ	mMK0
	JMP	$-1
	NOP					;;3*100 = 100us
	
	SDZ	mMK1
	JMP	L_Dly20ms_1
	
	RET

;;-----------------------------------------------
;;function:	QN8027
;;in:		FIFO_out1~FIFO_out8
;;out:		NULL
;;description:	deal QN8027 Data from EP1
;;-----------------------------------------------	
QN8027:	
	;;Type check (main or set)
	MOV	A,cFMUSBType_Main
	XOR	A,FIFO_out2
	SZ	Z
	JMP	L_FMType_Main			;;Main data
	
	MOV	A,cFMUSBType_Set
	XOR	A,FIFO_out2
	SZ	Z
	JMP	L_FMType_Set			;;Set data
	JMP	L_QN8027_end
	
;;-----------------------------------------------
L_FMType_Main:		
	;;FIFO6 is Key
	SZ	FIFO_out6.@FMKeyTun
	CALL	L_FMFun_FMFreSet

	SZ	FIFO_out6.@FMKeyOn
	CALL	L_FMFun_FMWork

	SZ	FIFO_out6.@FMKeyOff
	CALL	L_FMFun_FMIdle

	SZ	FIFO_out6.@FMKeyMute
	CALL	L_FMFun_FMMute

	SZ	FIFO_out6.@FMKeyNoMute
	CALL	L_FMFun_FMNoMute
	
	;;FIFO5 is PAC-VALUE(0x10)
	SNZ	mQNReg[0].5
	JMP	L_QN8027_end		;;Idle mode
	
	MOV	A,FIFO_out5
	MOV	mFMData,A
	MOV	A,10H
	MOV	mFMAddr,A
	CALL	QN8027_I2C_Write_Data
	
	;;In idle and work for PA-ok
;;	CALL	L_FMFun_FMMute		;;Mute
;;	CALL	L_FMFun_FMIdle
;;	CALL	L_FMFun_FMWork
;;	SZ	FIFO_out6.@FMKeyNoMute
;;	CALL	L_FMFun_FMNoMute
	JMP	L_QN8027_end
	
;;
L_FMFun_FMNoMute:
	CLR	mQNReg[0].3		;;Not mute
	JMP	$+2	
L_FMFun_FMMute:
	SET	mQNReg[0].3
	
	MOV	A,00H
	MOV	mFMAddr,A
	MOV	A,mQNReg[0]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data	;;Set Mute/No Mute
;;	JMP	L_QN8027_end
	RET
	
;;
L_FMFun_FMIdle:
	SET	P_LED
	CLR	mQNReg[0].5		;;Idle mode
	JMP	$+3
L_FMFun_FMWork:
	CLR	P_LED
	SET	mQNReg[0].5		;;Work mode
	
	MOV	A,00H
	MOV	mFMAddr,A
	MOV	A,mQNReg[0]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data	;;Set Idle/Work
;;	JMP	L_QN8027_end
	RET

;;
L_FMFun_FMFreSet:	
	;;FIFO3/4 is Freq
	MOV	A,FIFO_out4
	MOV	mQNReg[1],A
	MOV	A,0FCH
	ANDM	A,mQNReg[0]
	MOV	A,FIFO_out3
	AND	A,03H
	ORM	A,mQNReg[0]	

	MOV	A,00H
	MOV	mFMAddr,A
	MOV	A,mQNReg[0]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
	
	MOV	A,01H
	MOV	mFMAddr,A
	MOV	A,mQNReg[1]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data
;;	JMP	L_QN8027_end
	RET

;;-----------------------------------------------
L_FMType_Set:
	;;FIFO_out3 is TX-GAIN
	MOV	A,mQNReg[4]
	AND	A,8CH			;;Set GVGA & RIN(GVGA = 000/RIN=11 --> GVGA=101/RIN=11 --> GVGA=000/RIN=10 --> GVGA=101/RIN=0)
	OR	A,FIFO_out3
	MOV	mQNReg[4],A
	
	MOV	A,04H
	MOV	mFMAddr,A
	MOV	A,mQNReg[4]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data	;;Set TX-GAIN
	
	;;Set other
	CLR	mQNReg[0].4
	SZ	FIFO_out4.@FMMono
	SET	mQNReg[0].4
	
	CLR	mQNReg[2].7
	SZ	FIFO_out4.@FMDeemp
	SET	mQNReg[2].7
	
	MOV	A,00H
	MOV	mFMAddr,A
	MOV	A,mQNReg[0]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data	;;FM Mono
	
	MOV	A,02H
	MOV	mFMAddr,A
	MOV	A,mQNReg[2]
	MOV	mFMData,A
	CALL	QN8027_I2C_Write_Data	;;FM De-emp
	;;JMP	L_QN8027_end
	
	
L_QN8027_end:
	RET
	
