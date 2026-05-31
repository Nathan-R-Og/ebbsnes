.MEMORYMAP                      ; Begin describing the system architecture.
DEFAULTSLOT 0
SLOT 0 START $8000 SIZE $08000 ; ROM
; TODO: Is there a way to specify the bank here? Currently it seems as if it
; thinks these are all in bank $00...
; In ebbsnes.sym we have:
;   00:0000 RAM_USAGE_SLOT_1_BANK_0_START
;   00:083f RAM_USAGE_SLOT_1_BANK_0_END
;   00:2000 RAM_USAGE_SLOT_2_BANK_0_START
;   00:2001 RAM_USAGE_SLOT_2_BANK_0_END
;   00:0000 RAM_USAGE_SLOT_3_BANK_0_START
;   00:0001 RAM_USAGE_SLOT_3_BANK_0_END
SLOT 1 START $0000 SIZE $02000 ; RAM: low RAM, mirrored in each bank
SLOT 2 START $2000 SIZE $0A000 ; RAM: Rest of bank $7E
SLOT 3 START $0000 SIZE $10000 ; RAM: Bank $7F
.ENDME          ; End MemoryMap definition

.ROMBANKSIZE $8000              ; Every ROM bank is 32 KBytes in size
.ROMBANKS 32                    ; 32 x 32KB ==> 1MB of ROM

; Have all long pointers point to FastROM mirrors
.BASE $80

;joypad bits
;l
;h
.EQU PAD_B      %10000000
.EQU PAD_A      %01000000
.EQU PAD_SELECT %00100000
.EQU PAD_START  %00010000
.EQU PAD_UP     %00001000
.EQU PAD_DOWN   %00000100
.EQU PAD_RIGHT  %00000010
.EQU PAD_LEFT   %00000001

;flags
.EQU FLAG_CARRY %00000001
.EQU FLAG_ZERO %00000010
.EQU FLAG_INTERRUPT %00000100
.EQU FLAG_DECIMAL %00001000
.EQU FLAG_INDEX16 %00010000
.EQU FLAG_ACCUM16 %00100000
.EQU FLAG_OVERFLOW %01000000
.EQU FLAG_NEGATIVE %10000000

.EQU INIDISP $2100
OBJSEL  = $2101
OAMADDL     =   $2102   ;   OAM Address Registers (Low)   single   write   f-blank, v-blank
OAMADDH     =   $2103   ;   OAM Address Registers (High)   single   write   f-blank, v-blank
OAMDATA     =   $2104   ;   OAM Data Write Register   single   write   f-blank, v-blank
.EQU BGMODE $2105
.EQU BG1SC $2107 ;BG 1 Tilemap address
.EQU BG2SC $2108
.EQU BG3SC $2109
.EQU BG4SC $210A
.EQU BG12NBA $210B
.EQU BG34NBA $210C
.EQU BG1HOFS $210D
.EQU BG1VOFS $210E
.EQU BG2HOFS $210F
.EQU BG2VOFS $2110
.EQU BG3HOFS $2111
.EQU BG3VOFS $2112
.EQU BG4HOFS $2113
.EQU BG4VOFS $2114
.EQU VMAIN $2115
.EQU VMADDL $2116
.EQU VMADDH $2117
.EQU VMDATAL $2118
.EQU VMDATAH $2119
;Palette Selection
.EQU CGADD $2121
;Write 1 == Color data reg ?bbbbbgg
;Write 2 == Color data reg gggrrrrr
.EQU CGDATA $2122
.EQU W12SEL $2123
.EQU W34SEL $2124
.EQU TM $212c

NMITIMEN = $4200

.EQU MDMAEN $420B   ;   DMA Enable Register   single   write   any time
RDNMI       =   $4210   ;   Interrupt Flag Registers   single   read   any time
.EQU HVBJOY $4212


JOY1L       =   $4218   ;   Controller Port Data Registers (Pad 1 - Low)   single   read   any time that is not auto-joypad
JOY1H       =   $4219   ;   Controller Port Data Registers (Pad 1 - High)   single   read   any time that is not auto-joypad
JOY2L       =   $421A   ;   Controller Port Data Registers (Pad 2 - Low)   single   read   any time that is not auto-joypad
JOY2H       =   $421B   ;   Controller Port Data Registers (Pad 2 - High)   single   read   any time that is not auto-joypad
JOY3L       =   $421C   ;   Controller Port Data Registers (Pad 3 - Low)   single   read   any time that is not auto-joypad
JOY3H       =   $421D   ;   Controller Port Data Registers (Pad 3 - High)   single   read   any time that is not auto-joypad
JOY4L       =   $421E   ;   Controller Port Data Registers (Pad 4 - Low)   single   read   any time that is not auto-joypad
JOY4H       =   $421F   ;   Controller Port Data Registers (Pad 4 - High)   single   read   any time that is not auto-joypad

.EQU DMAP0 $4300   ;   (H)DMA Control Register
.EQU BBAD0 $4301   ;   (H)DMA Destination Register
.EQU A1T0L $4302   ;   (H)DMA Source Address Registers
.EQU A1T0H $4303   ;   (H)DMA Source Address Registers
.EQU A1B0 $4304   ;   (H)DMA Source Address Registers
.EQU DAS0L $4305   ;   (H)DMA Size Registers (Low)
.EQU DAS0H $4306   ;   (H)DMA Size Registers (High)
.EQU DASB0 $4307   ;   HDMA Indirect Address Registers
.EQU A2A0L $4308   ;   HDMA Mid Frame Table Address Registers (Low)
.EQU A2A0H $4309   ;   HDMA Mid Frame Table Address Registers (High)
.EQU NTLR0 $430A   ;   HDMA Line Counter Register
DMAP1       =   $4310   ;   (H)DMA Control Register
BBAD1       =   $4311   ;   (H)DMA Destination Register
A1T1L       =   $4312   ;   (H)DMA Source Address Registers
A1T1H       =   $4313   ;   (H)DMA Source Address Registers
A1B1        =   $4314   ;   (H)DMA Source Address Registers
DAS1L       =   $4315   ;   (H)DMA Size Registers (Low)
DAS1H       =   $4316   ;   (H)DMA Size Registers (High)
DASB1       =   $4317   ;   HDMA Indirect Address Registers
A2A1L       =   $4318   ;   HDMA Mid Frame Table Address Registers (Low)
A2A1H       =   $4319   ;   HDMA Mid Frame Table Address Registers (High)
NTLR1       =   $431A   ;   HDMA Line Counter Register
.FUNCTION TM_ARGS(bg1, bg2, bg3, bg4, obj) (obj << 4) | (bg4 << 3) | (bg3 << 2) | (bg2 << 1) | bg1


MOSAIC      =   $2106   ;   Mosaic Register   single   write   f-blank, v-blank, h-blank
M7SEL       =   $211A   ;   Mode 7 Settings Register   single   write   f-blank, v-blank
M7A         =   $211B   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
M7B         =   $211C   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
M7C         =   $211D   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
M7D         =   $211E   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
M7X         =   $211F   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
M7Y         =   $2120   ;   Mode 7 Matrix Registers   dual   write   f-blank, v-blank, h-blank
WOBJSEL     =   $2125   ;   Window Mask Settings Registers   single   write   f-blank, v-blank, h-blank
WH0         =   $2126   ;   Window Position Registers (WH0)   single   write   f-blank, v-blank, h-blank
WH1         =   $2127   ;   Window Position Registers (WH1)   single   write   f-blank, v-blank, h-blank
WH2         =   $2128   ;   Window Position Registers (WH2)   single   write   f-blank, v-blank, h-blank
WH3         =   $2129   ;   Window Position Registers (WH3)   single   write   f-blank, v-blank, h-blank
WBGLOG      =   $212A   ;   Window Mask Logic registers (BG)   single   write   f-blank, v-blank, h-blank
WOBJLOG     =   $212B   ;   Window Mask Logic registers (OBJ)   single   write   f-blank, v-blank, h-blank
TS          =   $212D   ;   Screen Destination Registers   single   write   f-blank, v-blank, h-blank
TMW         =   $212E   ;   Window Mask Destination Registers   single   write   f-blank, v-blank, h-blank
TSW         =   $212F   ;   Window Mask Destination Registers   single   write   f-blank, v-blank, h-blank
CGWSEL      =   $2130   ;   Color Math Registers   single   write   f-blank, v-blank, h-blank
CGADSUB     =   $2131   ;   Color Math Registers   single   write   f-blank, v-blank, h-blank
COLDATA     =   $2132   ;   Color Math Registers   single   write   f-blank, v-blank, h-blank
SETINI      =   $2133   ;   Screen Mode Select Register   single   write   f-blank, v-blank, h-blank
MPYL        =   $2134   ;   Multiplication Result Registers   single   read   f-blank, v-blank, h-blank
MPYM        =   $2135   ;   Multiplication Result Registers   single   read   f-blank, v-blank, h-blank
MPYH        =   $2136   ;   Multiplication Result Registers   single   read   f-blank, v-blank, h-blank
SLHV        =   $2137   ;   Software Latch Register   single      any time
OAMDATAREAD =   $2138   ;   OAM Data Read Register   dual   read   f-blank, v-blank
VMDATALREAD =   $2139   ;   VRAM Data Read Register (Low)   single   read   f-blank, v-blank
VMDATAHREAD =   $213A   ;   VRAM Data Read Register (High)   single   read   f-blank, v-blank
CGDATAREAD  =   $213B   ;   CGRAM Data Read Register   dual   read   f-blank, v-blank
OPHCT       =   $213C   ;   Scanline Location Registers (Horizontal)   dual   read   any time
OPVCT       =   $213D   ;   Scanline Location Registers (Vertical)   dual   read   any time
STAT77      =   $213E   ;   PPU Status Register   single   read   any time
STAT78      =   $213F   ;   PPU Status Register   single   read   any time
APUIO0      =   $2140   ;   APU IO Registers   single   both   any time
APUIO1      =   $2141   ;   APU IO Registers   single   both   any time
APUIO2      =   $2142   ;   APU IO Registers   single   both   any time
APUIO3      =   $2143   ;   APU IO Registers   single   both   any time
WMDATA      =   $2180   ;   WRAM Data Register   single   both   any time
WMADDL      =   $2181   ;   WRAM Address Registers   single   write   any time
WMADDM      =   $2182   ;   WRAM Address Registers   single   write   any time
WMADDH      =   $2183   ;   WRAM Address Registers   single   write   any time