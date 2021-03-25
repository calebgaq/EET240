;
; LCDassemblyat.asm
; STK200 with Atmega32
; Created: 3/24/2021 4:25:35 PM
; Author : Caleb
; Organization:  Rogue Community College - Electronics Technology Department
; Project Brief: Command LCD unit in 4 bit mode. Simple message display.
; PinB(4-7) go to D4-D7 on the LCD
; PinB0 is RS
; PinB1 is E



.include "m32def.inc" ; 


.equ LCD_P = PORTB
.equ LCD_DDR = DDRB
.equ LCD_RS = 0
.equ LCD_E = 1


.def temp = r16		;temporary register for user
.def nibb = r17		;swap nibble register
.def nutt = r18		;register to keep track of RS and E

//*************************Initialization***********************

	ldi temp, HIGH(RAMEND)	;$08
	out SPH, temp			;stack pointer high byte
	ldi temp, LOW(RAMEND)	;$5F
	out SPL, temp			;Stack pointer low byte

	ser temp 
	out LCD_DDR, temp  ; configure portb (0-7) as output
	

//************************MAIN**********************************
		call LCDwake

		ldi temp, $02	;testing
		call cmd		
		call d2ms
				
		ldi temp, $28	;2line, 5x8, 4bit mode 
		call cmd
		call d2ms

		ldi temp, $0C	;display on cursor off
		call cmd
		call d2ms

		ldi temp, $06	;increment cursor (shift right after write)
		call cmd
		call d2ms

		ldi temp, $01	;clear screen
		call cmd
		call LCDwake

		ldi temp, 'F'
		call DWRT
		call d2ms

		ldi temp, 'u'
		call DWRT
		call d2ms

		ldi temp, 'n'
		call DWRT
		call d2ms

		ldi temp, '!'
		call DWRT
		call d2ms

endr:	rjmp endr

//************************COMMANDWRITE**************************

cmd:	mov nibb, temp		;copy command to stemp
		ANDI nibb, $F0		;mask to high byte
		in nutt, LCD_P		;current output copied to nutt
		andi nutt, $0F		;mask to low byte (for RS and E)
		or nutt, nibb		;OR nutt with nibb to get the best of both worlds!
		out LCD_P, nutt		;send first nibble
		cBi LCD_P, LCD_RS	;send RS to 0 for command
		sbi LCD_P, LCD_E	;send 1 to Enable
		call sdel			;small delay for Enable pulse
		cbi LCD_P, LCD_E	;now 0 to Enable
		call d100u			;100us delay for low pulse

		mov nibb, temp		;copy command to stemp
		swap nibb			;swap so low byte is now high!
		ANDI nibb, $F0		;mask to high byte
		in nutt, LCD_P		;current output copied to nutt
		andi nutt, $0F		;mask to low byte (for RS and E)
		or nutt, nibb		;OR nutt with nibb to get the best of both worlds!
		out LCD_P, nutt		;send first nibble
		;cBi LCD_P, LCD_RS	;send RS to 0 for command
		sbi LCD_P, LCD_E	;send 1 to Enable
		call sdel			;small delay for Enable pulse
		cbi LCD_P, LCD_E	;now 0 to Enable
		call d100u			;100us delay for low pulse

//************************DATAWRITE*****************************
DWRT:	mov nibb, temp		;copy data to stemp
		ANDI nibb, $F0		;mask to high byte
		in nutt, LCD_P		;current output copied to nutt
		andi nutt, $0F		;mask to low byte (for RS and E)
		or nutt, nibb		;OR nutt with nibb to get the best of both worlds!
		out LCD_P, nutt		;send first nibble
		sBi LCD_P, LCD_RS	;send RS to 1 for DATA
		sbi LCD_P, LCD_E	;send 1 to Enable
		call sdel			;small delay for Enable pulse
		cbi LCD_P, LCD_E	;now 0 to Enable
		call d100u			;100us delay for low pulse

		mov nibb, temp		;copy command to stemp
		swap nibb			;swap so low byte is now high!
		ANDI nibb, $F0		;mask to high byte
		in nutt, LCD_P		;current output copied to nutt
		andi nutt, $0F		;mask to low byte (for RS and E)
		or nutt, nibb		;OR nutt with nibb to get the best of both worlds!
		out LCD_P, nutt		;send first nibble
		;sBi LCD_P, LCD_RS	;send RS to 1 for DATA
		sbi LCD_P, LCD_E	;send 1 to Enable
		call sdel			;small delay for Enable pulse
		cbi LCD_P, LCD_E	;now 0 to Enable
		call d100u			;100us delay for low pulse



//************************DELAYS********************************

//5us at 1MHz
sdel:	nop			;1 cycle
		ret			;4 cycles

//100us at 1MHz
d100u:	push temp	;2 cycles
		ldi temp, 9 ;9 times
d100US:	call sdel	;9	cycles
		dec temp	;1 cycle
		brne d100us; 2 if true 1 if false
		pop temp	;2 cycles
		ret			;4 cycles

//2ms at 1MHz
d2ms:	push temp
		ldi temp, 20;20 times 
dMS:	call sdel	;9	cycles
		dec temp	;1 cycle
		brne dms; 2 if true 1 if false
		pop temp	;2 cycles
		ret			;4 cycles


LCDwake: push temp
		ldi temp, 8	;8times
wake:	call d2ms
		dec temp
		brne wake
		pop temp
		ret