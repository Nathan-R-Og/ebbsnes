.BANK 0
.ORG $0000

.EQU BG1_GFX $0000
.EQU BG2_GFX $1000
.EQU BG3_GFX $2000
.EQU BG4_GFX $3000
.EQU BG1_MAP $4000
.EQU BG2_MAP $4800
.EQU BG3_MAP $5000
.EQU BG4_MAP $5800
.EQU SPR_GFX $6000

.include "src/header.asm"

reset:
    .include "src/init.asm"
    sep #$30

    lda #%10000001 ;joypad autoread
    sta NMITIMEN

    ;bgmode == 0
    lda #%00001000
    sta BGMODE

    ; Test that far memory (banks $7e, $7f) are working correctly
    rep #$20
    lda #$aabb
    sta.l test_7e
    ina
    sta.l test_7f

    sep #$20
    rep #$10

    ; ldx #2
    ; @jump1:
    ; bit PPUSTATUS
    ; bpl @jump1
    ; dex
    ; bne @jump1
    ;jsr DoOAMDMA.WaitVblank
    ;jsr DoOAMDMA.WaitVblank

    jsr MemoryInit

    ;set up screen
    ;bg1+2 graphics at $2000
    ;go until $3000
    ;2 * $1000
    lda #((BG2_GFX >> 12) << 4) | (BG1_GFX >> 12)
    sta BG12NBA
    ;bg3+4 graphics at $0000
    ;go until $800
    ;0 * $1000
    lda #((BG4_GFX >> 12) << 4) | (BG3_GFX >> 12)
    sta BG34NBA

    lda #(BG1_MAP >> 10) << 2
    sta BG1SC
    ;bg2 tilemap at $3000
    ;go until $3800
    ;12 * $400
    lda #(BG2_MAP >> 10) << 2
    sta BG2SC
    ;bg3 tilemap at $0800
    ;go until $1000
    ;2 * $400
    lda #(BG3_MAP >> 10) << 2
    sta BG3SC
    ;bg4 tilemap at $1000
    ;go until $1800
    ;4 * $400
    lda #(BG4_MAP >> 10) << 2
    sta BG4SC
    ;bg1 tilemap at $1800
    ;go until $2000
    ;6 * $400

    stz W12SEL
    lda #%1010
    stz W34SEL

    lda #%10000000
    sta VMAIN

;clear vram
    stz VMADDL
    stz VMADDH
    ldx #$6000 ;size
    @ClearTilemap:
    stz VMDATAL
    stz VMDATAH
    dex
    bne @ClearTilemap



    ;set scroll
    stz BG1HOFS
    stz BG1HOFS
    stz BG2HOFS
    stz BG2HOFS
    stz BG3HOFS
    stz BG3HOFS
    stz BG4HOFS
    stz BG4HOFS
    stz BG1VOFS
    stz BG1VOFS
    stz BG2VOFS
    stz BG2VOFS
    stz BG3VOFS
    stz BG3VOFS
    stz BG4VOFS
    stz BG4VOFS


    DoLoadGfx GFXTEST@gfx, BG1_GFX+$400, GFXTEST@gfx_END-GFXTEST@gfx
    rep #FLAG_ACCUM16
    lda #$0000
    tay
    tax
    sep #FLAG_ACCUM16

    DoLoadGfx GFXTEST_spr@gfx, SPR_GFX, GFXTEST_spr@gfx_END-GFXTEST_spr@gfx
    rep #FLAG_ACCUM16
    lda #$0000
    tay
    tax

    ;load title palette (old)
    lda #loword(Title_Palette_Old)
    sta z_L
    lda #hiword(Title_Palette_Old)
    sta z_L+2
    jsl LoadPaletteFrom

    jsl OT0_DefaultTransition

    sep #FLAG_ACCUM16

    stz VMADDL
    lda #hibyte(BG1_MAP)
    sta VMADDH

    rep #FLAG_ACCUM16
    lda #loword(produced_by_TEST)
    sta z_L
    lda #hiword(produced_by_TEST)
    sta z_L+2

    ldy #0
    @copytiles:
    sep #FLAG_ACCUM16
    rep #FLAG_INDEX16
    lda [z_L], y
    sta VMDATAL
    lda #8
    sta VMDATAH
    iny
    cpy #$3b0
    bne @copytiles


    ; ;turn on layers
    lda #TM_ARGS(1, 1, 1, 0, 1)
    sta TM

    lda #1
    sta OBJSEL

    lda #%00001111 ;screen on
    sta INIDISP

    sep #FLAG_ACCUM16

    ldx #60
    jsl WaitXFrames_Min1_JSL

    ;lda #lobyte(produced_by_tiles)
    ;ldx #hibyte(produced_by_tiles)



    jsl B31_0e30

    ;do oam dma
    ;this doesnt really do much other than clearing the sprites
	jsr DoOAMDMA

    ; cli
main_loop:
    wai

	; Copy OAM data via DMA
	jsr DoOAMDMA

    ; lda object_count
    ; cmp #32
    ; bcs @no_snow_spawn
    ; jsr Rand
    ; cmp #$fb
    ; bcc @no_snow_spawn

    ; ;get last object index
    ; ;object_count *= 8

    ; lda object_count
    ; asl
    ; asl
    ; asl
    ; tax

    ; jsr CreateNewObject

    ; inc object_count
    ; @no_snow_spawn:


    ; ;bg1_scrx += 25
    ; clc
    ; lda bg1_scrx
    ; adc #25
    ; sta bg1_scrx
    ; lda bg1_scrx+1
    ; adc #0
    ; sta bg1_scrx+1

    ; ;bg1_scry += 25
    ; clc
    ; lda bg1_scry
    ; adc #25
    ; sta bg1_scry
    ; lda bg1_scry+1
    ; adc #0
    ; sta bg1_scry+1


    ; ;bg2_scrx -= 25
    ; sec
    ; lda bg2_scrx
    ; sbc #25
    ; sta bg2_scrx
    ; lda bg2_scrx+1
    ; sbc #0
    ; sta bg2_scrx+1

    ; ;bg2_scry += 25
    ; clc
    ; lda bg2_scry
    ; adc #25
    ; sta bg2_scry
    ; lda bg2_scry+1
    ; adc #0
    ; sta bg2_scry+1

    ; ;load into registers
    ; lda bg1_scrx+1
    ; sta BG1HOFS
    ; lda bg1_scrx
    ; sta BG1HOFS
    ; lda bg1_scry+1
    ; sta BG1VOFS
    ; lda bg1_scry
    ; sta BG1VOFS

    ; lda bg2_scrx+1
    ; sta BG2HOFS
    ; lda bg2_scrx
    ; sta BG2HOFS
    ; lda bg2_scry+1
    ; sta BG2VOFS
    ; lda bg2_scry
    ; sta BG2VOFS



    ; ldx #(64 *4)
	; lda JOY1H
	; bit #PAD_DOWN
	; beq @down_not_pressed
    ;     inc SHADOW_OAM.w + 1, x
	; @down_not_pressed:
	; bit #PAD_UP
    ; beq @up_not_pressed
    ;     dec SHADOW_OAM.w + 1, x
    ; @up_not_pressed:
	; bit #PAD_LEFT
	; beq @right_not_pressed
    ;     inc SHADOW_OAM.w, x
	; @right_not_pressed:
	; bit #PAD_RIGHT
    ; beq @left_not_pressed
    ;     dec SHADOW_OAM.w, x
    ; @left_not_pressed:
	; bit #PAD_START
    ; beq @start_not_pressed
    ;     pha
    ;     stz CursorX
    ;     stz CursorY
    ;     ldx #$2020
    ;     stx func_ram+1
    ;     jsr PrintString
    ;     pla
    ; @start_not_pressed:
	; bit #PAD_SELECT
    ; beq @select_not_pressed
    ;     pha
    ;     stz CursorX
    ;     stz CursorY
    ;     stz func_ram+1
    ;     jsr PrintString
    ;     pla
    ; @select_not_pressed:

    ; jsr DoObjectTick
	jmp main_loop

;x == offset
CreateNewObject:
    ;make x speed
    jsr Rand
    and #%00111111
    sec
    adc #0
    sta OBJECTS.w, x
    stz OBJECTS.w+1, x
    ;make x pos
    jsr Rand
    sta OBJECTS.w+2, x
    jsr Rand
    sta OBJECTS.w+3, x
    ;make y speed
    lda #30
    sta OBJECTS.w+4, x
    stz OBJECTS.w+5, x
    ;make y pos
    stz OBJECTS.w+6, x
    stz OBJECTS.w+7, x

    rts

DoObjectTick:
    ;iterate all objects
    ldx #0
    @loop:
    phx

    lda OBJECTS.w, x
    beq @end_early

    jsr Rand
    cmp #$fe
    bcc @no_flip
    lda OBJECTS.w, x
    eor #$ff
    sta OBJECTS.w, x
    lda OBJECTS.w+1, x
    eor #$ff
    sta OBJECTS.w+1, x
    @no_flip:

    ;add x spd to x pos
    clc
    lda OBJECTS.w+2, x
    adc OBJECTS.w, x
    sta OBJECTS.w+2, x

    lda OBJECTS.w+3, x
    adc OBJECTS.w+1, x
    sta OBJECTS.w+3, x
    pha

    ;add y spd to y pos
    clc
    lda OBJECTS.w+6, x
    adc OBJECTS.w+4, x
    sta OBJECTS.w+6, x

    lda OBJECTS.w+7, x
    adc OBJECTS.w+5, x
    sta OBJECTS.w+7, x
    pha

    clc
    cmp #$e8
    bcc @no_make
    pla
    pla
    ;make a new object if object is out of screen
    jsr CreateNewObject
    bra @end_early
    @no_make:


    ;x = (x / 2) + $100 for oam
    ;make accumulator 16
    rep #FLAG_ACCUM16
    txa
    lsr
    adc #$100
    tax
    lda #0
    ;make accumulator 8
    sep #FLAG_ACCUM16

    ;get y
    pla
    sta SHADOW_OAM.w+1, x
    ;get x
    pla
    sta SHADOW_OAM.w, x
    ;get tile
    lda #$21
    sta SHADOW_OAM.w+2, x
    ;get priority
    lda #%00110000
    sta SHADOW_OAM.w+3, x


    @end_early:
    plx
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    inx
    cpx #$100
    bne @loop

    rts

DoOAMDMA:
    @WaitVblank:
        lda HVBJOY
        and #%10000000
        beq @WaitVblank

	; Copy OAM data via DMA
	stz OAMADDL
	lda #%00000000
	sta DMAP1
	lda #lobyte(OAMDATA)
	sta BBAD1
	ldx #loword(SHADOW_OAM)
	stx A1T1L
	lda #bankbyte(SHADOW_OAM)
	sta A1B1
	ldx #$220
	stx DAS1L
	lda #%00000010
	sta MDMAEN

    rts


Menu_DrawWords:

    ;store starting x
    lda CursorX
    sta func_ram

    ldy #0 ;offset
    @again:
    lda [z_L],y
    beq @done
    cmp #1
    beq @newline
    jsr Menu_PrintChar
    iny
    jmp @again
    @done:
    rts

    @newline:
    inc CursorY
    lda func_ram
    sta CursorX
    iny
    jmp @again



.EQU sprite_xpos func_ram+1
.EQU sprite_index func_ram+2
Menu_PrintChar:
    and #%11011111
    beq @imm_end
    ;adjust to font
    sec
    sbc #$41
    pha
    and #%00010000
    beq @no_adjust
    pla
    clc
    adc #$10
    pha
    @no_adjust:
    pla
    clc
    adc #$30

    ;store char
    pha

    ;make xpos
    ;a = (y + CursorX) << 3
    clc
    tya
    adc CursorX
    asl
    asl
    sta sprite_xpos

    ;sprite index << 2
    lda sprite_index
    asl
    asl
    tax

    ;write top of letter
    lda sprite_xpos
    sta SHADOW_OAM.w, x
    lda CursorY
    sta SHADOW_OAM.w+1, x
    pla
    sta SHADOW_OAM.w+2, x
    pha
    ;set priority
    lda #%00100000
    sta SHADOW_OAM.w+3, x

    inc sprite_index
    ;sprite index << 2
    lda sprite_index
    asl
    asl
    tax

    ;write bottom of letter
    lda sprite_xpos
    sta SHADOW_OAM.w, x
    lda CursorY
    clc
    adc #8
    sta SHADOW_OAM.w+1, x
    pla
    clc
    adc #$10
    sta SHADOW_OAM.w+2, x
    ;set priority
    lda #%00100000
    sta SHADOW_OAM.w+3, x

    inc sprite_index

    @imm_end:
    inc CursorX
    rts

PrintString:
    rts
    ;store starting x
    lda CursorX
    sta func_ram

    ldy #0 ;offset
    @again:
    lda [z_L],y
    beq @done
    cmp #1
    beq @newline
    jsr PrintChar
    iny
    jmp @again
    @done:
    rts

    @newline:
    inc CursorY
    lda func_ram
    sta CursorX
    iny
    jmp @again


PrintChar:
    and #%11011111
    beq @space
    ;adjust to font
    sec
    sbc #64
    clc
    adc func_ram+1
    @space:
    pha
    ldx z_L
    phx
    lda CursorY
    sta z_L+1

    lda #0
    clc
    ror z_L+1
    ror
    ror z_L+1
    ror
    ror z_L+1
    ror
    adc CursorX
    sta z_L
    WaitVblank:
        lda HVBJOY
        and #%10000000
        beq WaitVblank

    ;set vmaddr
    ldx z_L
    stx VMADDL
    lda #hibyte(BG3_MAP)
    sta VMADDH

    plx
    stx z_L
    pla
    sta VMDATAL
    lda #%00100000
    sta VMDATAH
    inc CursorX
    rts

;z_L == addr
;x == cg at
;y == rom at
;func_ram == size
LoadPalette:
    ;clear a
    and #0
    tay

@loop:
    phy

    ;CGADD = x (8 bit)
    txa
    sta CGADD

    tya
    asl
    tay

    ;get palette 16 bit
    lda [z_L],y
    sta CGDATA
    iny
    lda [z_L],y
    sta CGDATA

    ply

    iny
    inx
    dec func_ram
    bne @loop

    rts

;z_L == addr
;y == at
;func_ram == size
LoadGfx_1bpp:
    ;write vmaddl + vmaddh (16 bit)
    sty VMADDL

    ldy #0
    @loop:
    lda [z_L], y ;whole word
    sta VMDATAL
    sta VMDATAH
    iny

    cpy func_ram
    bne @loop

    rts


;z_L == addr
;y == at
;func_ram == size
LoadGfx:
    ;make accumulator 16
    rep #FLAG_ACCUM16
    ;write vmaddl + vmaddh (16 bit)
    sty VMADDL

    ldy #0
    @loop:
    lda [z_L], y ;whole word
    sta VMDATAL
    iny
    iny

    cpy func_ram
    bne @loop

    ;make accumulator 8
    sep #FLAG_ACCUM16
    rts

;Sets up hardware stuff
MemoryInit:
    ;clear ram
	ldx #0
    @zero_ram:
	stz 0, x
    inx
	cpx #$100
	bne @zero_ram

    ;clean shadow_oam
    jsr ClearOam

    ;lda #8
    ;sta PPUCTRL ; Sprite pattern table at $1000
    ;sta ram_PPUCTRL

    ; CHR inversion: two 2KB banks at $1000-$1FFF, four 1KB banks at $0000-$0FFF
    ;lda #$80
    ;sta bankswitch_flags
    ;sta BANKSELECT

    ;lda #$18
    ;sta PPUMASK ; Enable BG and OBJ
    ;sta ram_PPUMASK

    ;lda #0
    ;sta MIRROR ; Vertical nametable mirroring

    rts

ClearOam:
    ;put all oam y's out of range
    ; lda #$f0
    ; @clear:
    ; sta SHADOW_OAM.w, x
    ; inx
    ; inx
    ; inx
    ; inx
    ; bne @clear

    ; ClearOam_rts:

	ldx #0
    @zero_oam:
	stz SHADOW_OAM.w, x
    inx
	lda #$ed
	sta SHADOW_OAM.w, x
    inx
	stz SHADOW_OAM.w, x
    inx
	stz SHADOW_OAM.w, x
    inx
	cpx #$200
	bne @zero_oam

    rts

nmi:
	bit RDNMI
	inc nmi_count.w

    ;if nmi_mode & NMI_MODE::SKIP, exit immediately
    bit nmi_mode
    bpl @do_nmi
    rti
    @do_nmi:
    jsl NmiHandler
_rti:
	rti

Rand:
    clc
    lda random_num
    adc random_num+1
    sta random_num+1
    clc
    lda random_num
    adc #$75
    sta random_num
    lda random_num+1
    adc #$63
    sta random_num+1

    rts

GFXTEST:
@gfx:
.incbin "artifacts/us/chr/title.2bpp"
@gfx_END:

GFXTEST_spr:
@gfx:
.incbin "artifacts/us/chr/earth.4bpp"
@gfx_END:

NES_NTSC_BGR5:
.incbin "palettes/nes_bgr5.pal"

Title_Palette_Old:
    .byte $0f, $28, $30, $18
    .byte $0f, $21, $30, $12
    .byte $0f, $16, $30, $12
    .byte $0f, $3a, $30, $12

    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12

produced_by_tiles:
    ;produced by
    set_pos 13, 11
    .byte $C8,$C9,$CA,$CB,$CD,$CE,$CF
    .byte 1
    ;tail of p
    set_pos 13, 12
    .byte $D8
    .byte 1
    ;tail of y
    set_pos 19, 12
    .byte $DF
    .byte 1

    ;line
    set_pos 13, 13
    repeatTile $CC, 19
    .byte 1

    ;Nintendo
    set_pos 13, 15
    .byte $E3,$E4,$E5,$E6,$E7,$E8
    .byte 0

; $9EEA - presented by SHIGESATO ITOI
presented_by_tiles:
    ;presented by
    set_pos 13, 11
    .byte $D9,$DA,$DB,$DC,$DD,$DE,$CE,$CF
    .byte 1
    ;tail of p
    set_pos 13, 12
    .byte $D8
    .byte 1
    ;tail of y
    set_pos 20, 12
    .byte $DF
    .byte 1

    ;line
    set_pos 0, 13
    repeatTile $CC, 21
    .byte 1

    ;SHIGESATO ITOI
    set_pos 8, 15
    .byte $F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
    .byte 0

; $9F18 - title screen
title_screen_tiles:
    ;EARTHBOUND logo
    set_pos 8, 7
    .byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C
    .byte 1
    .byte $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC
    .byte 1
    .byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
    .byte 1
    .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
    .byte 1
    .byte $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE
    .byte 1
    .byte $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE
    .byte 1
    .byte $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE
    .byte 1

    ;c 1989/1990
    ;SHIGESATO ITOI / NINTENDO
    set_pos 7, 23
    .byte $43,$44,$45,$46,$47,$70
    .byte $69,$6A,$6B,$6C,$6D,$6E,$6F,$53,$54,$55,$56,$57
    .byte 0

produced_by_TEST:
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C8, $C9, $CA
.db $CB, $CD, $CE, $CF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $D8, $00, $00
.db $00, $00, $00, $DF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $CC, $CC, $CC
.db $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E3, $E4, $E5
.db $E6, $E7, $E8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
