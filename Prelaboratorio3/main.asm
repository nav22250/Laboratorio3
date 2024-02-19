//*****************************************************************************
//Universidad del Valle de Guatemala
//IE2023 Programacionde Microcontroladores
//Author : Nicole Navas
//Proyecto: Prelab3: Contador 4 bits con interrupciones
//IDescripcion: Codigo de contador 4 bits programado con interrupciones
//Hardware: ATMega328P
//Created: 2/11/2024 5:45:27 PM
// Actualizado: 2/5/2024
//*****************************************************************************
// Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.cseg //Inicio del código
.org 0x00
	RJMP main
.org 0x0006
	JMP ISR_PCINT0
.org 0x0020
	JMP ISR_TIMER0_OVF

main:
//*****************************************************************************
//Stack
//*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//*****************************************************************************
// Tabla del display
//*****************************************************************************
TABLA7SEG: .DB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67
/*TABLA7SEG: .DB 0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78,  0x00, 0x10, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E*/
//*****************************************************************************
//Configuracion
//*****************************************************************************
setup:

	LDI R16, 0b0000_1100
	OUT DDRB, R16
	LDI R16, 0b1000_0011
	OUT PORTB, R16

	LDI R16, 0b0000_1111
	OUT DDRC, R16

	LDI R16, 0b1111_1111
	OUT DDRD, R16

	LDI ZH, HIGH (TABLA7SEG << 1)
	LDI ZL, LOW (TABLA7SEG << 1)
	LPM R21, Z

	LDI R17, 0b0000_0000
	OUT PORTD, R17
	LDI R19, 0x00
	STS UCSR0B, R19
	OUT PORTD, R19

	LDI R16, (1<<PCINT0)|(1<<PCINT1)
	STS PCMSK0, R16

	LDI R16, (1<<PCIE0)
	STS PCICR, R16

	LDI R16, 0b0000_0001
	STS TIMSK0, R16

	CALL IdelayT0
	SEI

	LDI R17, 0
	LDI R19, 0
	LDI R22, 0
	LDI R23, 0
	
	SEI


loop:
	LDI ZH, HIGH (TABLA7SEG << 1)
	LDI ZL, LOW (TABLA7SEG << 1)
	ADD ZL, R19
	SBI PORTB, PB2
	LPM R21, Z
	OUT PORTD, R21
	Delay:
		LDI r16, 250
	delay1:
		dec r16
		cpi r16, 0
		Brne delay1

	CBI PORTB, PB2

	LDI ZH, HIGH (TABLA7SEG << 1)
	LDI ZL, LOW (TABLA7SEG << 1)
	ADD ZL, R23

	SBI PORTB, PB3
	LPM R21, Z
	OUT PORTD, R21
	Delay3:
		LDI r16, 250

	delay2:
		dec r16
		cpi r16, 0
		Brne delay2

	CBI PORTB, PB3
	RJMP loop

//*****************************************************************************
//sub rutinas
//*****************************************************************************
IdelayT0:

	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 100
	OUT TCNT0, R16

	LDI R16, (1<<TOIE0)
	STS TIMSK0, R16
	RET

ISR_TIMER0_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16

	LDI R16, 100
	OUT TCNT0, R16
	SBI TIFR0, TOV0

	INC R22
	CPI R22, 100
	BRNE display
	CLR R22

	INC R19
	//INC ZL
	CPI R19, 10
	BRNE display
	CLR R19
	LDI ZH, HIGH (TABLA7SEG << 1)
	LDI ZL, LOW (TABLA7SEG << 1)

	INC R23
	//INC ZL
	CPI R23, 60
	BRNE display
	CLR R23
	LDI ZH, HIGH (TABLA7SEG << 1)
	LDI ZL, LOW (TABLA7SEG << 1)
	
	display:
	POP R16
	OUT SREG, R16
	POP R16
	RETI


ISR_PCINT0:
	PUSH R16
	IN R16, SREG
	PUSH R16

	IN R18, PINB
	
	SBRS R18, PB0
	RJMP b1

	SBRS R18, PB1
	RJMP b2

	RJMP leds

b1:
	CPI R17, 0b1111_1111
	BRNE incrementar
	RJMP leds

b2:
	CPI R17, 0b1111_1111
	BRNE decrementar
	RJMP leds

incrementar:
	INC R17
	RJMP leds

decrementar:
	DEC R17
	RJMP leds


leds:
	OUT PORTC, R17
	SBI PCIFR, PCIF0
	POP R16
	OUT SREG, R16
	POP R16
	RETI
