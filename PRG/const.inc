;****************************************************************
;Author:Ansonku
;Email:ansonku@holtek.com.tw
;================================================================
;Update Information
;================================================================
;2004/09/27
;define register for usb audio speaker chip
;the usb chip register are all at bank0
;
;****************************************************************


USB_REG_BANK	EQU	0


;R0		EQU	[00H]
;MP0		EQU	[01H]
;R1		EQU	[02H]
;MP1		EQU	[03H]

;ACC		EQU	[05H]
;PCL		EQU	[06H]
;TBLP		EQU	[07H]
;TBLH		EQU	[08H]

;STATUS		EQU	[0AH]
;INTC0		EQU	[0BH]

;TMR0		EQU	[0DH]
;TMR0C		EQU	[0EH]
;TMR1H		EQU	[0FH]
;TMR1L		EQU	[10H]
;TMR1C		EQU	[11H]
;PA		EQU	[12H]
;PAC		EQU	[13H]
;PB		EQU	[14H]
;PBC		EQU	[15H]
;PC		EQU	[16H]
;PCC		EQU	[17H]
;PD		EQU	[18H]
;PDC		EQU	[19H]
;PE		EQU	[1AH]
;PEC		EQU	[1BH]

;INTC1		EQU	[1EH]

EP0_FIFO_SIZE	EQU	8

USB_FIFO0_SIZE	EQU	8
USB_FIFO1_SIZE	EQU	8
USB_FIFO2_SIZE	EQU	8
USB_FIFO3_SIZE	EQU	8
USB_FIFO4_SIZE	EQU	8
USB_FIFO5_SIZE	EQU	8



USB_USC		EQU	020H
USB_USR		EQU	021H
USB_UCC		EQU	022H
USB_AWR		EQU	023H
USB_STALL	EQU	024H
USB_SIES	EQU	025H
USB_MISC	EQU	026H
USB_SETIO	EQU	027H
USB_FIFO0	EQU	028H
USB_FIFO1	EQU	029H
USB_FIFO2	EQU	02AH
USB_FIFO3	EQU	02BH
USB_FIFO4	EQU	02CH
USB_FIFO5	EQU	02DH


;bit position define
@BIT0		EQU	0
@BIT1		EQU	1
@BIT2		EQU	2
@BIT3		EQU	3
@BIT4		EQU	4
@BIT5		EQU	5
@BIT6		EQU	6
@BIT7		EQU	7

;INTC0
@INTC0_EMI	EQU	@BIT0
@INTC0_EEI	EQU	@BIT1
@INTC0_ET0I	EQU	@BIT2
@INTC0_ET1I	EQU	@BIT3
@INTC0_EIF	EQU	@BIT4
@INTC0_T0F	EQU	@BIT5
@INTC0_T1F	EQU	@BIT6

;INTC1
@INTC1_EUI	EQU	@BIT0
@INTC1_EADI	EQU	@BIT1
@INTC1_ESII	EQU	@BIT2
@INTC1_USBF	EQU	@BIT4
@INTC1_ADF	EQU	@BIT5
@INTC1_SIF	EQU	@BIT6

;USC
@USC_SUSP	EQU	@BIT0
@USC_RMWK	EQU	@BIT1
@USC_URST	EQU	@BIT2
@USC_RESUME	EQU	@BIT3
@USC_V33C	EQU	@BIT4
@USC_URD	EQU	@BIT7

;USR
@USR_EP0F	EQU	@BIT0
@USR_EP1F	EQU	@BIT1
@USR_EP2F	EQU	@BIT2
@USR_EP3F	EQU	@BIT3
@USR_EP4F	EQU	@BIT4
@USR_EP5F	EQU	@BIT5


;UCC  [20H]
@UCC_EPS0	EQU	@BIT0
@UCC_EPS1	EQU	@BIT1
@UCC_EPS2	EQU	@BIT2
@UCC_USBCKEN	EQU	@BIT3
@UCC_SUSP2	EQU	@BIT4
@UCC_SYSCLK	EQU	@BIT6
@UCC_UFLS	EQU	@BIT7

;AWR
@AWR_WKEN	EQU	@BIT0

;STALL
@STALL_STL0	EQU	@BIT0
@STALL_STL1	EQU	@BIT1
@STALL_STL2	EQU	@BIT2
@STALL_STL3	EQU	@BIT3
@STALL_STL4	EQU	@BIT4
@STALL_STL5	EQU	@BIT5

;SIES
@SIES_ASET	EQU	@BIT0
@SIES_ERR	EQU	@BIT1
@SIES_OUT	EQU	@BIT2
@SIES_IN	EQU	@BIT3
@SIES_NAK	EQU	@BIT4
@SIES_SETUP	EQU	@BIT5

;MISC
@MISC_REQ	EQU	@BIT0
@MISC_TX	EQU	@BIT1
@MISC_CLEAR	EQU	@BIT2
@MISC_ISOEN	EQU	@BIT4
@MISC_SCMD	EQU	@BIT5
@MISC_READY	EQU	@BIT6
@MISC_LEN0	EQU	@BIT7

;SETIO
@SETIO_DATATG	EQU	@BIT0
@SETIO_SETIO1	EQU	@BIT1
@SETIO_SETIO2	EQU	@BIT2
@SETIO_SETIO3	EQU	@BIT3
@SETIO_SETIO4	EQU	@BIT4
@SETIO_SETIO5	EQU	@BIT5

;
;===================================================
;Descriptor constant declarations
;===================================================
;Standard Request Codes
get_status		EQU	0
clear_feature		EQU	1
set_feature		EQU	3
set_address		EQU	5
get_descriptor		EQU	6
set_descriptor		EQU	7
get_configuration	EQU	8
set_configuration	EQU	9
get_interface		EQU	10
set_interface		EQU	11
synch_frame		EQU	12

;Standard Descriptor types
device			EQU	1
configuration		EQU	2
string			EQU	3
interface		EQU	4
endpoint		EQU	5

;Standard Feature Selectors
endpoint_stalled	EQU	0
device_remote_wakeup	EQU	1

;HID class
HID			EQU	21H
report			EQU	22H
physical		EQU	23H

;calss specific request code from section 7.2 class specific requests
get_report		EQU	1
get_idle		EQU	2
get_protocol		EQU	3
set_report		EQU	09
set_idle		EQU	10
set_protocol		EQU	11

set_input_report	EQU	1	
set_output_report	EQU	2

;===================================================
;USB packet constants (debug purposes)
;===================================================
setup			EQU	0B4H
in			EQU	096H
out			EQU	087H
data0			EQU	0C3H
data1			EQU	0D2H
ack			EQU	04BH
nak			EQU	04AH
;===================================================
;USB Audio Class-Specific Request Code
;===================================================
REQUEST_CODE_UNDEFINED	EQU	000H
SET_CUR			EQU	001H
GET_CUR			EQU	081H
SET_MIN			EQU	002H
GET_MIN			EQU	082H
SET_MAX			EQU	003H
GET_MAX			EQU	083H
SET_RES			EQU	004H
GET_RES			EQU	084H
SET_MEM			EQU	005H
GET_MEM			EQU	085H
GET_STAT		EQU	0FFH

;Feature Unit Control Selectors
FU_CONTROL_UNDEFINED	EQU	000H
MUTE_CONTROL		EQU	001H
VOLUME_CONTROL		EQU	002H
BASS_CONTROL		EQU	003H
MID_CONTROL		EQU	004H
TREBLE_CONTROL		EQU	005H
GRAPHIC_EQUALIZER_CONTROL	EQU	006H
AUTOMATIC_GAIN_CONTROL	EQU	007H
DELAY_CONTROL		EQU	008H
BASS_BOOST_CONTROL	EQU	009H
LOUNDNESS_CONTROL	EQU	00AH


;//just for HT23RB60 RAM bank
ABank0			EQU	000H
ABank1			EQU	001H
ABank2			EQU	002H
ABank3			EQU	003H
ABank4			EQU	004H
ABank5			EQU	005H
ABank6			EQU	006H
ABank7			EQU	007H
ABank8			EQU	008H
ABank9			EQU	009H
ABankA			EQU	00aH
ABankB			EQU	00bH
;//just for HT23RB60 ROM bank
OBank0			EQU	000H
OBank1			EQU	020H
OBank2			EQU	040H
OBank3			EQU	060H


;for HT16A102B 68k Parallel Mode
OLCD_DATA_PIN	EQU	PA
C68		EQU	PB.0
RD		EQU	PB.1
RW		EQU	PB.2
DCOM		EQU	PB.3
RES		EQU	PB.4


;for volume control 
Const_Counter	EQU	00AH

VIOP		EQU	[12H]
@Mute		EQU	@BIT6
@Inc		EQU	@BIT4
@Dec		EQU	@BIT5

Min_Volume	EQU	0C8H
Max_Volume	EQU	000H
;//Max_Volume	EQU	000H
Cur_Volume	EQU	0FCH




;=============================================================
;  IF USE key Debounced Function please set UseMedaiKey = 1
;  Key_Defined represent which bit you want to detect
;  For Example : I want to detect PA.0  and PA.1
;		 Then I set Key_Defined to 00000011'b = 03H
;=============================================================
#define		UseMediaKey	0
#define		UseReportID	0	;des is changed usereport has problem
Key_Defined	EQU	0FFH

USB_LED_ON	EQU	PB.0
MUTE_LED_ON	EQU	PB.1
