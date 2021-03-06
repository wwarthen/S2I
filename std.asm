; ~/RomWBW/branches/s100/Source/std.asm 1/19/2013 dwg - 
;

; The purpose of this file is to define generic symbols and to include
; the appropriate std-*.inc file to bring in platform specifics.

; There are four classes of systems supported by N8VEM.
; 1. N8VEM 	Platforms that include ECB interface
; 2. ZETA	Genrally N8VEM-like, but no ECB
; 3. N8		Generally N8VEM-like bt 180 and extra embedded devices
; 4. S100	Assumes Z80 Master CPU Card

; All the classes require certain generic definitions, and these are
; defined here prior to the inclusion of platform specific .inc files.

; It is unfortunate, but all the possible config items must be defined
; here because the config gets read before the specific std-*.inc's

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
TRUE		.EQU 	1
FALSE		.EQU 	0
;
; DEPRECATED STUFF!!!
;
DIOPLT		.EQU	0		; DEPRECATED!!!
VDUMODE		.EQU	0		; DEPRECATED!!!
BIOSSIZE	.EQU	0100H		; DEPRECATED!!!
;
; PRIMARY HARDWARE PLATFORMS
;
PLT_N8VEM	.EQU	1		; N8VEM ECB Z80 SBC
PLT_ZETA	.EQU	2		; ZETA Z80 SBC
PLT_N8		.EQU	3		; N8 (HOME COMPUTER) Z180 SBC
PLT_S2I		.EQU	4		; SCSI2IDE
PLT_S100	.EQU	5		; S100COMPUTERS Z80 based system
;
; BOOT STYLE
;
BT_MENU		.EQU	1	; WAIT FOR MENU SELECTION AT LOADER PROMPT
BT_AUTO		.EQU	2	; AUTO SELECT BOOT_DEFAULT AFTER BOOT_TIMEOUT
;
; RAM DISK INITIALIZATION OPTIONS
;
CLR_NEVER	.EQU	0		; NEVER CLEAR RAM DISK
CLR_AUTO	.EQU	1		; CLEAR RAM DISK IF INVALID DIR ENTRIES
CLR_ALWAYS	.EQU	2		; ALWAYS CLEAR RAM DISK
;
; DISK MAP SELECTION OPTIONS
;
DM_ROM		.EQU	1		; ROM DRIVE PRIORITY
DM_RAM		.EQU	2		; RAM DRIVE PRIORITY
DM_FD		.EQU	3		; FLOPPY DRIVE PRIORITY
DM_IDE		.EQU	4		; IDE DRIVE PRIORITY
DM_PPIDE	.EQU	5		; PPIDE DRIVE PRIORITY
DM_SD		.EQU	6		; SD DRIVE PRIORITY
DM_PRPSD	.EQU	7		; PROPIO SD DRIVE PRIORITY
DM_PPPSD	.EQU	8		; PROPIO SD DRIVE PRIORITY
DM_HDSK		.EQU	9		; SIMH HARD DISK DRIVE PRIORITY
;
; FLOPPY DISK MEDIA SELECTIONS (ID'S MUST BE INDEX OF ENTRY IN FCD_TBL)
;
FDM720		.EQU	0		; 3.5" FLOPPY, 720KB, 2 SIDES, 80 TRKS, 9 SECTORS
FDM144		.EQU	1		; 3.5" FLOPPY, 1.44MB, 2 SIDES, 80 TRKS, 18 SECTORS
FDM360		.EQU	2		; 5.25" FLOPPY, 360KB, 2 SIDES, 40 TRKS, 9 SECTORS
FDM120		.EQU	3		; 5.25" FLOPPY, 1.2MB, 2 SIDES, 80 TRKS, 15 SECTORS
FDM111		.EQU	4		; 8" FLOPPY, 1.11MB, 2 SIDES, 74 TRKS, 15 SECTORS
;
; MEDIA ID VALUES
;
MID_NONE	.EQU	0
MID_MDROM	.EQU	1
MID_MDRAM	.EQU	2
MID_HD		.EQU	3
MID_FD720	.EQU	4
MID_FD144	.EQU	5
MID_FD360	.EQU	6
MID_FD120	.EQU	7
MID_FD111	.EQU	8
;
; FD MODE SELECTIONS
;
FDMODE_NONE	.equ	0		; FD modes defined in std-*.inc
FDMODE_DIO	.EQU	1		; DISKIO V1
FDMODE_ZETA	.EQU	2		; ZETA
FDMODE_DIDE	.EQU	3		; DUAL IDE
FDMODE_N8	.EQU	4		; N8
FDMODE_DIO3	.EQU	5		; DISKIO V3
;
; IDE MODE SELECTIONS
;
IDEMODE_NONE	.EQU	0
IDEMODE_DIO	.EQU	1		; DISKIO V1
IDEMODE_DIDE	.EQU	2		; DUAL IDE
;
; PPIDE MODE SELECTIONS
;
PPIDEMODE_NONE	.EQU	0
PPIDEMODE_STD	.EQU	1		; STANDARD N8VEM PARALLEL PORT
PPIDEMODE_DIO3	.EQU	2		; DISKIO V3 PARALLEL PORT
;
; SD MODE SELECTIONS
;
SDMODE_NONE	.EQU	0
SDMODE_JUHA	.EQU	1		; JUHA MINI BOARD
SDMODE_N8	.EQU	2		; N8-2511, UNMODIFIED
SDMODE_CSIO	.EQU	3		; N8-2312 OR N8-2511 MODIFIED
SDMODE_PPI	.EQU	4		; PPISD MINI BOARD
SDMODE_UART	.EQU	5		; S2ISD
SDMODE_DSD	.EQU	6		; DUAL SD
SDMODE_MK4	.EQU	7		; MARK IV
;
; CONSOLE TERMINAL TYPE CHOICES
;
TERM_TTY	.EQU	0
TERM_ANSI	.EQU	1
TERM_WYSE	.EQU	2
TERM_VT52	.EQU	3
;
; EMULATION TYPES
;
EMUTYP_NONE	.EQU	0
EMUTYP_TTY	.EQU	1
EMUTYP_ANSI	.EQU	2
;
; SCSI DEVICE PERSONALITY CHOICES
;
S2I_PER_N8VEM	.EQU	1
S2I_PER_ST125N	.EQU	2
;
; SYSTEM GENERATION SETTINGS
;
SYS_CPM		.EQU	1		; CPM (IMPLIES BDOS + CCP)
SYS_ZSYS	.EQU	2		; ZSYSTEM OS (IMPLIES ZSDOS + ZCPR)
;
DOS_BDOS	.EQU	1		; BDOS
DOS_ZDDOS	.EQU	2		; ZDDOS VARIANT OF ZSDOS
DOS_ZSDOS	.EQU	3		; ZSDOS
;
CP_CCP		.EQU	1		; CCP COMMAND PROCESSOR
CP_ZCPR		.EQU	2		; ZCPR COMMAND PROCESSOR
;
; CONFIGURE DOS (DOS) AND COMMAND PROCESSOR (CP) BASED ON SYSTEM SETTING (SYS)
;
#IFNDEF BLD_SYS
SYS		.EQU	SYS_CPM
#ELSE
SYS		.EQU	BLD_SYS
#ENDIF
;
#IF (SYS == SYS_CPM)
DOS		.EQU	DOS_BDOS
CP		.EQU	CP_CCP
#DEFINE		OSLBL	"CP/M-80 2.2"
#ENDIF
;
#IF (SYS == SYS_ZSYS)
DOS		.EQU	DOS_ZSDOS
CP		.EQU	CP_ZCPR
#DEFINE		OSLBL	"ZSDOS 1.1"
#ENDIF
;
; INCLUDE VERSION AND BUILD SETTINGS
;
#INCLUDE "ver.inc"			; ADD BIOSVER
;
#INCLUDE "build.inc"			; INCLUDE USER CONFIG, ADD VARIANT, TIMESTAMP, & ROMSIZE
;
; INCLUDE PLATFORM SPECIFIC HARDWARE DEFINITIONS
;
#IF ((PLATFORM == PLT_N8VEM) | (PLATFORM == PLT_ZETA))
#INCLUDE "n8vem.inc"
#ENDIF
;
#IF (PLATFORM == PLT_S2I)
#INCLUDE "s2i.inc"
#ENDIF
;
#IF (PLATFORM == PLT_N8)
#INCLUDE "n8.inc"
#ENDIF
;
#IF (PLATFORM == PLT_S100)
;
#DEFINE S100_IOB			; WBW: FORCED ON TO MAKE BUILD WORK!
;
#IFDEF S100_CPU
#INCLUDE "S100CPU.INC"
#ENDIF
;
#IFDEF S100_IOB
#INCLUDE "S100IOB.INC"
#ENDIF
;
#IFDEF S100_RRF
#INCLUDE "S100RRF.INC"
#ENDIF
;
#IFDEF S100_DIDE
#INCLUDE "S100DIDE.INC"
#ENDIF
;
#ENDIF
;
; CHARACTER DEVICE FUNCTIONS
;
CF_INIT		.EQU	0
CF_IN		.EQU	1
CF_IST		.EQU	2
CF_OUT		.EQU	3
CF_OST		.EQU	4
;
; DISK OPERATIONS
;
DOP_READ	.EQU	0		; READ OPERATION
DOP_WRITE	.EQU	1		; WRITE OPERATION
DOP_FORMAT	.EQU	2		; FORMAT OPERATION
DOP_READID	.EQU	3		; READ ID OPERATION
;
; DISK DRIVER FUNCTIONS
;
DF_READY	.EQU	1
DF_SELECT	.EQU	2
DF_READ		.EQU	3
DF_WRITE	.EQU	4
DF_FORMAT	.EQU	5
;
; BIOS FUNCTIONS
;
BF_CIO		.EQU	$00
BF_CIOIN	.EQU	BF_CIO + 0	; CHARACTER INPUT
BF_CIOOUT	.EQU	BF_CIO + 1	; CHARACTER OUTPUT
BF_CIOIST	.EQU	BF_CIO + 2	; CHARACTER INPUT STATUS
BF_CIOOST	.EQU	BF_CIO + 3	; CHARACTER OUTPUT STATUS
BF_CIOCFG	.EQU	BF_CIO + 4	; CHARACTER I/O CONFIG
;
BF_DIO		.EQU	$10
BF_DIORD	.EQU	BF_DIO + 0	; DISK READ
BF_DIOWR	.EQU	BF_DIO + 1	; DISK WRITE
BF_DIOST	.EQU	BF_DIO + 2	; DISK STATUS
BF_DIOMED	.EQU	BF_DIO + 3	; DISK MEDIA
BF_DIOID	.EQU	BF_DIO + 4	; DISK IDENTIFY
BF_DIOGETBUF	.EQU	BF_DIO + 8	; DISK GET BUFFER ADR
BF_DIOSETBUF	.EQU	BF_DIO + 9	; DISK SET BUFFER ADR
;
BF_RTC		.EQU	$20
BF_RTCGETTIM	.EQU	BF_RTC + 0	; GET TIME
BF_RTCSETTIM	.EQU	BF_RTC + 1	; SET TIME
BF_RTCGETBYT	.EQU	BF_RTC + 2	; GET NVRAM BYTE BY INDEX
BF_RTCSETBYT	.EQU	BF_RTC + 3	; SET NVRAM BYTE BY INDEX
BF_RTCGETBLK	.EQU	BF_RTC + 4	; GET NVRAM DATA BLOCK
BF_RTCSETBLK	.EQU	BF_RTC + 5	; SET NVRAM DATA BLOCK
;
BF_EMU		.EQU	$30
BF_EMUIN	.EQU	BF_EMU + 0	; EMULATOR CHARACTER INPUT
BF_EMUOUT	.EQU	BF_EMU + 1	; EMULATOR CHARACTER OUTPUT
BF_EMUIST	.EQU	BF_EMU + 2	; EMULATOR CHARACTER INPUT STATUS
BF_EMUOST	.EQU	BF_EMU + 3	; EMULATOR CHARACTER OUTPUT STATUS
BF_EMUCFG	.EQU	BF_EMU + 4	; EMULATOR CHARACTER I/O CONFIG
BF_EMUINI	.EQU	BF_EMU + 8	; INITIALIZE EMULATION
BF_EMUQRY	.EQU	BF_EMU + 9	; QUERY EMULATION STATUS
;
BF_VDA		.EQU	$40
BF_VDAINI	.EQU	BF_VDA + 0	; INITIALIZE VDU
BF_VDAQRY	.EQU	BF_VDA + 1	; QUERY VDU STATUS
BF_VDARES	.EQU	BF_VDA + 2	; SOFT RESET VDU
BF_VDASCS	.EQU	BF_VDA + 3	; SET CURSOR STYLE
BF_VDASCP	.EQU	BF_VDA + 4	; SET CURSOR POSITION
BF_VDASAT	.EQU	BF_VDA + 5	; SET CHARACTER ATTRIBUTE
BF_VDASCO	.EQU	BF_VDA + 6	; SET CHARACTER COLOR
BF_VDAWRC	.EQU	BF_VDA + 7	; WRITE CHARACTER
BF_VDAFIL	.EQU	BF_VDA + 8	; FILL
BF_VDASCR	.EQU	BF_VDA + 9	; SCROLL
BF_VDAKST	.EQU	BF_VDA + 10	; GET KEYBOARD STATUS
BF_VDAKFL	.EQU	BF_VDA + 11	; FLUSH KEYBOARD BUFFER
BF_VDAKRD	.EQU	BF_VDA + 12	; READ KEYBOARD
;
BF_SYS		.EQU	$F0
BF_SYSGETCFG	.EQU	BF_SYS + 0	; GET CONFIGURATION DATA BLOCK
BF_SYSSETCFG	.EQU	BF_SYS + 1	; SET CONFIGURATION DATA BLOCK
BF_SYSBNKCPY	.EQU	BF_SYS + 2	; COPY TO/FROM RAM/ROM MEMORY BANK
BF_SYSGETVER	.EQU	BF_SYS + 3	; GET VERSION OF HBIOS
;
; MEMORY LAYOUT
;
CPM_LOC		.EQU	0D000H			; CONFIGURABLE: LOCATION OF CPM FOR RUNNING SYSTEM
CPM_SIZ		.EQU	2F00H			; SIZE OF CPM IMAGE (CCP + BDOS + CBIOS (INCLUDING DATA))
CPM_END		.EQU	CPM_LOC + CPM_SIZ
;
CCP_LOC		.EQU	CPM_LOC			; START OF COMMAND PROCESSOR
CCP_SIZ		.EQU	800H
CCP_END		.EQU	CCP_LOC + CCP_SIZ
;
BDOS_LOC	.EQU	CCP_END			; START OF BDOS
BDOS_SIZ	.EQU	0E00H
BDOS_END	.EQU	BDOS_LOC + BDOS_SIZ
;
CBIOS_LOC	.EQU	BDOS_END
CBIOS_SIZ	.EQU	CPM_END - CBIOS_LOC
CBIOS_END	.EQU	CBIOS_LOC + CBIOS_SIZ
;
CPM_ENT		.EQU	CBIOS_LOC
;
HB_LOC		.EQU	CPM_END
HB_SIZ		.EQU	100H
HB_END		.EQU	HB_LOC + HB_SIZ
;
MON_LOC		.EQU	0C000H			; LOCATION OF MONITOR FOR RUNNING SYSTEM
MON_SIZ		.EQU	01000H			; SIZE OF MONITOR BINARY IMAGE
MON_END		.EQU	MON_LOC + MON_SIZ
MON_DSKY	.EQU	MON_LOC			; MONITOR ENTRY (DSKY)
MON_UART	.EQU	MON_LOC + 3		; MONITOR ENTRY (UART)
;
CBIOS_BOOT	.EQU	CBIOS_LOC + 0
CBIOS_WBOOT	.EQU	CBIOS_LOC + 3
CBIOS_CONST	.EQU	CBIOS_LOC + 6
CBIOS_CONIN	.EQU	CBIOS_LOC + 9
CBIOS_CONOUT	.EQU	CBIOS_LOC + 12
CBIOS_LIST	.EQU	CBIOS_LOC + 15
CBIOS_PUNCH	.EQU	CBIOS_LOC + 18
CBIOS_READER	.EQU	CBIOS_LOC + 21
CBIOS_HOME	.EQU	CBIOS_LOC + 24
CBIOS_SELDSK	.EQU	CBIOS_LOC + 27
CBIOS_SETTRK	.EQU	CBIOS_LOC + 30
CBIOS_SETSEC	.EQU	CBIOS_LOC + 33
CBIOS_SETDMA	.EQU	CBIOS_LOC + 36
CBIOS_READ	.EQU	CBIOS_LOC + 39
CBIOS_WRITE	.EQU	CBIOS_LOC + 42
CBIOS_LISTST	.EQU	CBIOS_LOC + 45
CBIOS_SECTRN	.EQU	CBIOS_LOC + 48
;
; EXTENDED CBIOS FUNCTIONS
;
CBIOS_BNKSEL	.EQU	CBIOS_LOC + 51
CBIOS_GETDSK	.EQU	CBIOS_LOC + 54
CBIOS_SETDSK	.EQU	CBIOS_LOC + 57
CBIOS_GETINFO	.EQU	CBIOS_LOC + 60
;
; PLACEHOLDERS FOR FUTURE CBIOS EXTENSIONS
;
CBIOS_RSVD1	.EQU	CBIOS_LOC + 63
CBIOS_RSVD2	.EQU	CBIOS_LOC + 76
CBIOS_RSVD3	.EQU	CBIOS_LOC + 69
CBIOS_RSVD4	.EQU	CBIOS_LOC + 72
;
CDISK:	 	.EQU 	00004H		; LOC IN PAGE 0 OF CURRENT DISK NUMBER 0=A,...,15=P
IOBYTE:	 	.EQU 	00003H		; LOC IN PAGE 0 OF I/O DEFINITION BYTE.
;
; MEMORY CONFIGURATION
;
MSIZE		.EQU	59		; CP/M VERSION MEMORY SIZE IN KILOBYTES
;
; "BIAS" IS ADDRESS OFFSET FROM 3400H FOR MEMORY SYSTEMS
; THAN 16K (REFERRED TO AS "B" THROUGHOUT THE TEXT) 
;
BIAS:	 	.EQU 	(MSIZE-20)*1024
CCP:	 	.EQU 	3400H+BIAS	; BASE OF CCP
BDOS:	 	.EQU 	CCP+806H	; BASE OF BDOS
BIOS:	 	.EQU 	CCP+1600H	; BASE OF BIOS
CCPSIZ:		.EQU	00800H
;
#IF (PLATFORM == PLT_N8VEM)
  #DEFINE 	PLATFORM_NAME	"N8VEM Z80"
#ENDIF
#IF (PLATFORM == PLT_ZETA)
  #DEFINE 	PLATFORM_NAME	"ZETA Z80"
#ENDIF
#IF (PLATFORM == PLT_N8)
  #DEFINE 	PLATFORM_NAME	"N8 Z180"
#ENDIF
#IF (PLATFORM == PLT_S2I)
  #DEFINE 	PLATFORM_NAME	"SCSI2IDE Z80"
#ENDIF
#IF (PLATFORM == PLT_S100)
  #DEFINE	PLATFORM_NAME	"S100"
#ENDIF
;
#IF (DSKYENABLE)
  #DEFINE	DSKYLBL	", DSKY"
#ELSE
  #DEFINE	DSKYLBL	""
#ENDIF
;
#IF (VDUENABLE)
  #DEFINE	VDULBL	", VDU"
#ELSE
  #DEFINE	VDULBL	""
#ENDIF
;
#IF (CVDUENABLE)
  #DEFINE	CVDULBL	", CVDU"
#ELSE
  #DEFINE	CVDULBL	""
#ENDIF
;
#IF (UPD7220ENABLE)
  #DEFINE	UPD7220LBL	", UPD7220"
#ELSE
  #DEFINE	UPD7220LBL	""
#ENDIF
;
#IF (N8VENABLE)
  #DEFINE	N8VLBL	", N8V"
#ELSE
  #DEFINE	N8VLBL	""
#ENDIF
;
#IF (FDENABLE)
  #IF (FDMAUTO)
      #DEFINE	FDLBL	", FLOPPY (AUTOSIZE)"
  #ELSE
    #IF (FDMEDIA == FDM720)
      #DEFINE	FDLBL	", FLOPPY (360KB)"
    #ENDIF
    #IF (FDMEDIA == FDM111)
      #DEFINE	FDLBL	", FLOPPY (1.11MB)"
    #ENDIF
  #ENDIF
#ELSE
  #DEFINE	FDLBL	""
#ENDIF
;
#IF (IDEENABLE)
  #IF (IDEMODE == IDEMODE_DIO)
    #DEFINE	IDELBL		", IDE (DISKIO)"
  #ENDIF
  #IF (IDEMODE == IDEMODE_DIDE)
    #DEFINE	IDELBL		", IDE (DUAL IDE)"
  #ENDIF
#ELSE
  #DEFINE	IDELBL		""
#ENDIF
;
#IF (PPIDEENABLE)
    #DEFINE	PPIDELBL	", PPIDE"
#ELSE
  #DEFINE	PPIDELBL	""
#ENDIF
;
#IF (SDENABLE)
  #DEFINE	SDLBL		", SD CARD"
#ELSE
  #DEFINE	SDLBL		""
#ENDIF
;
#IF (IDEENABLE)
  #DEFINE	IDELBL	", IDE"
#ELSE
  #DEFINE	IDELBL	""
#ENDIF
;
#IF (PPIDEENABLE)
  #DEFINE	PPIDELBL	", PPIDE"
#ELSE
  #DEFINE	PPIDELBL	""
#ENDIF

#IF (SDENABLE)
  #DEFINE	SDLBL		", SD CARD"
#ELSE
  #DEFINE	SDLBL		""
#ENDIF

#IF (HDSKENABLE)
  #DEFINE	HDSKLBL		", SIMH DISK"
#ELSE
  #DEFINE	HDSKLBL		""
#ENDIF

#IF (PRPENABLE)
  #IF (PRPCONENABLE & PRPSDENABLE)
    #DEFINE	PRPLBL		", PROPIO (CONSOLE, SD CARD)"
  #ENDIF
  #IF (PRPCONENABLE & !PRPSDENABLE)
    #DEFINE	PRPLBL		", PROPIO (CONSOLE)"
  #ENDIF
  #IF (!PRPCONENABLE & PRPSDENABLE)
    #DEFINE	PRPLBL		", PROPIO (SD CARD)"
  #ENDIF
  #IF (!PRPCONENABLE & !PRPSDENABLE)
    #DEFINE	PRPLBL		", PROPIO ()"
  #ENDIF
#ELSE
  #DEFINE	PRPLBL		""
#ENDIF

#IF (PPPENABLE)
  #IF (PPPCONENABLE & PPPSDENABLE)
    #DEFINE	PPPLBL		", PARPORTPROP (CONSOLE, SD CARD)"
  #ENDIF
  #IF (PPPCONENABLE & !PPPSDENABLE)
    #DEFINE	PPPLBL		", PARPORTPROP (CONSOLE)"
  #ENDIF
  #IF (!PPPCONENABLE & PPPSDENABLE)
    #DEFINE	PPPLBL		", PARPORTPROP (SD CARD)"
  #ENDIF
  #IF (!PPPCONENABLE & !PPPSDENABLE)
    #DEFINE	PPPLBL		", PARPORTPROP ()"
  #ENDIF
#ELSE
  #DEFINE	PPPLBL		""
#ENDIF

#IFDEF (HISTENABLE)
	#DEFINE	HISTLBL		", HIST"
#ELSE
	#DEFINE	HISTLBL		""
#ENDIF

	.ECHO	"Configuration: "
	.ECHO	PLATFORM_NAME
	.ECHO	DSKYLBL
	.ECHO	VDULBL
	.ECHO	FDLBL
	.ECHO	IDELBL
	.ECHO	PPIDELBL
	.ECHO	SDLBL
	.ECHO	PRPLBL
	.ECHO	PPPLBL
	.ECHO	HISTLBL
	.ECHO	"\n"
;
; HELPER MACROS
;
#DEFINE	PRTC(C)	CALL PRTCH \ .DB C			; PRINT CHARACTER C TO CONSOLE - PRTC('X')
#DEFINE	PRTS(S)	CALL PRTSTRD \ .DB S			; PRINT STRING S TO CONSOLE - PRTD("HELLO")
#DEFINE	PRTX(X) CALL PRTSTRI \ .DW X			; PRINT STRING AT ADDRESS X TO CONSOLE - PRTI(STR_HELLO)
;
#DEFINE	XIO_PRTC(C)	CALL XIO_PRTCH \ .DB C	; PRINT CHARACTER C TO CONSOLE - PRTC('X')
#DEFINE	XIO_PRTS(S)	CALL XIO_PRTSTRD \ .DB S	; PRINT STRING S TO CONSOLE - PRTD("HELLO")
#DEFINE	XIO_PRTX(X)	CALL XIO_PRTSTRI \ .DW X	; PRINT STRING AT ADDRESS X TO CONSOLE - PRTI(STR_HELLO)
