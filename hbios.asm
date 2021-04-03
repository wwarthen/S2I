;__________________________________________________________________________________________________
;
;	HBIOS CONTAINER FOR SCSI2IDE
; 	ASSUMES IT WILL BE LOCATED AT $F000-$FFFF
;__________________________________________________________________________________________________
;
	.ORG	$F000
;
; INCLUDE GENERIC STUFF
;
#INCLUDE "std.asm"
;
;==================================================================================================
;   SYSTEM INITIALIZATION
;==================================================================================================
;
; AT THIS POINT, IT IS ASSUMED WE ARE OPERATING FROM RAM PAGE 1
;
INITSYS:
;
; ANNOUNCE HBIOS
;
	CALL	NEWLINE
	CALL	NEWLINE
	PRTX(STR_PLATFORM)
	PRTS(" @ $")
	LD	HL,CPUFREQ
	CALL	PRTDEC
	PRTS("MHz ROM=$")
	LD	HL,ROMSIZE
	CALL	PRTDEC
	PRTS("KB RAM=$")
	LD	HL,RAMSIZE
	CALL	PRTDEC
	PRTS("KB$")
;
; DURING INITIALIZATION, CONSOLE IS UART!
; POST-INITIALIZATION, WILL BE SWITCHED TO USER CONFIGURED CONSOLE
;
	LD	A,CIODEV_UART
	LD	(CONDEV),A
;
; PERFORM DEVICE INITIALIZATION
;
	LD	B,HB_INITTBLLEN
	LD	DE,HB_INITTBL
INITSYS2:
	CALL	NEWLINE
	LD	A,(DE)
	LD	L,A
	INC	DE
	LD	A,(DE)
	LD	H,A
	INC	DE
	PUSH	DE
	PUSH	BC
	CALL	JPHL
	POP	BC
	POP	DE
	DJNZ	INITSYS2
;;
;; SET UP THE DEFAULT DISK BUFFER ADDRESS
;;
;	LD	HL,$8000	; DEFAULT DISK XFR BUF ADDRESS
;	LD	(DIOBUF),HL	; SAVE IT
;
; NOW SWITCH TO USER CONFIGURED CONSOLE
;
	LD	A,DEFCON
	LD	(CONDEV),A	; SET THE ACTIVE CONSOLE DEVICE
;
; DISPLAY THE POST-INITIALIZATION BANNER
;
	CALL	NEWLINE
	CALL	NEWLINE
	PRTX(STR_BANNER)
	CALL	NEWLINE
;
	RET
;
;==================================================================================================
;   TABLE OF INITIALIZATION ENTRY POINTS
;==================================================================================================
;
HB_INITTBL:
#IF (UARTENABLE)
	.DW	UART_INIT
#ENDIF
#IF (PPIDEENABLE)
	.DW	PPIDE_INIT
#ENDIF
#IF (SDENABLE)
	.DW	SD_INIT
#ENDIF
;
HB_INITTBLLEN	.EQU	(($ - HB_INITTBL) / 2)
;
;==================================================================================================
;   IDLE
;==================================================================================================
;
;__________________________________________________________________________________________________
;
IDLE:
	RET
;
;==================================================================================================
;   BIOS FUNCTION DISPATCHER
;==================================================================================================
;
; MAIN BIOS FUNCTION
;   B: FUNCTION
;__________________________________________________________________________________________________
;
BIOS_DISPATCH:
	LD	A,B		; REQUESTED FUNCTION IS IN B
	CP	BF_CIO + $10	; $00-$0F: CHARACTER I/O
	JR	C,CIO_DISPATCH
	CP	BF_DIO + $10	; $10-$1F: DISK I/O
	JR	C,DIO_DISPATCH
	CP	BF_RTC + $10	; $20-$2F: REAL TIME CLOCK (RTC)
	JR	C,RTC_DISPATCH
	CP	BF_EMU + $10	; $30-$3F: EMULATION
	JP	C,EMU_DISPATCH
	CP	BF_VDA + $10	; $40-$4F: VIDEO DISPLAY ADAPTER
	JP	C,VDA_DISPATCH
	
	CP	BF_SYS		; SKIP TO BF_SYS VALUE AT $F0
	CALL	C,PANIC		; PANIC IF LESS THAN BF_SYS
	JP	SYS_DISPATCH	; OTHERWISE SYS CALL
	CALL	PANIC		; THIS SHOULD NEVER BE REACHED
;
;==================================================================================================
;   CHARACTER I/O DEVICE DISPATCHER
;==================================================================================================
;
; ROUTE CALL TO SPECIFIED CHARACTER I/O DRIVER
;   B: FUNCTION
;   C: DEVICE/UNIT
;
CIO_DISPATCH:
	LD	A,C		; REQUESTED DEVICE/UNIT IS IN C
	AND	$F0		; ISOLATE THE DEVICE PORTION
#IF (UARTENABLE)
	CP	CIODEV_UART
	JP	Z,UART_DISPATCH
#ENDIF
	CALL	PANIC
;
;==================================================================================================
;   DISK I/O DEVICE DISPATCHER
;==================================================================================================
;
; ROUTE CALL TO SPECIFIED DISK I/O DRIVER
;   B: FUNCTION
;   C: DEVICE/UNIT
;
DIO_DISPATCH:
	; GET THE REQUESTED FUNCTION TO SEE IF SPECIAL HANDLING
	; IS NEEDED
	LD	A,B
;
	; DIO FUNCTIONS STARTING AT DIOGETBUF ARE COMMON FUNCTIONS
	; AND DO NOT DISPATCH TO DRIVERS (HANDLED GLOBALLY)
	CP	BF_DIOGETBUF	; TEST FOR FIRST OF THE COMMON FUNCTIONS
	JR	NC,DIO_COMMON	; IF >= DIOGETBUF HANDLE AS COMMON DIO FUNCTION
;
	; HACK TO FILL IN HSTTRK AND HSTSEC
	; BUT ONLY FOR READ/WRITE FUNCTION CALLS
	; ULTIMATELY, HSTTRK AND HSTSEC ARE TO BE REMOVED
	CP	BF_DIOST		; BEYOND READ/WRITE FUNCTIONS ?
	JR	NC,DIO_DISPATCH1	; YES, BYPASS
	LD	(HSTTRK),HL		; RECORD TRACK
	LD	(HSTSEC),DE		; RECORD SECTOR
;
DIO_DISPATCH1:
	; START OF THE ACTUAL DRIVER DISPATCHING LOGIC
	LD	A,C		; GET REQUESTED DEVICE/UNIT FROM C
	LD	(HSTDSK),A	; TEMP HACK TO FILL IN HSTDSK
	AND	$F0		; ISOLATE THE DEVICE PORTION
#IF (PPIDEENABLE)
	CP	DIODEV_PPIDE
	JP	Z,PPIDE_DISPATCH
#ENDIF
#IF (SDENABLE)
	CP	DIODEV_SD
	JP	Z,SD_DISPATCH
#ENDIF
;
	CALL	PANIC
;
; HANDLE COMMON DISK FUNCTIONS (NOT DEVICE DRIVER SPECIFIC)
;
DIO_COMMON:
	SUB	BF_DIOGETBUF	; FUNCTION = DIOGETBUF?
	JR	Z,DIO_GETBUF	; YES, HANDLE IT
	DEC	A		; FUNCTION = DIOSETBUF?
	JR	Z,DIO_SETBUF	; YES, HANDLE IT
	CALL	PANIC		; INVALID FUNCTION SPECFIED
;
; DISK: GET BUFFER ADDRESS
;
DIO_GETBUF:
	LD	HL,(DIOBUF)	; HL = DISK BUFFER ADDRESS
	XOR	A		; SIGNALS SUCCESS
	RET
;
; DISK: SET BUFFER ADDRESS
;
DIO_SETBUF:
	BIT	7,H		; IS HIGH ORDER BIT SET?
	CALL	Z,PANIC		; IF NOT, ADR IS IN LOWER 32K, NOT ALLOWED!!!
	LD	(DIOBUF),HL	; RECORD NEW DISK BUFFER ADDRESS
	XOR	A		; SIGNALS SUCCESS
	RET
;
;==================================================================================================
;   REAL TIME CLOCK DEVICE DISPATCHER
;==================================================================================================
;
; ROUTE CALL TO REAL TIME CLOCK DRIVER (NOT YET IMPLEMENTED)
;   B: FUNCTION
;
RTC_DISPATCH:
	CALL	PANIC
;
;==================================================================================================
;   EMULATION HANDLER DISPATCHER
;==================================================================================================
;
; ROUTE CALL TO EMULATION HANDLER CURRENTLY ACTIVE
;   B: FUNCTION
;
EMU_DISPATCH:
	CALL	PANIC		; INVALID
;
;==================================================================================================
;   VIDEO DISPLAY ADAPTER DEVICE DISPATCHER
;==================================================================================================
;
; ROUTE CALL TO SPECIFIED VDA DEVICE DRIVER
;   B: FUNCTION
;   C: DEVICE/UNIT
;
VDA_DISPATCH:
	CALL	PANIC
;
;==================================================================================================
;   SYSTEM FUNCTION DISPATCHER
;==================================================================================================
;
;   B: FUNCTION
;
SYS_DISPATCH:
	LD	A,B		; GET REQUESTED FUNCTION
	AND	$0F		; ISOLATE SUB-FUNCTION
	JR	Z,SYS_GETCFG	; $F0
	DEC	A
	JR	Z,SYS_SETCFG	; $F1
	DEC	A
	JR	Z,SYS_BNKCPY	; $F2
	DEC	A
	JR	Z,SYS_GETVER	; $F3
	CALL	PANIC		; INVALID
;
; GET ACTIVE CONFIGURATION
;   DE: DESTINATION TO RECEIVE CONFIGURATION DATA BLOCK
;       MUST BE IN UPPER 32K
;
SYS_GETCFG:
	CALL	PANIC
	LD	HL,$0200		; SETUP SOURCE OF CONFIG DATA
	LD	BC,$0100		; SIZE OF CONFIG DATA
	LDIR				; COPY IT
	RET
;
; SET ACTIVE CONFIGURATION
;   DE: SOURCE OF NEW CONFIGURATION DATA BLOCK
;       MUST BE IN UPPER 32K
;
;   HBIOS IS NOT REALLY SET UP TO DYNAMICALLY RECONFIGURE ITSELF!!!
;   THIS FUNCTION IS NOT USEFUL YET.
;
SYS_SETCFG:
	CALL	PANIC
	LD	HL,$0200		; SETUP SOURCE OF CONFIG DATA
	LD	BC,$0100
	EX	DE,HL
	LDIR
	RET
;
; PERFORM A BANKED MEMORY COPY
;   C: BANK TO SWAP INTO LOWER 32K PRIOR TO COPY OPERATION
;   IX: COUNT OF BYTES TO COPY
;   HL: SOURCE ADDRESS FOR COPY
;   DE: DESTINATION ADDRESS FOR COPY
;
SYS_BNKCPY:
	CALL	PANIC
;
; GET THE CURRENT HBIOS VERSION
;   RETURNS VERSION IN DE AS BCD
;     D: MAJOR VERION IN TOP 4 BITS, MINOR VERSION IN LOW 4 BITS
;     E: UPDATE VERION IN TOP 4 BITS, PATCH VERSION IN LOW 4 BITS
;
SYS_GETVER:
	LD	DE,0 | (RMJ<<12) | (RMN<<8) | (RUP<<4) | RTP
	XOR	A
	RET
;
;==================================================================================================
;   GLOBAL HBIOS FUNCTIONS
;==================================================================================================
;
; COMMON ROUTINE THAT IS CALLED BY CHARACTER IO DRIVERS WHEN
; AN IDLE CONDITION IS DETECTED (WAIT FOR INPUT/OUTPUT)
;
CIO_IDLE:
	LD	HL,IDLECOUNT		; POINT TO IDLE COUNT
	DEC	(HL)			; 256 TIMES?
	CALL	Z,IDLE			; RUN IDLE PROCESS EVERY 256 ITERATIONS
	XOR	A			; SIGNAL NO CHAR READY
	RET				; AND RETURN
;
;==================================================================================================
;   DEVICE DRIVERS
;==================================================================================================
;
#IF (UARTENABLE)
ORG_UART	.EQU	$
  #INCLUDE "uart.asm"
SIZ_UART	.EQU	$ - ORG_UART
		.ECHO	"UART occupies "
		.ECHO	SIZ_UART
		.ECHO	" bytes.\n"
#ENDIF
;
#IF (PPIDEENABLE)
ORG_PPIDE	.EQU	$
  #INCLUDE "ppide.asm"
SIZ_PPIDE	.EQU	$ - ORG_PPIDE
		.ECHO	"PPIDE occupies "
		.ECHO	SIZ_PPIDE
		.ECHO	" bytes.\n"
#ENDIF
;
#IF (SDENABLE)
ORG_SD		.EQU	$
  #INCLUDE "sd.asm"
SIZ_SD		.EQU	$ - ORG_SD
		.ECHO	"SD occupies "
		.ECHO	SIZ_SD
		.ECHO	" bytes.\n"
#ENDIF
;
#DEFINE	CIOMODE_CONSOLE
#DEFINE	DSKY_KBD
#INCLUDE "util.asm"
;
;==================================================================================================
;   BANK ONE GLOBAL DATA
;==================================================================================================
;
CONDEV		.DB	DEFCON
;
IDLECOUNT	.DB	0
;
HSTDSK		.DB	0		; DISK IN BUFFER
HSTTRK		.DW	0		; TRACK IN BUFFER
HSTSEC		.DW	0		; SECTOR IN BUFFER
;
;DIOBUF		.DW	$FD00		; PTR TO 512 BYTE DISK XFR BUFFER
DIOBUF		.DW	$8000		; PTR TO 512 BYTE DISK XFR BUFFER
;
STR_BANNER	.DB	"S2I HBIOS v", BIOSVER, " ("
VAR_LOC		.DB	VARIANT, "-"
TST_LOC		.DB	TIMESTAMP, ")$"
STR_PLATFORM	.DB	PLATFORM_NAME, "$"
;
;==================================================================================================
;   FILL REMAINDER OF BANK
;==================================================================================================
;
SLACK:		.EQU	($FF00 - $)
		.FILL	SLACK,0FFH
;
		.ECHO	"HBIOS space remaining: "
		.ECHO	SLACK
		.ECHO	" bytes.\n"
;
;==================================================================================================
;   HBIOS UPPER MEMORY STUB
;==================================================================================================
;
;==================================================================================================
;   HBIOS INTERRUPT VECTOR TABLE
;==================================================================================================
;
; AREA RESERVED FOR UP TO 16 INTERRUPT VECTOR ENTRIES (MODE 2)
;
HB_IVT:
	.FILL	20H,0FFH
;
;==================================================================================================
;   HBIOS ENTRY FOR RST 08 PROCESSING
;==================================================================================================
;
; ENTRY POINT FOR BIOS FUNCTIONS (TARGET OF RST 08)
;
HB_ENTRY:
	CALL	BIOS_DISPATCH	; CALL HBIOS FUNCTION DISPATCHER
	RET			; RETURN TO CALLER
;
HB_SLACK	.EQU	($FFFF - $ + 1)
		.ECHO	"STACK space remaining: "
		.ECHO	HB_SLACK
		.ECHO	" bytes.\n"
;
		.FILL	HB_SLACK,0FFH
		.END
