;
;==================================================================================================
;   ROMWBW 2.X CONFIGURATION FOR SCSI2IDE 11/26/2012
;==================================================================================================
;
; BUILD CONFIGURATION OPTIONS
;
CPUFREQ		.EQU	8		; IN MHZ, USED TO COMPUTE DELAY FACTORS
RAMSIZE		.EQU	32		; SIZE OF RAM IN KB, MUST MATCH YOUR HARDWARE!!!
;
DEFCON		.EQU	CIODEV_UART	; DEFAULT CONSOLE DEVICE (LOADER AND MONITOR): CIODEV_UART, CIODEV_VDU, DIODEV_PRPCON
;
BAUDRATE	.EQU	38400		; IN BPS: 1200, 9600, 38400, ..., 115200
;
S2I_TRACE	.EQU	2		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (DEBUG)
S2I_PER		.EQU	S2I_PER_N8VEM	; PERSONALITY (N8VEM, ST125N)
S2I_PDMA	.EQU	TRUE		; PSEUDO DMA (TRUE, FALSE)
S2I_LUNCNT	.EQU	2		; NUMBER OF LUNS (1-7)
S2I_LUNSIZ	.EQU	20		; SIZE OF EACH LUN (IN MB)
;
UARTENABLE	.EQU	TRUE		; TRUE FOR UART SUPPORT (ALMOST ALWAYS WANT THIS TO BE TRUE)
UARTFIFO	.EQU	TRUE		; TRUE ENABLES UART FIFO (16550 ASSUMED, N8VEM AND ZETA ONLY)
UARTAFC		.EQU	FALSE		; TRUE ENABLES AUTO FLOW CONTROL (YOUR TERMINAL/UART MUST SUPPORT RTS/CTS FLOW CONTROL!!!)
;
PPIDEENABLE	.EQU	TRUE		; TRUE FOR PPIDE SUPPORT (DO NOT COMBINE WITH DSKYENABLE)
PPIDEIOB	.EQU	$80		; PPIDE IOBASE
PPIDETRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPIDEENABLE = TRUE)
PPIDE8BIT	.EQU	FALSE		; USE IDE 8BIT TRANSFERS (PROBABLY ONLY WORKS FOR CF CARDS!)
PPIDECAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
PPIDESLOW	.EQU	FALSE		; ADD DELAYS TO HELP PROBLEMATIC HARDWARE (TRY THIS IF PPIDE IS UNRELIABLE)
;
DSKYENABLE	.EQU	FALSE		; TRUE FOR DSKY SUPPORT (DO NOT COMBINE WITH PPIDE)
;
SDENABLE	.EQU	TRUE		; TRUE FOR SD SUPPORT
SDMODE		.EQU	SDMODE_UART	; SDMODE_JUHA, SDMODE_CSIO, SDMODE_UART, SDMODE_PPI, SDMODE_DSD
SDTRACE		.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
SDCAPACITY	.EQU	64		; CAPACITY OF DEVICE (IN MB)
SDCSIOFAST	.EQU	FALSE		; TABLE-DRIVEN BIT INVERTER
;
VDUENABLE	.EQU	FALSE		; TRUE FOR VDU BOARD SUPPORT
CVDUENABLE	.EQU	FALSE		; TRUE FOR CVDU BOARD SUPPORT
UPD7220ENABLE	.EQU	FALSE		; TRUE FOR uPD7220 BOARD SUPPORT
N8VENABLE	.EQU	FALSE		; TRUE FOR N8 (TMS9918) VIDEO/KBD SUPPORT
FDENABLE	.EQU	FALSE		; TRUE FOR FLOPPY SUPPORT
IDEENABLE	.EQU	FALSE		; TRUE FOR IDE SUPPORT
PRPENABLE	.EQU	FALSE		; TRUE FOR PROPIO SD SUPPORT (FOR N8VEM PROPIO ONLY!)
PPPENABLE	.EQU	FALSE		; TRUE FOR PARPORTPROP SUPPORT
HDSKENABLE	.EQU	FALSE		; TRUE FOR SIMH HDSK SUPPORT
