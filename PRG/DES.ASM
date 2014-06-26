;====================================================================
;	ROM Size     , HT82A821R = 2K	, last page = 0700H
;		       HT82A822R = 4K	, last page = 0F00H
;	If use HT82A821R
;		       #defined HT82A821R 1
;		       #defined HT82A822R 0
;	If use HT82A822R
;		       #defined HT82A821R 0
;		       #defined HT82A822R 1
;====================================================================
;	Use ReportID , Report ID 1 = Volume HID control
;		       Report ID 2 = Transform Other Data
;====================================================================

#include		ht82a821r.inc
#include		const.inc
#define		HT82A821R	1
#define		HT82A822R	0

IF	HT82A821R
Descript		.Section   at   0700h		'code'
ENDIF


IF	HT82A822R
Descript		.Section   at   0F00h		'code'
ENDIF



control_read_table:
	device_desc_table:
		DW	00112H	;descriptor type (device descriptor) , size of descriptor (18 bytes)
		DW	00110H	;USB spec release (ver 1.1)
		DW	00000H	;device sub-class , device class
		DW	00800H	;maximum packet size , device sub-sub-class
		DW  	0046DH  ;vender ID = 004D9H
		DW	03F0EH
		DW	03F0AH	;product ID (Sample Device) = 0x2821		
		DW	00100H	;product version ID
		DW	00201H	;product string index (device show) , manufacturer string index
		DW	00100H	;number of configurations
	config_desc_table:
		DW	00209H	;descriptor type (config descriptor) , size of descriptor
		DW	00087H	;total length of descriptor (34 bytes)
		DW	00103H	;1 configuration , 3 interface
		DW	03F00H	;configuration string index
		DW	03FA0H	;configuration attributes (bus supply), Remote Wakeup
		DW	03FFAH	;maxpower (500ma)
	Interface_Descriptor:
	    Interface0_descriptor:
	    standard_audio_control_interface_control:
		DW	00409H	;descriptor type (interface descriptor) , size of descriptor (9 bytes)
		DW	00000H	;interface alternate setting , interface number (0 base)
		DW	00100H	;interface class(01H for audio class) , number of endpoint (1 end point)
		DW	00001H	;interface protocol , interface sub-class (audio control)
		DW	03F00H	;x , interface string index
	    class_specific_audio_control_interface_descriptor:
	    	DW	02409H	;descriptor type (CS_INTERFACE) , size of descriptor (9 bytes)
	    	DW	03F01H	;descriptor subtype (Header)
	    	DW	00100H	;audio device class specification release number(1.00)
	    	DW	00028H	;total number of bytes for the class-specific audiocontrol interface descriptor
	    	DW	00101H	;streaming interface number belongs to audio control interface , the number of streaming interface
	    input_terminal:
	    	DW	0240CH	;descriptor type(CS_INTERFACE) , size of descriptor
	    	DW	00102H	;ID of this terminal(ID=1) , descriptor subtype(INPUT_TERMINAL)
	    	DW	00101H	;terminal type(USB streaming type)
	    	DW	00200H	;number of channel(two channel) , associate with output terminal
	    	DW	00003H	;channel config(Left/Right Front)
	    	DW	00000H	;channelname(unused) , terminal name(unused)
	    feature_unit:
	    	DW	0240AH	;descriptor type(CS_INTERFACE) , size of descriptor(10 bytes)
	    	DW	00D06H	;UnitID , descriptorSubtype(FEATURE_UNIT)
	    	DW	00101H	;control size(1) , SourceID(input terminal 01)
	    	DW	00003H	;D1(volume)control is enable foe channel 1 , D0(mute) D1(volume) is enable for channel 0
	    	DW	00000H	;index of this descriptor , D1(volume)control is enable for channel 2
	    output_terminal:
	    	DW	02409H	;descriptor type(CS_INTERFACE) , size of descriptor(9 bytes)
	    	DW	00303H	;terminal ID(03) , descriptorsubtype(OUTPUT_TERMINAL)
	    	DW	00301H	;terminal is speaker
	    	DW	00D00H	;sourceID(feature unit ID=0D) , associate terminal
	    	DW	03F00H	;index of this descriptor
	    Interface1_descriptor:
	    zero_bw:
	    	DW	00409H	;descriptor type(INTERFACE) , sizoe of descriptor
	    	DW	00001H	;index of ths setting(alternatesetting = 0) , index of this interface
	    	DW	00100H	;interface-class(AUDIO) , number of endpoint(0)
	    	DW	00002H	;interface protocol(unused) , InterfaceSubClass(AUDIO_STREAMING)
	    	DW	03F00H	;index string of this descriptor
	    audio_streaming:
	    	DW	00409H	;descriptor type(INTERFACE) , size of descriptor
	    	DW	00101H	;index of the setting(alternatesetting = 1) ,index of this interface
	    	DW	00101H	;interface-class(AUDIO) , number of endpoint(1)
	    	DW	00002H	;interface protocol(unused) , InterfaceSubClass(AUDIO_STREAMING)
	    	DW	03F00H	;index string of this descriptor
	    class_specific_as_interface_desc:
	    	DW	02407H	;descriptor type(CS_INTERFACE) , size of descriptor
	    	DW	00101H	;terminalLink(Input terminal) , descriptor subtype(AS_GENERAL)
	    	DW	03F01H	;interface delay(1)
	    	DW	00001H	;PCM format
	    format_type_descriptor:
	    	DW	0240BH	;descriptor type(CS_INTERFACE) , size of descriptor
	    	DW	00102H	;FormatType(FORMAT_TYPE_I) , descriptorSubType(FORMAT_TYPE)
	    	DW	00202H	;SubFrameSize(2 byte per slot) , number of channel(2 channels)
	    	DW	00110H	;SamFreqType(support 1 type) , BitSolution(16 bits)
	    	DW	03F80H	;Sample Frequency(48000 Hz)
	    	DW	000BBH	;
	    end_point_descriptor:
	    	DW	00509H	;descriptor type(END_POINT) , size of descriptor
	    	DW	00902H	;endpoint attributes(adaptive,isochronous) , endpoint2(out direction)
	    	DW	000C0H	;maxPacketSize(192 bytes)
	    	DW	00001H	;Refresh(0) , Interval(1ms)
	    	DW	03F00H	;index string of this descriptor
	    class_specific_endpoint_descriptor:
	    	DW	02507H	;descriptor type(CS_ENDPOINT) , size of descriptor
	    	DW	00001H	;Attributes(no sampling frequency , no pitch , no maxpackets control) , descriptorType(EP_GENERAL)
	    	DW	03F00H	;LockedDelayUnit(unused)
	    	DW	00000H	;LockDelay(unused)
	    Interface2_descriptor:
	    HID_class:
	    	DW	00409H	;INTERFACE descriptor , Size of this descriptor
	    	DW	00002H	;Index of this string , index of this interface
	    	DW	00301H	;HID , 1 endpoint
	    	DW	00000H	;Unused , Non-Boot Device
	    	DW	03F00H	;null string
	    HID_Desc:
	    	DW	02109H	;HID , Size of this descriptor
	    	DW	00110H	;HID spec rev #1.10
	    	DW	00100H	;bNumDescriptor , bCountryCode
	    	DW	03F22H	;Report Descriptor
	    	;====================================================================
	    	;	Use ReportID , Report ID 1 = Volume HID control
	    	;		       Report ID 2 = Transform Other Data
	    	;====================================================================
	    	IF	UseReportID
	    	DW	00016H	;67 bytes
			ELSE
			DW	00016H	
			ENDIF

	    HID_end_point_descriptor:
	    	DW	00507H	;Endpoint descriptor , Length of this descriptor
	    	DW	00381H	;Interrupt , Endpoint 1 In direction
	    	DW	00008H	;wMaxPacketSize = 1 Bytes
	    	DW	03F30H	;48ms Interval
	end_config_desc_table:

	hid_report_desc_table:
;====================================================================
;	Use ReportID , Report ID 1 = Volume HID control
;		       Report ID 2 = Transform Other Data
;====================================================================		
		;;vender defined
		DW	03F06H		;//Usage Page(Global)
		DW	03F00H
		DW	03FFFH		;//Usage Page

		DW	00109H		;//Usage(Local 1 bytes)
		DW	001A1H		;//collection(Main)
		;input report
;;		DW	03F19H
;;		DW	03FA6H
;;		DW	03F29H		;//Usage(Local)
;;		DW	03FACH
;;		DW	03F15H		;//Global Logical Minimum
;;		DW	03F80H
;;		DW	03F25H		;//Global Logical Maximum
;;		DW	03F7FH		
;;		DW	00875H		;//Global Report Size 8 bits
;;		DW	00795H		;//Global Report Count 7 (field)
;;		DW	00281H		;//Main Input (Data,Variable,Absolute)
		;output
		DW	00015H		;//LOGICAL MINIMUM (0)
		DW	03F25H
		DW	03FffH		;//LOGICAL MAXIMUM (FF)
		DW	00019H		;//Usage Min (#)
		DW	00129H		;//Usage Max (#)
		DW	00895H		;//Report Count(8)
		DW	00875H		;//Report Size(8)
		DW	00291H		;//OUTPUT: (Data, Array)
		DW	03FC0H		;End Collection
	end_hid_report_desc_table:	

	string_descriptor:
	USBStringLanguageDescription:
	    	DW 	00304h          ; Length , Type (3=string)
    		DW 	00409h          ; Language:  English , Sub-language: US
	
	imanufacturer_string:	;Vendor Name
	USBStringDescription1:	
		DW	00310h, 00048h, 0004fh, 0004ch, 00054h, 00045h, 0004bh, 00020h	;HOLTEK		
	
	iproduct_string:	;Product Name
	USBStringDescription2:	
		;DW	00326h, 00042h, 0002Dh, 0004ch, 00049h, 0004Eh, 0004bh, 00020h	;B-LINK
		DW	00055h, 00053h, 00042h, 00020h					;USB
		DW	00041h, 00075h, 00064h, 00069h, 0006fh, 00020h, 00020h		;Audio
	
	isnumber_string:	;Serial Number
	USBStringDescription3:	
		DW	0030Ah, 00038h,	00032h, 00031h, 00052h	;821R



	config_desc_length:
		DW	00087H

	report_desc_length:
		IF	UseReportID
		DW	00016H
		ELSE
		DW	00016H
		ENDIF
	hid_desc_length:
		DW	00009H



	 Public		control_read_table
	 Public		device_desc_table
	 Public		config_desc_table
	 Public		end_config_desc_table
	 Public		USBStringLanguageDescription
	 Public		USBStringDescription1
	 Public		USBStringDescription2
	 Public		USBStringDescription3
	 
	 Public		HID_Desc
	 Public		hid_report_desc_table
	 Public		end_hid_report_desc_table
	 
	 
	 Public		config_desc_length
	 Public		hid_desc_length
	 Public		report_desc_length

