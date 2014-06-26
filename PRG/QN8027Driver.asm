;;-----------------------------------------------
;;function:	QN8072_I2C_Read_Data
;;in:		mFMAddr
;;out:		mFMData
;;description:	Read AS6600 data
;;-----------------------------------------------
QN8072_I2C_Read_Data:

L_I2CRd_Data_lp:
	CLR	WDT
		
	CLR	mFMACK
	CALL	I2C_START
	MOV	A,QN8072_I2C_WRITE_ADDR
	MOV	mFMSend,A		;;Set send data
	CALL	Write_I2C_Byte		;;Send data
	
	MOV	A,mFMAddr
	MOV	mFMSend,A
	CALL	Write_I2C_Byte
	
	MOV	A,mFMACK
	OR	A,0
	SNZ	Z			;;Z=1,OK
	JMP	L_I2CRd_Data_lp
;;	
L_I2CRd_Data_lp2:
	CLR	WDT
	
	CLR	mFMACK
	CALL	I2C_START
	
	MOV	A,QN8072_I2C_READ_ADDR
	MOV	mFMSend,A		;;Set send data
	CALL	Write_I2C_Byte		;;Send data
	
	MOV	A,mFMACK
	OR	A,0
	SNZ	Z			;;Z=1,OK
	JMP	L_I2CRd_Data_lp2
	
	CALL	Read_I2C_Byte
	MOV	mFMData,A
	CALL	sendNoAck
	
	CALL	I2C_STOP
	RET	
	
;;-----------------------------------------------
;;function:	QN8027_I2C_Write_Data
;;in:		mFMAddr,mFMData
;;out:		
;;description:	Write QN8027 data
;;-----------------------------------------------	
QN8027_I2C_Write_Data:

L_I2CWt_Data_lp:
	CLR	WDT
		
	CLR	mFMACK
	CALL	I2C_START
	MOV	A,QN8072_I2C_WRITE_ADDR
	MOV	mFMSend,A		;;Set send data
	CALL	Write_I2C_Byte		;;Send data
	
	MOV	A,mFMAddr
	MOV	mFMSend,A
	CALL	Write_I2C_Byte
	
	MOV	A,mFMData
	MOV	mFMSend,A
	CALL	Write_I2C_Byte
	
	CALL	I2C_STOP
	
	MOV	A,mFMACK
	OR	A,0
	SNZ	Z			;;Z=1,OK
	JMP	L_I2CWt_Data_lp
	
	RET

;;-----------------------------------------------
;;function:	Delay5us
;;in:		NULL
;;out:		NULL
;;description:	Delay 5us
;;-----------------------------------------------
Delay5us:
	JMP	$+1
	JMP	$+1
	JMP	$+1
	JMP	$+1
	JMP	$+1
	JMP	$+1
	JMP	$+1
	NOP
	RET
	
;;-----------------------------------------------
;;function:	sendAck
;;in:		NULL
;;out:		NULL
;;description:	Send ACK
;;-----------------------------------------------
sendAck:
	CLR	P_SDA			;;0
	CALL	Delay5us
	
	SET	P_SCL
	CALL	Delay5us
	CLR	P_SCL
	CALL	Delay5us
	RET
	
;;-----------------------------------------------
;;function:	sendNoAck
;;in:		NULL
;;out:		NULL
;;description:	Send No ACK
;;-----------------------------------------------
sendNoAck:
	SET	P_SDA			;;1
	CALL	Delay5us
	
	SET	P_SCL
	CALL	Delay5us
	CLR	P_SCL
	CALL	Delay5us
	RET

;;-----------------------------------------------
;;function:	Read_I2C_Byte
;;in:		NULL
;;out:		ACC
;;description:	Read data
;;-----------------------------------------------
Read_I2C_Byte:
	CLR	mFMSend
	MOV	A,8D
	MOV	mFMCnt,A
	
	SET	P_SDAC		;;SDA input
L_ReadI2C_lp:
	CLR	C
	RLC	mFMSend

	CLR	P_SCL
	CALL	Delay5us
	SET	P_SCL
	CALL	Delay5us
	
	SZ	P_SDA
	SET	mFMSend.0	;;save data
	
	SDZ	mFMCnt
	JMP	L_ReadI2C_lp
	
	CLR	P_SCL
	CLR	P_SDAC		;;SDA Output
	CALL	Delay5us
	
	MOV	A,mFMSend
	RET
	
;;-----------------------------------------------
;;function:	Write_I2C_Byte
;;in:		mFMSend
;;out:		mFMAck
;;description:	Write data
;;-----------------------------------------------
Write_I2C_Byte:
	MOV	A,8D
	MOV	mFMCnt,A
	
L_WriteI2C_lp:
	SZ	mFMSend.7
	SET	P_SDA
	SNZ	mFMSend.7
	CLR	P_SDA
	
	RLC	mFMSend			;;Next bit
	
	CALL	Delay5us
	SET	P_SCL
	CALL	Delay5us
	CLR	P_SCL
	
	SDZ	mFMCnt
	JMP	L_WriteI2C_lp		;;Send data
	
	;;Get ACK
	CALL	Delay5us
	SET	P_SDAC			;;SDA input
	CALL	Delay5us
	SET	P_SCL
	CALL	Delay5us
	SZ	P_SDA
	INC	mFMACK			;;ACK=1,error
	
	CLR	P_SCL
	CALL	Delay5us
	CLR	P_SDAC			;;SDA output
	RET
	
;;-----------------------------------------------
;;function:	I2C_START
;;in:		NULL
;;out:		NULL
;;description:	IIC Start
;;-----------------------------------------------
I2C_START:
	SET	P_SDA		;;Dat H
	CALL	Delay5us
	SET	P_SCL		;;CLK H
	CALL	Delay5us
	CLR	P_SDA		;;Dat L
	CALL	Delay5us
	CLR	P_SCL		;;CLK L
	CALL	Delay5us
	RET

;;-----------------------------------------------
;;function:	I2C_Stop
;;in:		NULL
;;out:		NULL
;;description:	IIC Stop
;;-----------------------------------------------
I2C_Stop:
	CLR	P_SDA		;;Dat L
	CALL	Delay5us
	SET	P_SCL		;;CLK L
	CALL	Delay5us
	SET	P_SDA		;;Dat H
	CALL	Delay5us
	RET
	
