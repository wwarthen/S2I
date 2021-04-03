;
;=============================================================================
;   SD/SDHC/SDXC CARD STORAGE DRIVER
;=============================================================================
;
;------------------------------------------------------------------------------
; SD Signal	Active	JUHA	N8	CSIO	PPI	UART	DSD    MK4
; ------------	-------	-------	-------	-------	-------	-------	-------	-------
; CS (DAT3)	LO ->	RTC:2	RTC:2	RTC:2	~PC:4	MCR:3	OPR:2  MK4_SD:2
; CLK		HI ->	RTC:1	RTC:1	N/A	PC:1	~MCR:2	OPR:1  N/A
; DI (CMD)	HI ->	RTC:0	RTC:0	N/A	PC:0	~MCR:0	OPR:0  N/A
; DO (DAT0)	HI ->	RTC:7	RTC:6	N/A	PB:7	~MSR:5	OPR:0  N/A
;------------------------------------------------------------------------------
;
; CS = CHIP SELECT (AKA DAT3 FOR NON-SPI MODE)
; CLK = CLOCK
; DI = DATA IN (HOST -> CARD, AKA CMD FOR NON-SPI MODE)
; DO = DATA OUT (HOST <- CARD, AKA DAT0 FOR NON-SPI MODE)
;
; NOTES:
;   1) SIGNAL NAMES ARE FROM THE SD CARD SPEC AND ARE NAMED FROM THE
;      PERSPECTIVE OF THE SD CARD:
;        DI = DATA IN: HOST -> CARD = MOSI (MASTER OUT/SLAVE IN)
;        DO = DATA OUT: HOST <- CARD = MISO (MASTER IN/SLAVE OUT)
;
;   2) THE QUIESCENT STATE OF THE OUTPUT SIGNALS (HOST -> CARD) IS:
;      CS = HI (NOT SELECTED)
;      CLK = LO (HI FOR CSIO)
;      DI = HI (ACTIVE IS THE NATURAL/DEFAULT STATE FOR DATA IN)
;
;   3) SPI MODE 0 IMPLEMENTATION IS USED (CPOL=0, CPHA=0)
;      THE DATA MUST BE AVAILABLE BEFORE THE FIRST CLOCK SIGNAL RISING.
;      THE CLOCK IDLE STATE IS ZERO. THE DATA ON MISO AND MOSI LINES 
;      MUST BE STABLE WHILE THE CLOCK IS HIGH AND CAN BE CHANGED WHEN
;      THE CLOCK IS LOW. THE DATA IS CAPTURED ON THE CLOCK'S LOW-TO-HIGH
;      TRANSITION AND PROPAGATED ON HIGH-TO-LOW CLOCK TRANSITION.
;
;      NOTE: THE CSIO IMPLEMENTATION (INCLUDE MK4) USES SPI MODE 4
;      (CPOL=1, CPHA=1) BECAUSE THAT IS THE WAY THAT THE Z180 CSIO
;      INTERFACE WORKS.  ALL OF THE CLOCK TRANSITIONS LISTED ABOVE
;      ARE REVERSED FOR CSIO.
;
;   4) DI SHOULD BE LEFT HI (ACTIVE) WHENEVER UNUSED (FOR EXAMPLE, WHEN
;      HOST IS RECEIVING DATA (HOST <- CARD)).
;
#IF (SDMODE == SDMODE_JUHA)		; JUHA MINI-BOARD
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	RTC		; USES RTC LATCHES FOR OPERATION
SD_OPRDEF	.EQU	%00000001	; QUIESCENT STATE???
SD_INPREG	.EQU	RTC		; INPUT REGISTER IS RTC
SD_CS		.EQU	%00000100	; RTC:2 IS SELECT
SD_CLK		.EQU	%00000010	; RTC:1 IS CLOCK
SD_DI		.EQU	%00000001	; RTC:0 IS DATA IN (CARD <- CPU)
SD_DO		.EQU	%10000000	; RTC:7 IS DATA OUT (CARD -> CPU)
#ENDIF
;
#IF (SDMODE == SDMODE_N8)		; UNMODIFIED N8-2511
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	RTC		; USES RTC LATCHES FOR OPERATION
SD_OPRDEF	.EQU	%00000001	; QUIESCENT STATE???
SD_INPREG	.EQU	RTC		; INPUT REGISTER IS RTC
SD_CS		.EQU	%00000100	; RTC:2 IS SELECT
SD_CLK		.EQU	%00000010	; RTC:1 IS CLOCK
SD_DI		.EQU	%00000001	; RTC:0 IS DATA IN (CARD <- CPU)
SD_DO		.EQU	%01000000	; RTC:6 IS DATA OUT (CARD -> CPU)
#ENDIF
;
#IF (SDMODE == SDMODE_CSIO)		; N8-2312
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	RTC		; USES RTC LATCHES FOR OPERATION
SD_OPRDEF	.EQU	%00000000	; QUIESCENT STATE
SD_CS		.EQU	%00000100	; RTC:2 IS SELECT
SD_CNTR		.EQU	CPU_CNTR
SD_TRDR		.EQU	CPU_TRDR
#ENDIF
;
#IF (SDMODE == SDMODE_PPI)		; PPISD
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_PPIBASE	.EQU	PPIBASE		; BASE IO PORT FOR PPI
SD_PPIB		.EQU	PPIBASE + 1	; PPI PORT B (INPUT: DOUT)
SD_PPIC		.EQU	PPIBASE + 2	; PPI PORT C (OUTPUT: CS, CLK, DIN)
SD_PPIX		.EQU	PPIBASE + 3	; PPI CONTROL PORT
SD_OPRREG	.EQU	SD_PPIC		; PPI PORT C IS OPR REG
SD_OPRDEF	.EQU	%00110001	; CS HI, DI HI
SD_INPREG	.EQU	SD_PPIB		; INPUT REGISTER IS PPI PORT B
SD_CS		.EQU	%00010000	; PPIC:4 IS SELECT
SD_CLK		.EQU	%00000010	; PPIC:1 IS CLOCK
SD_DI		.EQU	%00000001	; PPIC:0 IS DATA IN (CARD <- CPU)
SD_DO		.EQU	%10000000	; PPIB:7 IS DATA OUT (CARD -> CPU)
#ENDIF
;
#IF (SDMODE == SDMODE_UART)
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	SIO_MCR		; UART MCR PORT (OUTPUT: CS, CLK, DIN)
SD_OPRDEF	.EQU	%00001100	; QUIESCENT STATE
SD_INPREG	.EQU	SIO_MSR		; INPUT REGISTER IS MSR
SD_CS		.EQU	%00001000	; UART MCR:3 IS SELECT
SD_CLK		.EQU	%00000100	; UART MCR:2 IS CLOCK
SD_DI		.EQU	%00000001	; UART MCR:0 IS DATA IN (CARD <- CPU)
SD_DO		.EQU	%00100000	; UART MSR:5 IS DATA OUT (CARD -> CPU)
#ENDIF
;
#IF (SDMODE == SDMODE_DSD)		; DUAL SD
SD_UNITCNT	.EQU	2		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	$08		; DEDICATED OPERATIONS REGISTER
SD_OPRDEF	.EQU	%00000001	; QUIESCENT STATE
SD_INPREG	.EQU	SD_OPRREG	; INPUT REGISTER IS OPRREG
SD_SELREG	.EQU	SD_OPRREG + 1	; DEDICATED SELECTION REGISTER
SD_SELDEF	.EQU	%00000000	; SELECTION REGISTER DEFAULT
SD_CS		.EQU	%00000100	; RTC:2 IS SELECT
SD_CLK		.EQU	%00000010	; RTC:1 IS CLOCK
SD_DI		.EQU	%00000001	; RTC:6 IS DATA IN (CARD <- CPU)
SD_DO		.EQU	%00000001	; RTC:0 IS DATA OUT (CARD -> CPU)
#ENDIF
;
#IF (SDMODE == SDMODE_MK4)		; MARK IV (CSIO STYLE INTERFACE)
SD_UNITCNT	.EQU	1		; NUMBER OF PHYSICAL UNITS (SOCKETS)
SD_OPRREG	.EQU	MK4_SD		; DEDICATED MK4 SDCARD REGISTER
SD_OPRDEF	.EQU	%00000000	; QUIESCENT STATE
SD_CS		.EQU	%00000100	; SELECT ACTIVE
SD_CNTR		.EQU	CPU_CNTR
SD_TRDR		.EQU	CPU_TRDR
#ENDIF
;
; SD CARD COMMANDS
;
SD_CMD0		.EQU	$40 | 0		; 0x40, GO_IDLE_STATE
SD_CMD1		.EQU	$40 | 1		; 0x41, SEND_OP_COND
SD_CMD8		.EQU	$40 | 8		; 0x48, SEND_IF_COND
SD_CMD9		.EQU	$40 | 9		; 0x49, SEND_CSD
SD_CMD10	.EQU	$40 | 10	; 0x4A, SEND_CID
SD_CMD16	.EQU	$40 | 16	; 0x50, SET_BLOCKLEN
SD_CMD17	.EQU	$40 | 17	; 0x51, READ_SINGLE_BLOCK
SD_CMD24	.EQU	$40 | 24	; 0x58, WRITE_BLOCK
SD_CMD55	.EQU	$40 | 55	; 0x77, APP_CMD
SD_CMD58	.EQU	$40 | 58	; 0x7A, READ_OCR
; SD APPLICATION SPECIFIC COMMANDS
SD_ACMD41	.EQU	$40 | 41	; 0x69, SD_APP_OP_COND
;
; SD CARD TYPE
;
SD_TYPEUNK	.EQU	0	; CARD TYPE UNKNOWN/UNDETERMINED
SD_TYPEMMC	.EQU	1	; MULTIMEDIA CARD (MMC STANDARD)
SD_TYPESDSC	.EQU	2	; SDSC CARD (V1)
SD_TYPESDHC	.EQU	3	; SDHC/SDXC CARD (V2)
;
; SD CARD STATUS (SD_STAT)
;
SD_STOK		.EQU	0	; OK
SD_STNOTRDY	.EQU	-1	; NOT READY (INITIALIZATION PENDING)
SD_STRDYTO	.EQU	-2	; TIMEOUT WAITING FOR CARD TO BE READY
SD_STINITTO	.EQU	-3	; INITIALIZATOIN TIMEOUT
SD_STCMDTO	.EQU	-4	; TIMEOUT WAITING FOR COMMAND RESPONSE
SD_STCMDERR	.EQU	-5	; COMMAND ERROR OCCURRED (REF SD_RC)
SD_STDATAERR	.EQU	-6	; DATA ERROR OCCURRED (REF SD_TOK)
SD_STDATATO	.EQU	-7	; DATA TRANSFER TIMEOUT
SD_STCRCERR	.EQU	-8	; CRC ERROR ON RECEIVED DATA PACKET
SD_STNOMEDIA	.EQU	-9	; NO MEDIA IN CONNECTOR
SD_STWRTPROT	.EQU	-10	; ATTEMPT TO WRITE TO WRITE PROTECTED MEDIA
;
;
;
SD_DISPATCH:
	LD	A,B		; GET REQUESTED FUNCTION
	AND	$0F
	JP	Z,SD_READ
	DEC	A
	JP	Z,SD_WRITE
	DEC	A
	JP	Z,SD_STATUS
	DEC	A
	JP	Z,SD_MEDIA
	CALL	PANIC
;
;
;
SD_MEDIA:
	CALL	SD_SELUNIT
;
	; INITIALIZE THE SD CARD TO ACCOMMODATE HOT SWAPPING
	CALL	SD_INITCARD
	LD	A,MID_HD	; ASSUME SUCCESS
	RET	Z		; RETURN IF GOOD INIT
	CALL	SD_PRT
	LD	A,MID_NONE	; IF FAILURE, RETURN NO MEDIA
	RET
;
SD_INIT:
	PRTS("SD:$")
	PRTS(" UNITS=$")
	LD	A,SD_UNITCNT
	CALL	PRTHEXBYTE
#IF (SDMODE == SDMODE_JUHA)
	PRTS(" MODE=JUHA$")
	PRTS(" IO=0x$")
	LD	A,SD_OPRREG
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_N8)
	PRTS(" MODE=N8$")
	PRTS(" IO=0x$")
	LD	A,SD_OPRREG
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_CSIO)
	PRTS(" MODE=CSIO$")
  #IF (SDCSIOFAST)
	PRTS(" FAST$")
  #ENDIF
	PRTS(" OPR=0x$")
	LD	A,SD_OPRREG
	CALL	PRTHEXBYTE
	PRTS(" CNTR=0x$")
	LD	A,SD_CNTR
	CALL	PRTHEXBYTE
	PRTS(" TRDR=0x$")
	LD	A,SD_TRDR
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_PPI)
	PRTS(" MODE=PPI$")
	PRTS(" BASEIO=0x$")
	LD	A,SD_PPIBASE
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_UART)
	PRTS(" MODE=UART$")
	PRTS(" MCR=0x$")
	LD	A,SIO_MCR
	CALL	PRTHEXBYTE
	PRTS(" MSR=0x$")
	LD	A,SIO_MSR
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_DSD)
	PRTS(" MODE=DSD$")
	PRTS(" OPR=0x$")
	LD	A,SD_OPRREG
	CALL	PRTHEXBYTE
	PRTS(" SEL=0x$")
	LD	A,SD_SELREG
	CALL	PRTHEXBYTE
#ENDIF
;
#IF (SDMODE == SDMODE_MK4)
	PRTS(" MODE=MK4$")
  #IF (SDCSIOFAST)
	PRTS(" FAST$")
  #ENDIF
	PRTS(" OPR=0x$")
	LD	A,SD_OPRREG
	CALL	PRTHEXBYTE
	PRTS(" CNTR=0x$")
	LD	A,SD_CNTR
	CALL	PRTHEXBYTE
	PRTS(" TRDR=0x$")
	LD	A,SD_TRDR
	CALL	PRTHEXBYTE
#ENDIF
;
	LD	A,SD_STNOTRDY
	LD	HL,SD_STATLST
	LD	(SD_STATPTR),HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	LD	A,SD_TYPEUNK
	LD	HL,SD_TYPELST
	LD	(SD_TYPEPTR),HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
;
	LD	B,SD_UNITCNT
	LD	C,0
SD_INIT1:
	PUSH	BC
	CALL	SD_SELUNIT
	CALL	SD_INITCARD
	CALL	SD_PRT
	CALL	Z,SD_PRTINFO
	POP	BC
	INC	C
	DJNZ	SD_INIT1
;
	RET
;
SD_STATUS:
	CALL	SD_SELUNIT
	LD	HL,(SD_STATPTR)
	LD	A,(HL)
	OR	A
	RET
;
SD_READ:
	CALL	SD_SELUNIT
	CALL	SD_RDSEC
	JR	SD_PRT
;
SD_WRITE:
	CALL	SD_SELUNIT
	CALL	SD_CHKWP
	CALL	NZ,SD_WRTPROT
	CALL	Z,SD_WRSEC
	JR	SD_PRT
;
SD_PRT:
#IF (SDTRACE >= 1)
	RET	Z
	PUSH	AF
	CALL	SD_PRTPREFIX
	CALL	PC_SPACE
	CALL	SD_PRTSTAT
	POP	AF
#ENDIF
	RET
;
;=============================================================================
; SD HARDWARE INTERFACE ROUTINES
;=============================================================================
;
; TAKE ANY ACTIONS REQUIRED TO SELECT DESIRED PHYSICAL UNIT
;
SD_SELUNIT:
	LD	A,C
	AND	0FH		; ISOLATE THE UNIT NIBBLE
	CP	SD_UNITCNT	; CHECK VALIDITY (EXCEED UNIT COUNT?)
	CALL	NC,PANIC	; PANIC ON INVALID VALUE
	LD	(SD_UNIT),A	; SAVE CURRENT UNIT NUM
#IF (SDMODE == SDMODE_DSD)
	; SELECT REQUESTED UNIT
	OUT	(SD_SELREG),A	; ACTUALLY SELECT THE CARD
#ENDIF
	LD	HL,SD_STATLST	; POINT TO START OF STATUS LIST
	LD	D,0		; SETUP DE TO HAVE OFFSET
	LD	E,A		; FOR CURRENT UNIT
	ADD	HL,DE		; APPLY THE OFFSET
	LD	(SD_STATPTR),HL	; SAVE IT
	LD	HL,SD_TYPELST	; POINT TO START OF CARD TYPE LIST
	ADD	HL,DE		; APPLY THE OFFSET
	LD	(SD_TYPEPTR),HL	; SAVE IT
	RET
;
; PERFORM HARDWARE SPECIFIC INITIALIZATION
;
SD_SETUP:
;
#IF ((SDMODE == SDMODE_JUHA) | (SDMODE == SDMODE_N8) | (SDMODE == SDMODE_DSD))
	LD	A,SD_OPRDEF
	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A
#ENDIF
;
#IF ((SDMODE == SDMODE_CSIO) | (SDMODE == SDMODE_MK4))
	; CSIO SETUP
;	LD	A,2			; 18MHz/20 <= 400kHz
	LD	A,6			; ???
	OUT0	(SD_CNTR),A
	LD	A,SD_OPRDEF
	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A
#ENDIF
;
#IF (SDMODE == SDMODE_PPI)
	LD	A,82H			; PPI PORT A=OUT, B=IN, C=OUT
	OUT	(PPIX),A
	;LD	A,30H			; PC4,5 /CS HIGH
	LD	A,SD_OPRDEF
	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A
#ENDIF
;
#IF (SDMODE == SDMODE_UART)
SD_OPRMSK	.EQU	(SD_CS | SD_CLK | SD_DI)

	IN	A,(SD_OPRREG)		; OPRREG == SIO_MCR

	AND	~SD_OPRMSK
	OR	SD_OPRDEF

;;SD_OPRDEF	.EQU	%00001000	; QUIESCENT STATE???
;	OR	SD_CS			; OPR:3, DEASSERT = HI = 1
;	AND	~SD_DI			; OPR:0, ASSERT DIN = LO = 0 (INVERTED)
;	OR	SD_CLK			; OPR:2, DEASSERT CLK = HI = 1 (INVERTED)

	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A		; OPRREG == SIO_MCR
#ENDIF
;
#IF ((SDMODE == SDMODE_DSD) | (SDMODE == SDMODE_MK4))
	IN	A,(SD_OPRREG)
	BIT	5,A			; CARD DETECT
	JP	Z,SD_NOMEDIA		; NO MEDIA DETECTED
#ENDIF
;
	XOR	A
	RET
;
; SELECT CARD
;
SD_SELECT:
	LD	A,(SD_OPRVAL)
#IF ((SDMODE == SDMODE_PPI) | (SDMODE == SDMODE_UART))
	AND	~SD_CS		; SET SD_CS (CHIP SELECT)
#ELSE
	OR	SD_CS		; SET SD_CS (CHIP SELECT)
#ENDIF
	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A
	RET
;
; DESELECT CARD
;
SD_DESELECT:
	LD	A,(SD_OPRVAL)
#IF ((SDMODE == SDMODE_PPI) | (SDMODE == SDMODE_UART))
	OR	SD_CS		; RESET SD_CS (CHIP SELECT)
#ELSE
	AND	~SD_CS		; RESET SD_CS (CHIP SELECT)
#ENDIF
	LD	(SD_OPRVAL),A
	OUT	(SD_OPRREG),A
	RET
;
; CHECK FOR WRITE PROTECT (NZ = WRITE PROTECTED)
;
SD_CHKWP:
#IF ((SDMODE == SDMODE_DSD) | (SDMODE == SDMODE_MK4))
	IN	A,(SD_OPRREG)
	BIT	4,A
#ELSE
	XOR	A
#ENDIF
	RET
;
;
;
#IF ((SDMODE == SDMODE_CSIO) | (SDMODE == SDMODE_MK4))
SD_WAITTX:			; WAIT FOR TX EMPTY	
	IN0	A,(SD_CNTR)	; GET CSIO STATUS
	BIT	4,A		; TX EMPTY?
	JR	NZ,SD_WAITTX
	RET
;
;
;
SD_WAITRX:
	IN0	A,(SD_CNTR)	; WAIT FOR RECEIVER TO FINISH
	BIT	5,A
	JR	NZ,SD_WAITRX
	RET
;
;
;
MIRROR:				; MSB<-->LSB mirror bits in A, result in C
  #IF (!SDCSIOFAST)		; slow speed, least code space
	LD      B,8		; bit counter
MIRROR1:
	RLA			; rotate bit 7 into carry
	RR	C		; rotate carry into result
	DJNZ	MIRROR1		; do all 8 bits
	RET
  #ELSE				; fastest but uses most code space
	LD	BC,MIRTAB	; 256 byte mirror table
	ADD	A,C		; add offset
	LD	C,A
	JR	NC,MIRROR2
	INC	B
MIRROR2:
	LD	A,(BC)		; get result
	LD	C,A		; return result in C
	RET
  #ENDIF
;
MIRTAB:	.DB 00H, 80H, 40H, 0C0H, 20H, 0A0H, 60H, 0E0H, 10H, 90H, 50H, 0D0H, 30H, 0B0H, 70H, 0F0H
	.DB 08H, 88H, 48H, 0C8H, 28H, 0A8H, 68H, 0E8H, 18H, 98H, 58H, 0D8H, 38H, 0B8H, 78H, 0F8H
	.DB 04H, 84H, 44H, 0C4H, 24H, 0A4H, 64H, 0E4H, 14H, 94H, 54H, 0D4H, 34H, 0B4H, 74H, 0F4H
	.DB 0CH, 8CH, 4CH, 0CCH, 2CH, 0ACH, 6CH, 0ECH, 1CH, 9CH, 5CH, 0DCH, 3CH, 0BCH, 7CH, 0FCH
	.DB 02H, 82H, 42H, 0C2H, 22H, 0A2H, 62H, 0E2H, 12H, 92H, 52H, 0D2H, 32H, 0B2H, 72H, 0F2H
	.DB 0AH, 8AH, 4AH, 0CAH, 2AH, 0AAH, 6AH, 0EAH, 1AH, 9AH, 5AH, 0DAH, 3AH, 0BAH, 7AH, 0FAH
	.DB 06H, 86H, 46H, 0C6H, 26H, 0A6H, 66H, 0E6H, 16H, 96H, 56H, 0D6H, 36H, 0B6H, 76H, 0F6H
	.DB 0EH, 8EH, 4EH, 0CEH, 2EH, 0AEH, 6EH, 0EEH, 1EH, 9EH, 5EH, 0DEH, 3EH, 0BEH, 7EH, 0FEH
	.DB 01H, 81H, 41H, 0C1H, 21H, 0A1H, 61H, 0E1H, 11H, 91H, 51H, 0D1H, 31H, 0B1H, 71H, 0F1H
	.DB 09H, 89H, 49H, 0C9H, 29H, 0A9H, 69H, 0E9H, 19H, 99H, 59H, 0D9H, 39H, 0B9H, 79H, 0F9H
	.DB 05H, 85H, 45H, 0C5H, 25H, 0A5H, 65H, 0E5H, 15H, 95H, 55H, 0D5H, 35H, 0B5H, 75H, 0F5H
	.DB 0DH, 8DH, 4DH, 0CDH, 2DH, 0ADH, 6DH, 0EDH, 1DH, 9DH, 5DH, 0DDH, 3DH, 0BDH, 7DH, 0FDH
	.DB 03H, 83H, 43H, 0C3H, 23H, 0A3H, 63H, 0E3H, 13H, 93H, 53H, 0D3H, 33H, 0B3H, 73H, 0F3H
	.DB 0BH, 8BH, 4BH, 0CBH, 2BH, 0ABH, 6BH, 0EBH, 1BH, 9BH, 5BH, 0DBH, 3BH, 0BBH, 7BH, 0FBH
	.DB 07H, 87H, 47H, 0C7H, 27H, 0A7H, 67H, 0E7H, 17H, 97H, 57H, 0D7H, 37H, 0B7H, 77H, 0F7H
	.DB 0FH, 8FH, 4FH, 0CFH, 2FH, 0AFH, 6FH, 0EFH, 1FH, 9FH, 5FH, 0DFH, 3FH, 0BFH, 7FH, 0FFH
#ENDIF
;
; SEND ONE BYTE
;
SD_PUT:
#IF ((SDMODE == SDMODE_CSIO) | (SDMODE == SDMODE_MK4))
	CALL	MIRROR		; MSB<-->LSB mirror bits, result in C
	CALL	SD_WAITTX	; MAKE SURE WE ARE DONE SENDING
	OUT0	(SD_TRDR),C	; PUT BYTE IN BUFFER
	IN0	A,(SD_CNTR)
	SET	4,A		; SET TRANSMIT ENABLE
	OUT0	(SD_CNTR),A
#ELSE
#IF (SDMODE == SDMODE_UART)
	XOR	$FF		; DI IS INVERTED ON UART
#ENDIF
	LD	C,A		; C=BYTE TO SEND
	LD	B,8		; SEND 8 BITS (LOOP 8 TIMES)
	LD	A,(SD_OPRVAL)	; LOAD CURRENT OPR VALUE
SD_PUT1:
	RRA			; PREPARE TO GET DATA BIT FROM CF
	RL	C		; ROTATE NEXT BIT FROM C INTO CF
	RLA			; ROTATE CF INTO A:0, SD_DO is OPR:0
	OUT	(SD_OPRREG),A	; ASSERT DATA BIT
	XOR	SD_CLK		; TOGGLE CLOCK
	OUT	(SD_OPRREG),A	; UPDATE CLOCK AND ASSERT DATA BIT
	XOR	SD_CLK		; TOGGLE CLOCK
	OUT	(SD_OPRREG),A	; UPDATE CLOCK
	DJNZ	SD_PUT1		; REPEAT FOR ALL 8 BITS
	LD	A,(SD_OPRVAL)	; LOAD CURRENT OPR VALUE
	OUT	(SD_OPRREG),A	; LEAVE WITH CLOCK LOW
#ENDIF
	RET			; DONE
;
; RECEIVE ONE BYTE
;
SD_GET:
#IF ((SDMODE == SDMODE_CSIO) | (SDMODE == SDMODE_MK4))
	CALL	SD_WAITTX	; MAKE SURE WE ARE DONE SENDING
	IN0	A,(CPU_CNTR)	; GET CSIO STATUS
	SET	5,A		; START RECEIVER
	OUT0	(CPU_CNTR),A
	CALL	SD_WAITRX
	IN0	A,(CPU_TRDR)	; GET RECEIVED BYTE
	CALL	MIRROR		; MSB<-->LSB MIRROR BITS
	LD	A,C		; KEEP RESULT
#ELSE
	LD	B,8		; RECEIVE 8 BITS (LOOP 8 TIMES)
	LD	A,(SD_OPRVAL)	; LOAD CURRENT OPR VALUE
SD_GET1:
	XOR	SD_CLK		; TOGGLE CLOCK
	OUT	(SD_OPRREG),A	; UPDATE CLOCK
	IN	A,(SD_INPREG)	; READ THE DATA WHILE CLOCK IS ACTIVE
  #IF ((SDMODE == SDMODE_JUHA) | (SDMODE == SDMODE_PPI))
	RLA			; ROTATE INP:7 INTO CF
  #ENDIF
  #IF (SDMODE == SDMODE_N8)
	RLA			; ROTATE INP:6 INTO CF
	RLA			; "
  #ENDIF
  #IF (SDMODE == SDMODE_UART)
	RLA			; ROTATE INP:5 INTO CF
	RLA			; "
	RLA			; "
  #ENDIF
  #IF (SDMODE == SDMODE_DSD)
	RRA			; ROTATE INP:0 INTO CF
  #ENDIF
	RL	C		; ROTATE CF INTO C:0
	LD	A,(SD_OPRVAL)	; BACK TO INITIAL VALUES (TOGGLE CLOCK)
	OUT	(SD_OPRREG),A	; DO IT
	DJNZ	SD_GET1		; REPEAT FOR ALL 8 BITS
	LD	A,C		; GET BYTE RECEIVED INTO A
#IF (SDMODE == SDMODE_UART)
	XOR	$FF		; DO IS INVERTED ON UART
#ENDIF
#ENDIF
	RET
;
;==================================================================================================
;   SD DISK DRIVER PROTOCOL IMPLEMENTATION
;==================================================================================================
;
; SELECT CARD AND WAIT FOR IT TO BE READY ($FF)
;
SD_WAITRDY:
	CALL	SD_SELECT	; SELECT CARD
	LD	DE,0		; LOOP MAX (TIMEOUT)
SD_WAITRDY1:
	CALL	SD_GET
	INC	A		; $FF -> $00
	RET	Z		; IF READY, RETURN
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SD_WAITRDY1	; KEEP TRYING UNTIL TIMEOUT
	XOR	A		; ZERO ACCUM
	DEC	A		; ACCUM := $FF TO SIGNAL ERROR
	RET			; TIMEOUT
;
; COMPLETE A TRANSACTION - PRESERVE AF
;
SD_DONE:
	PUSH	AF
	CALL	SD_DESELECT
	LD	A,$FF
	CALL	SD_PUT
	POP	AF
	RET
;
; SD_GETDATA
;
SD_GETDATA:
	PUSH	HL		; SAVE DESTINATION ADDRESS
	PUSH	BC		; SAVE LENGTH TO RECEIVE
	LD	DE,$7FFF	; LOOP MAX (TIMEOUT)
SD_GETDATA1:
	CALL	SD_GET
	CP	$FF		; WANT BYTE != $FF
	JR	NZ,SD_GETDATA2	; NOT $FF, MOVE ON
	DEC    DE
	BIT	7,D
	JR	Z,SD_GETDATA1	; KEEP TRYING UNTIL TIMEOUT
SD_GETDATA2:
	LD	(SD_TOK),A
	POP	DE		; RESTORE LENGTH TO RECEIVE
	POP	HL		; RECOVER DEST ADDRESS
	CP	$FE		; PACKET START?
	JR	NZ,SD_GETDATA4	; NOPE, ABORT, A HAS ERROR CODE
SD_GETDATA3:
	CALL	SD_GET		; GET NEXT BYTE
	LD	(HL),A		; SAVE IT
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SD_GETDATA3	; LOOP FOR ALL BYTES
	CALL	SD_GET		; DISCARD CRC BYTE 1
	CALL	SD_GET		; DISCARD CRC BYTE 2
	XOR	A		; RESULT IS ZERO
SD_GETDATA4:
	RET
;
; SD_PUTDATA
;
SD_PUTDATA:
	PUSH	HL		; SAVE SOURCE ADDRESS
	PUSH	BC		; SAVE LENGTH TO SEND
	
	LD	A,$FE		; PACKET START
	CALL	SD_PUT		; SEND IT

	POP	DE		; RECOVER LENGTH TO SEND
	POP	HL		; RECOVER SOURCE ADDRESS
SD_PUTDATA1:
	LD	A,(HL)		; GET NEXT BYTE TO SEND
	CALL	SD_PUT		; SEND IF
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SD_PUTDATA1	; LOOP FOR ALL BYTES
	LD	A,$FF		; DUMMY CRC BYTE
	CALL	SD_PUT
	LD	A,$FF		; DUMMY CRC BYTE
	CALL	SD_PUT
	LD	DE,$7FFF	; LOOP MAX (TIMEOUT)
SD_PUTDATA2:
	CALL	SD_GET
	CP	$FF		; WANT BYTE != $FF
	JR	NZ,SD_PUTDATA3	; NOT $FF, MOVE ON
	DEC    DE
	BIT	7,D
	JR	Z,SD_PUTDATA2	; KEEP TRYING UNTIL TIMEOUT
SD_PUTDATA3:
	AND	$1F
	LD	(SD_TOK),A
	CP	$05
	RET	NZ
	XOR	A
	RET
;
; SETUP COMMAND BUFFER
;
SD_SETCMD0:	; NO PARMS
	LD	HL,SD_CMDBUF
	LD	(HL),A
	INC	HL
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	A,$FF
	LD	(HL),A
	RET
;
SD_SETCMDP:	; W/ PARMS IN BC & DE
	CALL	SD_SETCMD0
	LD	HL,SD_CMDP0
	LD	(HL),B
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),E
	RET	
;
; EXECUTE A SD CARD COMMAND
;
SD_EXEC:
	CALL	SD_WAITRDY
	JP	NZ,SD_ERRRDYTO	; RETURN VIA READY TIMEOUT HANDLER
	XOR	A
	LD	(SD_RC),A
	LD	(SD_TOK),A
	LD	HL,SD_CMDBUF
	LD	E,6		; COMMANDS ARE 6 BYTES
SD_EXEC1:
	LD	A,(HL)
	CALL	SD_PUT
	INC	HL
	DEC	E
	JR	NZ,SD_EXEC1
	LD	DE,$100		; LOOP MAX (TIMEOUT)
	;LD	DE,$8000	; *DEBUG*
SD_EXEC2:
	CALL	SD_GET
	;CALL	PRTHEXBYTE	; *DEBUG*
	OR	A		; SET FLAGS
	JP	P,SD_EXEC3	; IF HIGH BIT IS 0, WE HAVE RESULT
	DEC	DE
	BIT	7,D
	JR	Z,SD_EXEC2
	;LD	(SD_RC),A	; *DEBUG*
	;CALL	SD_PRTTRN	; *DEBUG*
	JP	SD_ERRCMDTO
SD_EXEC3:
	LD	(SD_RC),A
#IF (SDTRACE >= 2)
	CALL	SD_PRTTRN
#ENDIF
#IF (DSKYENABLE)
	CALL	SD_DSKY
#ENDIF
	OR	A
	RET
;	
SD_EXECCMD0:	; EXEC COMMAND, NO PARMS
	CALL	SD_SETCMD0
	JR	SD_EXEC
;
SD_EXECCMDP:	; EXEC CMD W/ PARMS IN BC/DE
	CALL	SD_SETCMDP
	JR	SD_EXEC
;
; PUT CARD IN IDLE STATE
;
SD_GOIDLE:
	;CALL	SD_DONE			; SEEMS TO HELP SOME CARDS...

	; SMALL DELAY HERE HELPS SOME CARDS
	LD	DE,200			; 5 MILISECONDS
	CALL	VDELAY

	; PUT CARD IN IDLE STATE
	LD	A,SD_CMD0		; CMD0 = ENTER IDLE STATE
	CALL	SD_SETCMD0
	LD	A,$95
	LD	(SD_CMDBUF+5),A		; SET CRC=$95
	CALL	SD_EXEC			; EXEC CMD
	CALL	SD_DONE			; SIGNAL COMMAND COMPLETE
	JP	P,SD_GOIDLE1		; VALID RESULT, CHECK IT
	CALL	SD_EXEC			; 2ND TRY
	CALL	SD_DONE			; SIGNAL COMMAND COMPLETE
	RET	M			; COMMAND FAILED
;
SD_GOIDLE1:	; COMMAND OK, CHECK FOR EXPECTED RESULT
	DEC	A			; MAP EXPECTED $01 -> $00
	RET	Z			; IF $00, ALL GOOD, RETURN
	JP	SD_ERRCMD		; OTHERWISE, HANDLE COMMAND ERROR
;
; INIT CARD
;
SD_INITCARD:
	CALL	SD_SETUP		; DO HARDWARE SETUP/INIT
	RET	NZ
;	
	; WAKE UP THE CARD, KEEP DIN HI (ASSERTED) AND /CS HI (DEASSERTED)
	LD	B,$10	; MIN 74 CLOCKS REQUIRED, WE USE 128 ($10 * 8)
SD_INITCARD000:
	LD	A,$FF
	PUSH	BC
	CALL	SD_PUT
	POP	BC
	DJNZ	SD_INITCARD000

	;CALL	SD_SELECT

	; PUT CARD IN IDLE STATE
	CALL	SD_GOIDLE
	RET	NZ			; FAILED

SD_INITCARD00:
	LD	A,SD_TYPESDSC		; ASSUME SDSC CARD TYPE
	LD	HL,(SD_TYPEPTR)		; LOAD THE CARD TYPE ADDRESS
	LD	(HL),A			; SAVE IT

	; CMD8 IS REQUIRED FOR V2 CARDS.  FAILURE HERE IS OK AND
	; JUST MEANS THAT IT IS A V1.X CARD
	LD	A,SD_CMD8
	LD	BC,0
	LD	D,1			; VHS=1, 2.7-3.6V
	LD	E,$AA			; CHECK PATTERN
	CALL	SD_SETCMDP
	LD	A,$87
	LD	(SD_CMDBUF+5),A		; SET CRC=$87
	CALL	SD_EXEC			; EXEC CMD
	CALL	M,SD_DONE		; CLOSE COMMAND IF ERROR
	RET	M			; ABORT DUE TO PROCESSING ERROR
	AND	~$01			; IGNORE BIT 0 (IDLE)
	JR	NZ,SD_INITCARD0		; CMD RESULT ERR, SKIP AHEAD
	
	; CMD8 WORKED, NEED TO CONSUME CMD8 RESPONSE BYTES (4)
	CALL	SD_GET
	CALL	SD_GET
	CALL	SD_GET
	CALL	SD_GET
	
SD_INITCARD0:
	CALL	SD_DONE

	LD	A,0
	LD	(SD_LCNT),A
SD_INITCARD1:
	; CALL SD_APP_OP_COND UNTIL CARD IS READY (NOT IDLE)
	LD	DE,200		; 5 MILLISECONDS
	CALL	VDELAY
	LD	A,SD_CMD55	; APP CMD IS NEXT
	CALL	SD_EXECCMD0
	CALL	SD_DONE
	RET	M		; ABORT ON PROCESSING ERROR
	AND	~$01		; ONLY 0 (OK) OR 1 (IDLE) ARE OK
	JP	NZ,SD_ERRCMD
	LD	A,SD_ACMD41	; SD_APP_OP_COND
	LD	BC,$4000	; INDICATE WE SUPPORT HC
	LD	DE,$0000
	CALL	SD_EXECCMDP
	CALL	SD_DONE
	RET	M		; ABORT ON PROCESSING ERROR
	CP	$00		; INIT DONE?
	JR	Z,SD_INITCARD2	; YUP, MOVE ON
	CP	$01		; IDLE?
	JP	NZ,SD_ERRCMD	; NOPE, MUST BE CMD ERROR, ABORT
	LD	HL,SD_LCNT	; POINT TO LOOP COUNTER
	DEC	(HL)		; DECREMENT LOOP COUNTER
	JR	NZ,SD_INITCARD1	; LOOP UNTIL COUNTER EXHAUSTED
	LD	A,$FF		; SIGNAL TIMEOUT
	OR	A
	JP	SD_ERRINITTO
	
SD_INITCARD2:
	; CMD58 RETURNS THE 32 BIT OCR REGISTER, WE WANT TO CHECK
	; BIT 30, IF SET THIS IS SDHC/XC CARD
	LD	A,SD_CMD58
	CALL	SD_EXECCMD0
	CALL	NZ,SD_DONE
	RET	M		; ABORT ON PROCESSING ERROR
	JP	NZ,SD_ERRCMD
	
	; CMD58 WORKED, GET OCR DATA AND SET CARD TYPE
	CALL	SD_GET		; BITS 31-24
	AND	$40		; ISOLATE BIT 30 (CCS)
	JR	Z,SD_INITCARD21	; NOT HC/XC, BYPASS
	LD	HL,(SD_TYPEPTR)	; LOAD THE CARD TYPE ADDRESS
	LD	A,SD_TYPESDHC	; CARD TYPE = SDHC
	LD	(HL),A		; SAVE IT
SD_INITCARD21:
	CALL	SD_GET		; BITS 23-16, DISCARD
	CALL	SD_GET		; BITS 15-8, DISCARD
	CALL	SD_GET		; BITS 7-0, DISCARD
	CALL	SD_DONE
	
	; SET OUR DESIRED BLOCK LENGTH (512 BYTES)
	LD	A,SD_CMD16	; SET_BLOCK_LEN
	LD	BC,0
	LD	DE,512
	CALL	SD_EXECCMDP
	CALL	SD_DONE
	RET	M		; ABORT ON PROCESSING ERROR
	JP	NZ,SD_ERRCMD
	
#IF (SDTRACE >= 2)
	CALL	NEWLINE
	LD	DE,SDSTR_SDTYPE
	CALL	WRITESTR
	LD	HL,(SD_TYPEPTR)
	LD	A,(HL)
	CALL	PRTHEXBYTE
#ENDIF

#IF ((SDMODE == SDMODE_CSIO) | (SDMODE == SDMODE_MK4))
	CALL	SD_WAITTX	; MAKE SURE WE ARE DONE SENDING
	XOR	A		; NOW SET CSIO PORT TO FULL SPEED
	OUT	(CPU_CNTR),A
#ENDIF

	XOR	A		; A = 0 (STATUS = OK)
	LD	HL,(SD_STATPTR)	; LOAD STATUS ADDRESS
	LD	(HL),A		; SAVE IT
	RET			; RETURN WITH A=0, AND Z SET
	
;
; GET AND PRINT CSD, CID
;
SD_PRTINFO:
	CALL	SD_PRTPREFIX
	
	; PRINT CARD TYPE
	PRTS(" TYPE=$")
	LD	HL,(SD_TYPEPTR)
	LD	A,(HL)
	LD	DE,SDSTR_TYPEMMC
	CP	SD_TYPEMMC
	JR	Z,SD_PRTINFO1
	LD	DE,SDSTR_TYPESDSC
	CP	SD_TYPESDSC
	JR	Z,SD_PRTINFO1
	LD	DE,SDSTR_TYPESDHC
	CP	SD_TYPESDHC
	JR	Z,SD_PRTINFO1
	LD	DE,SDSTR_TYPEUNK
SD_PRTINFO1:
	CALL	WRITESTR

	LD	A,SD_CMD10	; SEND_CID
	CALL	SD_EXECCMD0
	CALL	NZ,SD_DONE
	JP	NZ,SD_ERRCMD	; ABORT IF PROBLEM
	LD	BC,16		; 16 BYTES OF CID
	LD	HL,SD_BUF
	CALL	SD_GETDATA
	CALL	SD_DONE

#IF (SDTRACE >= 2)
	CALL	SD_PRTPREFIX
	LD	DE,SDSTR_CID
	CALL	WRITESTR
	LD	DE,SD_BUF
	LD	A,16
	CALL	PRTHEXBUF
#ENDIF

	; PRINT PRODUCT NAME
	PRTS(" NAME=$")
	LD	B,5
	LD	HL,SD_BUF + 3
SD_PRTINFO2:
	LD	A,(HL)
	CALL	COUT
	INC	HL
	DJNZ	SD_PRTINFO2

	LD	A,SD_CMD9	; SEND_CSD
	CALL	SD_EXECCMD0
	CALL	NZ,SD_DONE
	JP	NZ,SD_ERRCMD	; ABORT IF PROBLEM
	LD	BC,16		; 16 BYTES OF CSD
	LD	HL,SD_BUF
	CALL	SD_GETDATA
	CALL	SD_DONE

#IF (SDTRACE >= 2)
	CALL	SD_PRTPREFIX
	LD	DE,SDSTR_CSD
	CALL	WRITESTR
	LD	DE,SD_BUF
	LD	A,16
	CALL	PRTHEXBUF
#ENDIF

	; PRINT SIZE
	PRTS(" SIZE=$")			; PREFIX
	PUSH	IX			; SAVE IX
	LD	IX,SD_BUF		; POINT IX TO BUFFER
;
	LD	HL,(SD_TYPEPTR)		; POINT TO CARD TYPE
	LD	A,(HL)			; GET CARD TYPE
	CP	SD_TYPESDSC		; CSD V1?
	JR	Z,SD_PRTINFO3		; HANDLE V1
	CP	SD_TYPESDHC		; CSD V2?
	JR	Z,SD_PRTINFO4		; HANDLE V2
	JR	SD_PRTINFO6		; UNK, CAN'T HANDLE

SD_PRTINFO3:	; PRINT SIZE FOR V1 CARD
	LD	A,(IX+6)		; GET C_SIZE MSB
	AND	%00000011		; MASK OFF TOP 6 BITS (NOT PART OF C_SIZE)
	LD	C,A			; MSB -> C
	LD	D,(IX+7)		; D
	LD	E,(IX+8)		; LSB -> E
	LD	B,6			; RIGHT SHIFT WHOLE THING BY 6 BITS
SD_PRTINFO3A:
	SRA	C			; SHIFT MSB
	RR	D			; SHIFT NEXT BYTE
	RR	E			; SHIFT LSB
	DJNZ	SD_PRTINFO3A		; LOOP TILL DONE
	PUSH	DE			; DE = C_SIZE
	LD	A,(IX+9)		; GET C_SIZE_MULT MSB
	LD	B,(IX+10)		; GET C_SIZE_MULT LSB
	SLA	B			; SHIFT LEFT MSB
	RLA				; SHIFT LEFT LSB
	AND	%00000111		; ISOLATE RELEVANT BITS
	LD	C,A			; C := C_SIZE_MULT
	LD	A,(IX+5)		; GET READ_BL_LEN
	AND	%00001111		; ISLOATE RELEVANT BITS
	LD	B,A			; B := READ_BL_LEN
	LD	A,18			; ASSUME RIGHT SHIFT OF 18
	SUB	B			; REDUCE BY READ_BL_LEN BITS
	SUB	C			; REDUCE BY C_SIZE_MULT BITS
	LD	B,A			; PUT IN LOOP COUNTER
	POP	HL			; RECOVER C_SIZE
	JR	Z,SD_PRTINFO5		; HANDLE ZERO BIT SHIFT CASE
SD_PRTINFO3B:
	SRA	H			; SHIFT MSB
	RR	L			; SHIFT LSB
	DJNZ	SD_PRTINFO3B		; LOOP TILL DONE
	JR	SD_PRTINFO5		; GO TO PRINT ROUTINE
;
SD_PRTINFO4:	; PRINT SIZE FOR V2 CARD
	LD	A,(IX + 7)		; GET C_SIZE MSB TO A
	AND	%00111111		; ISOLATE RELEVANT BITS
	LD	H,(IX + 8)		; GET NEXT BYTE TO H
	LD	L,(IX + 9)		; GET C_SIZE LSB TO L
	SRA	A			; RIGHT SHIFT MSB BY ONE
	RR	H			; RIGHT SHIFT NEXT BYTE BY ONE
	RR	L			; RIGHT SHIFT LSB BY ONE
	JR	SD_PRTINFO5
;
SD_PRTINFO5:	; COMMON CODE TO PRINT RESULTANT SIZE (IN HL)
	CALL	PRTDEC			; PRINT SIZE IN DECIMAL
	JR	SD_PRTINFO7		; FINISH UP
;
SD_PRTINFO6:	; UNKNOWN CARD TYPE
	PRTC('?')			; UNKNOWN SIZE
;
SD_PRTINFO7:
	PRTS("MB$")			; PRINT SIZE SUFFIX
	POP	IX			; RESTORE IX
;	
	CALL	SD_CHKWP		; WRITE PROTECTED?
	JR	Z,SD_PRTINFO8		; NOPE, BYPASS
	CALL	PC_SPACE		; SEPARATOR
	PRTX(SDSTR_STWRTPROT)		; TELL THE USER
;
SD_PRTINFO8:
	RET				; DONE
;
; CHECK THE SD CARD, ATTEMPT TO REINITIALIZE IF NEEDED
;
SD_CHKCARD:
	LD	HL,(SD_STATPTR)		; LOAD STATUS ADDRESS
	LD	A,(HL)			; GET STATUS
	OR	A			; SET FLAGS
	CALL	NZ,SD_INITCARD		; INIT CARD IF NOT READY
	RET				; RETURN WITH STATUS IN A

SD_RDSEC:
	CALL	SD_CHKCARD	; CHECK / REINIT CARD AS NEEDED
	RET	NZ

	CALL	SD_SETADDR	; SETUP BLOCK ADDRESS

	LD	A,SD_CMD17	; READ_SINGLE_BLOCK
	CALL	SD_EXECCMDP	; EXEC CMD WITH BLOCK ADDRESS AS PARM
	CALL	NZ,SD_DONE	; TRANSACTION DONE IF ERROR OCCURRED
	RET	M		; ABORT ON PROCESSING ERROR
	JP	NZ,SD_ERRCMD	; FAIL IF NON-ZERO RC
	
	LD	HL,(DIOBUF)
	LD	BC,512		; LENGTH TO READ
	CALL	SD_GETDATA	; GET THE BLOCK
	CALL	SD_DONE
	JP	NZ,SD_ERRDATA	; DATA XFER ERROR
	RET
;
; WRITE ONE SECTOR
;
SD_WRSEC:
	CALL	SD_CHKCARD	; CHECK / REINIT CARD AS NEEDED
	RET	NZ

	CALL	SD_SETADDR	; SETUP BLOCK ADDRESS

	LD	A,SD_CMD24	; WRITE_BLOCK
	CALL	SD_EXECCMDP	; EXEC CMD WITH BLOCK ADDRESS AS PARM
	CALL	NZ,SD_DONE	; TRANSACTION DONE IF ERROR OCCURRED
	RET	M		; ABORT ON PROCESSING ERROR
	JP	NZ,SD_ERRCMD	; FAIL IF NON-ZERO RC
	
	LD	HL,(DIOBUF)	; SETUP DATA SOURCE ADDRESS
	LD	BC,512		; LENGTH TO WRITE
	CALL	SD_PUTDATA	; PUT THE BLOCK
	CALL	SD_DONE
	JP	NZ,SD_ERRDATA	; DATA XFER ERROR
	RET
;
;	
;
SD_SETADDR:
	LD	HL,(SD_TYPEPTR)
	LD	A,(HL)
	CP	SD_TYPESDSC
	JR	Z,SD_SETADDRSDSC
	CP	SD_TYPESDHC
	JR	Z,SD_SETADDRSDHC
	CALL	PANIC

;
; SDSC CARDS USE A BYTE OFFSET
;
; TT:SS = BC:DE -> TS:S0, THEN LEFT SHIFT ONE BIT
SD_SETADDRSDSC:
	LD	BC,(HSTTRK)
	LD	DE,(HSTSEC)
	LD	B,C
	LD	C,D
	LD	D,E
	LD	E,0
	SLA	E
	RL	D
	RL	C
	RL	B
	RET
;
; SDHC CARDS USE SIMPLE LBA, NO TRANSLATION NEEDED
;
SD_SETADDRSDHC:
	LD	BC,(HSTTRK)	; LBA HIGH WORD
	LD	DE,(HSTSEC)	; LBA LOW WORD
	RET			; DONE
;
; HANDLE READY TIMEOUT ERROR
;
SD_ERRRDYTO:
	LD	A,SD_STRDYTO
	JR	SD_CARDERR
;
SD_ERRINITTO:
	LD	A,SD_STINITTO
	JR	SD_CARDERR
;
SD_ERRCMDTO:
	LD	A,SD_STCMDTO
	JR	SD_CARDERR
;
SD_ERRCMD:
	LD	A,SD_STCMDERR
	JR	SD_CARDERR
;
SD_ERRDATA:
	LD	A,SD_STDATAERR
	JR	SD_CARDERR
;
SD_ERRDATATO:
	LD	A,SD_STDATATO
	JR	SD_CARDERR
;
SD_ERRCRC:
	LD	A,SD_STCRCERR
	JR	SD_CARDERR
;
SD_NOMEDIA:
	LD	A,SD_STNOMEDIA
	JR	SD_CARDERR
;
SD_WRTPROT:
	LD	A,SD_STWRTPROT
	JR	SD_CARDERR
;
; GENERIC ERROR HANDLER
;
SD_CARDERR:
	PUSH	HL			; IS THIS NEEDED?
	LD	HL,(SD_STATPTR)
	LD	(HL),A
	POP	HL			; IS THIS NEEDED?
#IF (SDTRACE >= 2)
	CALL	NEWLINE
	PUSH	AF			; IS THIS NEEDED?
	PRTC('<')
	CALL	SD_PRTSTAT
	PRTC('>')
	POP	AF			; IS THIS NEEDED?
#ENDIF
	OR	A
	RET
;
; PRINT DIAGNONSTIC PREFIX
;
SD_PRTPREFIX:
	CALL	NEWLINE
	LD	DE,SDSTR_PREFIX
	CALL	WRITESTR
	PUSH	AF
	LD	A,(SD_UNIT)
	ADD	A,'0'
	CALL	COUT
	POP	AF
	CALL	PC_COLON
	RET
;
; PRINT STATUS STRING
;
SD_PRTSTAT:
	PUSH	HL			; IS THIS NEEDED?
	LD	HL,(SD_STATPTR)
	LD	A,(HL)
	POP	HL			; IS THIS NEEDED?
	OR	A
	LD	DE,SDSTR_STOK
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STNOTRDY
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STRDYTO
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STINITTO
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STCMDTO
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STCMDERR
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STDATAERR
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STDATATO
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STCRCERR
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STNOMEDIA
	JR	Z,SD_PRTSTAT1
	INC	A
	LD	DE,SDSTR_STWRTPROT
	JR	Z,SD_PRTSTAT1
	LD	DE,SDSTR_STUNK
;
SD_PRTSTAT1:
	CALL	WRITESTR
	PUSH	HL			; IS THIS NEEDED?
	LD	HL,(SD_STATPTR)
	LD	A,(HL)
	POP	HL			; IS THIS NEEDED?
	CP	SD_STCMDERR
	JR	Z,SD_PRTCMDERR
	CP	SD_STDATAERR
	JR	Z,SD_PRTDATAERR
	RET
;
SD_PRTCMDERR:
	LD	A,(SD_RC)
	JR	SD_PRTCODE
;
SD_PRTDATAERR:
	LD	A,(SD_TOK)
	JR	SD_PRTCODE
;
SD_PRTCODE:
	CALL	PC_LPAREN
	PUSH	AF
	LD	A,(SD_CMD)
	CALL	PRTHEXBYTE
	LD	DE,SDSTR_ARROW
	CALL	WRITESTR
	POP	AF
	CALL	PRTHEXBYTE
	CALL	PC_RPAREN
	RET
;
; PRT COMMAND TRACE
;
SD_PRTTRN:
	PUSH	AF
	
	CALL	SD_PRTPREFIX

	LD	DE,SD_CMDBUF
	LD	A,6
	CALL	PRTHEXBUF
	LD	DE,SDSTR_ARROW
	CALL	WRITESTR

	LD	DE,SDSTR_RC
	CALL	WRITESTR
	LD	A,(SD_RC)
	CALL	PRTHEXBYTE
	CALL	PC_SPACE
	
	LD	DE,SDSTR_TOK
	CALL	WRITESTR
	LD	A,(SD_TOK)
	CALL	PRTHEXBYTE
	
	POP	AF

	RET

;
; DISPLAY COMMAND, LOW ORDER WORD OF PARMS, AND RC
;
#IF (DSKYENABLE)
SD_DSKY:
	PUSH	AF
	LD	HL,DSKY_HEXBUF
	LD	A,(SD_CMD)
	LD	(HL),A
	INC	HL
	LD	A,(SD_CMDP2)
	LD	(HL),A
	INC	HL
	LD	A,(SD_CMDP3)
	LD	(HL),A
	INC	HL
	LD	A,(SD_RC)
	CALL	DSKY_HEXOUT
	POP	AF
	RET
#ENDIF
;
;
;
SDSTR_PREFIX	.TEXT	"SD$"
SDSTR_ARROW	.TEXT	" -> $"
SDSTR_RC	.TEXT	"RC=$"
SDSTR_TOK	.TEXT	"TOK=$"
SDSTR_CSD	.TEXT	" CSD=$"
SDSTR_CID	.TEXT	" CID=$"
SDSTR_STOK	.TEXT	"OK$"
SDSTR_SDTYPE	.TEXT	"SD CARD TYPE: $"
;
SDSTR_STNOTRDY	.TEXT	"NOT READY$"
SDSTR_STRDYTO	.TEXT	"READY TIMEOUT$"
SDSTR_STINITTO	.TEXT	"INITIALIZATION TIMEOUT$"
SDSTR_STCMDTO	.TEXT	"COMMAND TIMEOUT$"
SDSTR_STCMDERR	.TEXT	"COMMAND ERROR$"
SDSTR_STDATAERR	.TEXT	"DATA ERROR$"
SDSTR_STDATATO	.TEXT	"DATA TIMEOUT$"
SDSTR_STCRCERR	.TEXT	"CRC ERROR$"
SDSTR_STNOMEDIA	.TEXT	"NO MEDIA$"
SDSTR_STWRTPROT	.TEXT	"WRITE PROTECTED$"
SDSTR_STUNK	.TEXT	"UNKNOWN$"
SDSTR_TYPEUNK	.TEXT	"UNK$"
SDSTR_TYPEMMC	.TEXT	"MMC$"
SDSTR_TYPESDSC	.TEXT	"SDSC$"
SDSTR_TYPESDHC	.TEXT	"SDHC/XC$"
;
;==================================================================================================
;   SD DISK DRIVER - DATA
;==================================================================================================
;
SD_STATLST	.FILL	SD_UNITCNT,0	; LIST OF UNIT STATUSES (2 UNITS)
SD_STATPTR	.DW	SD_STATLST	; ADDRESS OF STATUS FOR CURRENT UNIT
SD_TYPELST	.FILL	SD_UNITCNT,0	; LIST OF CARD TYPES (2 UNITS)
SD_TYPEPTR	.Dw	SD_TYPELST	; ADDRESS OF CARD TYPE FOR CURRENT UNIT
SD_UNIT		.DB	0		; CURRENT UNIT NUMBER
SD_RC		.DB	0		; RETURN CODE FROM CMD
SD_TOK		.DB	0		; TOKEN FROM DATA XFR
SD_OPRVAL	.DB	0		; CURRENT OPR REG VALUE
SD_LCNT		.DB	0		; LOOP COUNTER
;
SD_BUF		.FILL	16,0		; WORK BUFFER
;
SD_CMDBUF:				; START OF STD CMD BUF
SD_CMD		.DB	0
SD_CMDP0	.DB	0
SD_CMDP1	.DB	0
SD_CMDP2	.DB	0
SD_CMDP3	.DB	0
SD_CMDCRC	.DB	0
