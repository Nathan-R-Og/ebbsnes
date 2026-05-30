.MACRO incbinRange args arg_file, start, end
    .incbin arg_file SKIP start READ end - start
.ENDM

.MACRO BBP_INCBIN args arg_file_gfx, arg_file_pal
    @gfx:
    .incbin arg_file_gfx
    @gfx_END:
    @pal:
    .incbin arg_file_pal
    @pal_END:
.ENDM

.MACRO DoLoadPalette args label, at, size
    ldx #loword(label)
    stx z_L
    ldx #hiword(label)
    stx z_L+2
    ldx #size
    stx func_ram
    ldx #at
    jsr LoadPalette
.ENDM

.MACRO DoLoadGfx1bpp args label, at, size
    ldx #loword(label)
    stx z_L
    ldx #hiword(label)
    stx z_L+2
    ldy #size
    sty func_ram
    ldy #at
    jsr LoadGfx_1bpp
.ENDM

.MACRO DoLoadGfx args label, at, size
    ldx #loword(label)
    stx z_L
    ldx #hiword(label)
    stx z_L+2
    ldy #size
    sty func_ram
    ldy #at
    jsr LoadGfx
.ENDM

.MACRO BankswitchCHR_Address args addr
    lda #lobyte(addr)
    ldx #hibyte(addr)
    jsr BankswitchCHRFromTable
.ENDM

.MACRO LoadPalette_Address args addr
    lda #lobyte(addr)
    ldx #hibyte(addr)
    jsr LoadPalette
.ENDM


.EQU NMI_COMMANDS_SKIP 0
.EQU NMI_COMMANDS_NOTHING 1
.EQU NMI_COMMANDS_BRANCH 2
.EQU NMI_COMMANDS_GOTO 3
.EQU NMI_COMMANDS_UPDATE_PALETTE 4
.EQU NMI_COMMANDS_PPU_WRITE 5
.EQU NMI_COMMANDS_PPU_WRITE_32 6
.EQU NMI_COMMANDS_PPU_WRITE_ADDRS 7
.EQU NMI_COMMANDS_PPU_WRITE_BYTE 8
.EQU NMI_COMMANDS_PPU_READ 9
.EQU NMI_COMMANDS_PPU_READ_TEXT 10

.EQU NMI_MODE_SKIP $80
stopText = 0
newLine = 1
waitThenOverwrite = 2
pauseText = 3
t_nop = 5

.macro goto args ta
    .byte 4,lobyte(ta),hibyte(ta)
.endm
.macro set_pos args tx,ty
    .byte $20,tx,ty
.endm
.macro print_string args ta
    .byte $21,lobyte(ta),hibyte(ta)
.endm
.macro repeatTile args ta,tb
    .byte $22,ta,tb
.endm
.macro print_number args ta, tb, tc
    .byte $23,lobyte(ta),hibyte(ta),tb,tc
.endm