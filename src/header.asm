;header

.SNESHEADER
ID "SNES"
NAME "EARTHBOUND BEGINNINGS"  ; Program Title - can't be over 21 bytes,

;.db $23
SLOWROM
LOROM

;ROM + SRAM
CARTRIDGETYPE $02

;ROM size: 1<<N kilobytes, rounded up (so 8=256KB, 12=4096KB and so on)
ROMSIZE 10 ; 1MB should be enough

;RAM size: 1<<N kilobytes (so 1=2KB, 5=32KB, and so on)
SRAMSIZE 3 ; 8KB sram (just like the original)

; $01 = U.S.
COUNTRY 1

;developer id
LICENSEECODE $69 ; nice

;rom version (first)
VERSION 0

;Checksum complement (Checksum ^ $FFFF)
;Checksum
.ENDSNES


.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
COP 0
BRK 0
ABORT 0
NMI nmi
;blank
IRQ 0
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
COP 0
;blank
ABORT 0
NMI 0
RESET reset                     ; where execution starts
IRQBRK 0
.ENDEMUVECTOR