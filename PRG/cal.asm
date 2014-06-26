;8 bit unsigned mul  
unbin_mul_8 proc		;data0*data4---->to1to0 
	init
	mov	a, 08h
	mov	count0, a      
rradd:
	rrc	to1
        rrc	data4
        snz	[0ah].0   
        jmp	rr1		;当前data4.0=0,移位
        mov	a, data0	;当前data4.0=1,移位相加
        addm	a, to1    
rr1:
	sdz	count0
        jmp	rradd    
        rrc	to1
        rrc	data4
        mov	a, data4
        mov	to0, a
	ret
unbin_mul_8 endp


;8 bit unsigned div
unbin_div_8 proc           	;data0/data4---->data0(to0)---to1  
	init
        mov	a, 08h		;循环次数8
        mov	count0, a 
 
        sz	data4		;除数为0则溢出
        jmp	start0
        jmp	over8
start0: 
	sz	data0		;被除数为0则结束
        jmp	div0
        jmp	dispa
div0:   
	clr	[0Ah].0		;准备左移   
        rlc	data0
        rlc	to1		;左移一位结束
        mov	a, to1		;开始部分余数减除数
        sub	a, data4
        snz	[0Ah].0        
        jmp	next0		;不够减则转移
        mov	to1, a		;够减则商为1
        inc	data0
next0:
	sdz	count0
        jmp	div0
dispa:  
	mov	a, data0	;显示商
        mov	to0, a                  
;;	mov	a, data4
;;	mov	to1, a 	
      	ret
over8:
      	ret
unbin_div_8 endp


;16 bit unsigned div
unbin_div_16 proc		;data0data1/data4data5---->data1data0(to1to0)---to2to3  
	init
        mov	a, 10h		
        mov	count0, a 
        sz	data5		
        jmp	start16
        sz	data4           
        jmp	start16
        jmp	over16
start16:
	sz	data1		
        jmp	div16
        sz	data0
        jmp	div16
        jmp	dispa16
div16:  
	clr	[0Ah].0		
        rlc	data0
        rlc	data1
        rlc	to2
        rlc	to3		
        mov	a, to2		
        sub	a, data4
        mov	com3, a
        mov	a, to3
        sbc	a, data5
        snz	[0Ah].0        
        jmp	next16		
        mov	to3, a
        mov	a, com3
        mov	to2, a		
        mov	a, 01h
        addm	a, data0
        mov	a, 00h
        adcm	a, data1
next16: 
	sdz	count0
        jmp	div16
dispa16:
	mov	a, data0	
        mov	to0, a 
        mov	a, data1
        mov	to1, a                 
	mov	a, 00h
      	mov	to2, a 	
      	ret
over16:
       	ret
unbin_div_16 endp

;16 bit unsigned mul  
unbin_mul_16 proc		
	init
	mov	a, 10h		;data0data1*data4data5---->to0to1to2to3
	mov	count0, a    
    	clr	[0ah].0  
rradd16:
        rrc	to3
        rrc	to2
        rrc	data5         
        rrc	data4
        snz	[0ah].0      
        jmp	rr116
        mov	a, data0
        addm	a, to2
        mov	a, data1
        adcm	a, to3
rr116:
	sdz	count0
        jmp	rradd16     
        rrc	to3
        rrc	to2
        rrc	data5
        rrc	data4
        mov	a, data4
        mov	to0, a
        mov	a, data5
        mov	to1, a
	ret
unbin_mul_16 endp
