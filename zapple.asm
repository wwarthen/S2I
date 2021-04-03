;
;==================================================================================================
;   WRAPPER FOR ZAPPLE MONITOR FOR N8VEM PROJECT
;   WAYNE WARTHEN - 2012-11-26
;==================================================================================================
;
; THE FOLLOWING MACROS DO THE HEAVY LIFTING TO MAKE THE ZAPPLE SOURCE
; COMPATIBLE WITH TASM
;
#DEFINE		EQU	.EQU
#DEFINE		NAME	\;
#DEFINE		PAGE	.PAGE
#DEFINE		CSEG	.CSEG
#DEFINE		DSEG	.DSEG
#DEFINE		ORG	.ORG
#DEFINE		END	.END
#DEFINE		IF	.IF
#DEFINE		ELSE	.ELSE
#DEFINE		ENDIF	.ENDIF
#DEFINE		DEFB	.DB
#DEFINE		DB	.DB
#DEFINE		DEFW	.DW
#DEFINE		DW	.DW
#DEFINE		.	_
#DEFINE		TITLE	.TITLE
#DEFINE		EXT	\;
#DEFINE		NOT	~
;
; BELOW WE ADD SOME INSTRUCTION FORMATS EXPECTED BY ZAPPLE SOURCE
;
#ADDINSTR	IN	A,*	DB	2	NOP	1
#ADDINSTR	OUT	*,A	D3	2	NOP	1
#ADDINSTR	ADD	A	87	1	NOP	1
#ADDINSTR	ADD	D	82	1	NOP	1
#ADDINSTR	ADD	*	C6	2	NOP	1
#ADDINSTR	ADC	A	8F	1	NOP	1
#ADDINSTR	ADC	*	CE	2	NOP	1
#ADDINSTR	SBC	H	9C	1	NOP	1
;
; USER DEFINED ROUTINES (NEED TO DO SOMETHING WITH THESE!!!)
;
COLOC		.EQU	0
LNLOC		.EQU	0
LULOC		.EQU	0
PTPL		.EQU	0
PULOC		.EQU	0
CSLOC		.EQU	0
CILOC		.EQU	0
RPTPL		.EQU	0
RULOC		.EQU	0
;
; 16C550 SERIAL LINE UART
;
SIO_BASE	.EQU	90H
SIO_RBR		.EQU	SIO_BASE + 0	; DLAB=0: RCVR BUFFER REG (READ ONLY)
SIO_THR		.EQU	SIO_BASE + 0	; DLAB=0: XMIT HOLDING REG (WRITE ONLY)
SIO_IER		.EQU	SIO_BASE + 1	; DLAB=0: INT ENABLE REG
SIO_IIR		.EQU	SIO_BASE + 2	; INT IDENT REGISTER (READ ONLY)
SIO_FCR		.EQU	SIO_BASE + 2	; FIFO CONTROL REG (WRITE ONLY)
SIO_LCR		.EQU	SIO_BASE + 3	; LINE CONTROL REG
SIO_MCR		.EQU	SIO_BASE + 4	; MODEM CONTROL REG
SIO_LSR		.EQU	SIO_BASE + 5	; LINE STATUS REG
SIO_MSR		.EQU	SIO_BASE + 6	; MODEM STATUS REG
SIO_SCR		.EQU	SIO_BASE + 7	; SCRATCH REGISTER
SIO_DLL		.EQU	SIO_BASE + 0	; DLAB=1: DIVISOR LATCH (LS)
SIO_DLM		.EQU	SIO_BASE + 1	; DLAB=1: DIVISOR LATCH (MS)
;
BAUDRATE	.EQU	38400
UART_DIV	.EQU	(1843200 / (16 * BAUDRATE))
;
;
;
BASE		.EQU	$6000
;
; NOW INCLUDE THE MAIN SOURCE
;
#INCLUDE "zapple.z80"
;
	.FILL	$7000 - $
;
	.END
