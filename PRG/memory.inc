;;***********************************************
;;QN8072 memory
;;***********************************************
mQNReg		db	5 dup (?)	;;QN8072 Reg0~4

mFMAddr		db	?		;;QN8072 Reg addr
mFMData		db	?		;;QN8072 Reg data
mFreqL		db	?		;;QN8072 Freq
mFreqH		db	?

mFMACK		db	?		;;IIC ACK get OK?
mFMSend		db	?		;;IIC Send data
mFMCnt		db	?		;;IIC Send count

;;***********************************************
;;Temp
;;***********************************************
mMK0		db	?
mMK1		db	?

;;***********************************************
;;BIT
;;***********************************************
bIniFMOK	dbit			;;0-FM initial no. 1-FM initial OK

;;***********************************************
;;IO Define
;;***********************************************
P_LEDC		EQU	[013H].3
P_LED		EQU	PA.3
P_SCLC		EQU	[013H].0
P_SCL		EQU	PA.0
P_SDAC		EQU	[013H].1
P_SDA		EQU	PA.1

;;***********************************************
;;User Define
;;***********************************************
cFreqDefL		EQU	18H
cFreqDefH		EQU	01H		;;QN8072 define freq : 90.00MHz (Chanel = (Freq-76)/0.05)

QN8072_I2C_WRITE_ADDR	EQU	58H		;;QN8072 Write address
QN8072_I2C_READ_ADDR	EQU	59H		;;QN8072 Read address

;;***********************************************
;;USB Translate Define
;;***********************************************
cFMUSBType_Main		EQU	50H		;;USB Data is main data
cFMUSBType_Set		EQU	51H		;;USB Data is Set data

  @FMKeyOn		EQU	0		;;FM On
  @FMKeyOff		EQU	1		;;FM Off
  @FMKeyMute		EQU	2		;;FM Mute
  @FMKeyNoMute		EQU	3		;;FM NoMute
  @FMKeyTun		EQU	4		;;FM Tun(add/dec)
  
  @FMMono		EQU	0		;;FM Stereo(0)/mono(1)
  @FMFreq		EQU	1		;;FM freq 87.5~108M(0)/76~90(1)
  @FMDeemp		EQU	2		;;FM De-emphasis 50(0)/75(1)
  
