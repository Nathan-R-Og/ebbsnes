.include "include/hardware.asm"
.include "include/enums.asm"
.include "include/macros.asm"

.BANK 1
.ORG $0000

;overrides until we can clean stuff up better
.EQU UNK_60 z_L
.EQU UNK_C0 func_ram
.EQU BANK_CHR1000 pad
.EQU BANK_CHR1400 pad
.EQU BANK_PRGA000 pad
.EQU BANK_PRG8000 pad
.EQU BANK_CHR1800 pad
.EQU BANK_CHR1C00 pad
.EQU IRQLATCH pad.w
.EQU IRQRELOAD pad.w
.EQU PPUADDR pad.w
.EQU IRQENABLE pad.w
.EQU PPUSCROLL pad.w
.EQU PPUCTRL pad.w
.EQU PPUMASK pad.w
.EQU BANK_SWAP pad.w
.EQU BANKSELECT pad.w
.EQU PPUDATA pad.w
.EQU BankswitchMusic pad.w
.EQU Music_Tick pad.w
.EQU B31_1c96 pad.w
.EQU SpriteObjectsToOam pad.w
.EQU ReadPads pad.w
.EQU IncrementFramecounter pad.w

.ACCU 8
.INDEX 16

;Darken Transition
OT0_DefaultTransition:
    sep #FLAG_ACCUM16
    ;backup palette
    jsr BackupPalette
    ;same thing but without the backup lol
    B31_0ddf:
    ldy #5 ;amount of darkens
    @do_another:
    ldx #$1f ;amount of colors - 1
    @darken:
    ;set carry to check if toggled
    sec
    ;get palette[x]
    lda palette_queue.w, x
    ;-= 16
    sbc #$10
    ;skip if still 'carry'
    bcs @darkest
    ;if negative, load default black
    lda #$0f
    @darkest:
    ;load back into
    sta palette_queue.w, x
    dex
    ;if x < 0, break
    bpl @darken

    tya
    tax
    ;force update palette
    jsr B31_0eb5
    dey
    cpy #1
    bne @do_another

    rtl

; $EDFE - Backup palette and fill palette
BackupAndFillPalette:
    pha
    jsr BackupPalette
    pla
    ; FALLTHROUGH
; $EE03 - Fill palette
FillPalette:
    ldx #$1f
    @B31_0e05:
    sta palette_queue.w, x
    dex
    bpl @B31_0e05
    jmp UpdatePalette

; $EE0E - Fill palette background color
FillBackgroundColor:
    pha
    jsr PpuSync
    pla
    ldx #$1f
    @B31_0e15:
    dex
    dex
    dex
    sta palette_queue.w, x
    dex
    bpl @B31_0e15
    jmp UpdatePalette

;lighten
B31_0e21:
    pha
    jsr PpuSync
    pla

    ldx #$1f
    B31_0e28:
    sta palette_backup.w, x
    dex
    bpl B31_0e28
    bmi B31_0e33
    B31_0e30:
    jsr PpuSync
    B31_0e33:
    ldy #5
    @B31_0e35:
    ldx #$1f
    @B31_0e37:
    sec
    lda palette_queue.w, x
    sbc palette_backup.w, x
    beq @B31_0e71
    and #$0f
    bne @B31_0e4d
    bcs @B31_0e56
    lda palette_queue.w, x
    adc #$10
    bpl @B31_0e6e
    @B31_0e4d:
    lda palette_backup.w, x
    and #$0f
    cmp #$0d
    bcc @B31_0e61
    @B31_0e56:
    lda palette_queue.w, x
    sbc #$10
    bcs @B31_0e6e
    lda #$0f
    bpl @B31_0e6e
    @B31_0e61:
    pha
    lda palette_queue.w, x
    and #$30
    sta palette_queue.w, x
    pla
    ora palette_queue.w, x
    @B31_0e6e:
    sta palette_queue.w, x
    @B31_0e71:
    dex
    bpl @B31_0e37
    tya
    tax
    jsr B31_0eb5
    dey
    cpy #1
    bne @B31_0e35
    rtl

; Restore color palette from backup
RestorePalette:
    jsr PpuSync
    ldx #$1f
    @loop:
    lda palette_backup.w, x
    sta palette_queue.w, x
    dex
    bpl @loop
    rts

; Backup up current color palette
BackupPalette:
    sep #FLAG_ACCUM16
    jsr PpuSync
    ldx #$1f
    @loop:
    lda palette_queue.w, x
    sta palette_backup.w, x
    dex
    bpl @loop
    rts

;a == UNK_60 lo
;x == UNK_60 hi
LoadPalette_NES:
    sta UNK_60
    stx UNK_60+2
    jsr PpuSync
    ldy #$1f
    @loop:
    lda (UNK_60), y ;UNK_60 is a palette address
    sta palette_queue.w, y
    dey
    bpl @loop
    bmi UpdatePalette

RestoreAndUpdatePalette:
    jsr RestorePalette
UpdatePalette:
    ldx #1
B31_0eb5:
    sep #FLAG_ACCUM16
    ;add to nmi_queue
    ;04 00
    lda #NMI_COMMANDS_UPDATE_PALETTE
    sta nmi_queue.w
    ;lda #0
    stz nmi_queue.w+1

    ;lda #$00
    stz nmi_data_offset.w

    lda #NMI_MODE_SKIP
    sta nmi_flags.w

    jmp WaitXFrames_Min1

PpuSync:
    wai
    rts


WaitXFrames_Min1_JSL:
    wai
    dex
    bne WaitXFrames_Min1_JSL
    rtl

WaitXFrames_Min1:
    jsr WaitNMI
    dex
    bne WaitXFrames_Min1
    rts

; waits for NMI interrupt to complete
WaitNMI:
    lda #1
    sta nmi_mode
    @loop:
    lda nmi_mode
    bne @loop
    rts

;UNK60 == palette data pointer
LoadPaletteFrom:
    sep #FLAG_ACCUM16
    jsr PpuSync

    ;decrement over the chosen palette (bg and sprite)
    ;send to the palette_queue
    ldy #$1f
    @loop:
    lda (UNK_60), y ;UNK_60 is palette address
    sta palette_queue.w, y
    dey
    bpl @loop

QueuePaletteUpdate:
    ;add to nmi_queue
    ;04 00
    lda #NMI_COMMANDS_UPDATE_PALETTE
    sta nmi_queue.w
    stz nmi_queue.w+1

    stz nmi_data_offset.w

    lda #$80
    sta nmi_flags.w
    rtl

SetBGColorBlack:
    lda #$0f
SetBGColorA:
    pha
    jsr PpuSync
    pla
    ldy #$1c
    @B31_14bf:
    sta palette_queue.w, y
    dey
    dey
    dey
    dey
    bpl @B31_14bf
    jsr QueuePaletteUpdate
    jmp WaitNMI


NmiHandler:
    rep #FLAG_ACCUM16
    rep #FLAG_INDEX16
    ;store all registers
    pha
    phx
    phy
    sep #FLAG_ACCUM16
    sep #FLAG_INDEX16

    ;y = nmi_data_offset
    ldy nmi_data_offset.w

    ;if UNK_E0 == 0, branch
    lda UNK_E0.w
    beq @e0_is_zero
    ;else if nmi_flags != 0, branch
    lda nmi_flags.w
    bne NMI_Next
    ;else, branch
    beq B31_17e5
    @e0_is_zero:
    ;if nmi_flags == 0, branch
    lda nmi_flags.w
    beq B31_17e5
    ;else,
    ;UNK_E0 = nmi_flags & %01111111
    and #%01111111
    sta UNK_E0

;y == nmi_queue offset
NMI_Next:
    tyx
    ;get byte (command?)
    lda nmi_queue.w, x
    ;if byte == 0, branch
    beq @B31_17e3
    ;else if byte.7, branch
    bmi @B31_17dc
    ;else
    ;x = a << 1
    asl a
    tax
    ;jmp to pointer
    lda.l NMI_Commands+1, x
    pha
    lda.l NMI_Commands, x
    pha
    rts

    @B31_17dc:
    and #$7f
    sta nmi_queue.w, y
    bne B31_17e5
    @B31_17e3:
    sta nmi_flags
B31_17e5:
    ;sfaidas
    rep #FLAG_ACCUM16
    rep #FLAG_INDEX16
    ;store all registers
    ply
    plx
    pla
    sep #FLAG_ACCUM16

    lda #0
    sta nmi_mode

    rtl


    ldx irq_count
    beq @B31_1827
    lda #$ff
    sta IRQLATCH
    sta IRQRELOAD ; Interrupt at scanline 255?
    lda #$00
    sta PPUADDR
    sta PPUADDR ; PPUADDR = 0x0000
    lda #$10
    sta PPUADDR
    sta PPUADDR ; PPUADDR = 0x1010
    lda #$00
    sta PPUADDR
    sta PPUADDR ; PPUADDR = 0x0000
    lda #$10
    sta PPUADDR
    sta PPUADDR ; PPUADDR = 0x1010
    lda #$00
    sta PPUADDR
    sta PPUADDR  ; PPUADDR = 0x0000
    stx IRQLATCH
    stx IRQRELOAD ; Interrupt at scanline [$EC]?
    stx IRQENABLE ; Enable IRQ
    stx irq_latch
    sta irq_index
    cli
    @B31_1827:
    ;set ppuscroll
    lda scroll_x.w
    ldx scroll_y.w
    sta PPUSCROLL
    stx PPUSCROLL

    ;set ppuctrl and ppumask
    lda ram_PPUCTRL.w
    ldx ram_PPUMASK.w
    sta PPUCTRL
    stx PPUMASK

    sty nmi_data_offset.w

    ;skip next nmi
    lda #NMI_MODE_SKIP
    sta nmi_mode.w

    ;push current cpu state for switching
    lda bankswitch_mode.w
    pha
    lda current_banks.w+6
    pha
    lda current_banks.w+7
    pha
    .ifndef VER_JP
    lda melody_timer
    beq @B31_185f
    lsr a
    and #$03
    ora #$44
    ldx #BANK_CHR1000
    jsr BANK_SWAP

    ldx #BANK_CHR1400
    jsr BANK_SWAP

    dec melody_timer
    @B31_185f:
    .endif
    ;do music tick
    jsr BankswitchMusic
    jsr Music_Tick

    ;if oam_and_300_clear_flag.7, branch
    lda oam_and_300_clear_flag
    bmi @B31_188a
    ;else

    ;UNK_E1 = UNK_E7 & 0x3F
    lda UNK_E7
    and #$3f
    sta UNK_E1

    ;if UNK_E0, branch
    lda UNK_E0
    bne @B31_1879

    jsr B31_1c96
    jmp @B31_188a

    @B31_1879:
    clc

    ;if UNK_E1 - UNK_E0 sets carry, branch
    ;this (probably) usually results in UNK_E0 -= 1
    sbc UNK_E1
    bcs @B31_1885
    ;else
    ;UNK_E1 = UNK_E0 - 1
    ldx UNK_E0
    dex
    stx UNK_E1
    lda #0
    @B31_1885:
    ;UNK_E0 = result
    sta UNK_E0
    jsr SpriteObjectsToOam
    @B31_188a:

    pla
    ldx #BANK_PRGA000
    jsr BANK_SWAP

    pla
    ldx #BANK_PRG8000
    jsr BANK_SWAP

    pla
    sta bankswitch_mode.w
    ora bankswitch_flags
    sta BANKSELECT
    jsr ReadPads
    lda pad1_press
    ora pad1_forced
    sta pad1_forced
    lda pad2_press
    ora pad2_forced
    sta pad2_forced
    jsr IncrementFramecounter

    lda UNK_D7
    beq @dont_jsr
    jsr UNK_D7
    @dont_jsr:

    lda #0
    sta nmi_mode

    pla
    tay
    pla
    tax
    pla
    rtl

; $F8C1
; NMI Lut
NMI_Commands:
.addr NMI_Next-1 ; 00
.addr NMI_Nothing-1 ; 01
.addr NMI_Branch-1 ; 02
.addr NMI_Goto-1 ; 03
.addr NMI_UpdatePalette-1 ; 04
.addr NMI_PPUWrite-1 ; 05
.addr NMI_PPUWrite32-1 ; 06
.addr NMI_PPUWriteAddrs-1 ; 07
.addr NMI_PPUWriteByte-1 ; 08
.addr NMI_PPURead-1 ; 09
.ifndef VER_JP
    .addr NMI_PPUReadText-1 ; 0A
.endif

; NMI command 1
; args : none
; does : nothing
; NOP
NMI_Nothing:
    ;y++
    iny
    ;bye
    jmp NMI_Next

; NMI command 2
; args : OO (length)
; does : skips ahead OO bytes
; Skip OO bytes in buffer (BRANCH)
NMI_Branch:
    ;y++
    iny
    ;y += nmi_queue[y]
    tya
    sec
    adc nmi_queue.w, y
    tay
    ;bye
    jmp NMI_Next

; NMI command 3
; args : AA (addr)
; does : moves to nmi_queue[AA]
; Go to address AA in buffer (GOTO)
NMI_Goto:
    ;y++
    iny
    ;y = nmi_queue[y]
    lda nmi_queue.w, y
    tay
    ;bye
    jmp NMI_Next

; NMI command 4
; args : none
; does : copies palette_queue into ppu palette
; UPDATE_PALETTE
NMI_UpdatePalette:
    .index 8
    ;PPUADDR = palette
    lda #hibyte($3f00)
    ldx #lobyte($3f00)
    sta PPUADDR
    stx PPUADDR

    stz func_ram

    phy
    ldy #0

    ;copy palette_queue to ppu
    @copy:
    ;set cg id
    lda func_ram
    sta CGADD

    ;get nes id
    tyx
    lda palette_queue.w, x
    ;* 2
    asl
    ;load ntsc pal into cgdata
    tax
    lda.l NES_NTSC_BGR5, x
    sta CGDATA
    lda.l NES_NTSC_BGR5+1, x
    sta CGDATA

    iny
    inc func_ram

    lda #$10
    cmp func_ram
    bne @next
    ;set func_ram to $80 if in the sprite portion :)
    lda #$80
    sta func_ram
    @next:
    cpy #$20
    bne @copy

    ply


    ;PPUADDR = palette
    lda #hibyte($3f00)
    ldx #lobyte($3f00)
    sta PPUADDR
    stx PPUADDR

    ;PPUADDR = 0
    stx PPUADDR
    stx PPUADDR

    ;y++
    iny
    ;bye
    jmp NMI_Next

; NMI command 5
; args : bytecount, ppuaddr, BYTES
; does : writes an arbitray amount of bytes to ppu
; Write MM bytes into PPU address [AA AA]
NMI_PPUWrite:
    jsr NMI_WritePPUBytes
    ;jump straight back if next is cmd 5
    ;not technically needed but probably good practice
    lda nmi_queue.w, y
    cmp #NMI_COMMANDS_PPU_WRITE
    beq NMI_PPUWrite
    ;bye
    jmp NMI_Next

; NMI command 6
; args : bytecount, ppuaddr, BYTES
; does : writes an arbitray amount of bytes to ppu (but with 32-byte increments)
; Same as 05, but with 32-byte address increment
NMI_PPUWrite32:
    ; Increment VRAM address by 32 bytes on read/write
    lda ram_PPUCTRL.w
    ora #%00000100
    sta PPUCTRL

    @loop:
    jsr NMI_WritePPUBytes
    ;jump straight back if next is cmd 6
    ;not technically needed but probably good practice
    ;(more applicable than command 5 at least)
    lda nmi_queue.w, y
    cmp #NMI_COMMANDS_PPU_WRITE_32
    beq @loop

    ;reset ppu control
    lda ram_PPUCTRL.w
    sta PPUCTRL
    ;bye
    jmp NMI_Next

; NMI command 7
; args : loopcount, [ppuaddr, byte]
; does : write groups of [ppuaddr, byte] multiple times
; Write VV into PPU address [AA AA]. Repeat process CC times (PPU_WRITE)
NMI_PPUWriteAddrs:
    ;y++
    iny
    ;x = nmi_queue[y]++
    ldx nmi_queue.w, y
    iny

    @loop:
    ;PPUADDR = nmi_queue[y]++, ++
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    ;PPUDATA = nmi_queue[y]++
    lda nmi_queue.w, y
    sta PPUDATA
    iny

    dex
    bne @loop
    ;bye
    jmp NMI_Next

; NMI command 8
; args : bytecount, ppuaddr, byte
; does : writes a single byte multiple times to ppuaddr
; Fill CC bytes at PPU address [AA AA] with VV (PPU_FILL)
NMI_PPUWriteByte:
    ;y++
    iny
    ;x = nmi_queue[y]++
    ldx nmi_queue.w, y
    iny

    ;PPUADDR = nmi_queue[y]++, ++
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    lda nmi_queue.w, y
    sta PPUADDR
    iny

    ;a = nmi_queue[y]++
    lda nmi_queue.w, y
    iny
    @loop:
    ;PPUDATA = a
    sta PPUDATA
    dex
    bne @loop

    ;bye
    jmp NMI_Next

; NMI command 9
; args : bytecount, ppuaddr
; does : reads an arbitrary amount of bytes from ppuaddr, writes to after this command
; PPU_READ
NMI_PPURead:
    ;y++
    iny
    ;x = nmi_queue[y]++
    ldx nmi_queue.w, y
    iny
    ;PPUADDR = nmi_queue[y]++, ++
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    lda nmi_queue.w, y
    sta PPUADDR
    iny

    lda PPUDATA
    @loop:
    lda PPUDATA
    sta nmi_queue.w, y
    iny
    dex
    bne @loop
    jmp NMI_Next

.ifndef VER_JP
; NMI command A
; args : chr_bank, ppuaddr
; does : reads 64 bytes of text from a specified bank and address
; Read 64 bytes of text data from address [AA AA] in bank BB (READ_TEXT_DATA)
NMI_PPUReadText:
    ;stash bankswitch_mode
    lda bankswitch_mode.w
    pha
    ;stash current tileset chr banks
    lda current_banks.w+4
    pha
    lda current_banks.w+5
    pha
    iny

    ;tileset1 = nmi_queue[y]++
    lda nmi_queue.w, y
    ldx #BANK_CHR1800
    jsr BANK_SWAP
    ;tileset2 = tileset1+1
    clc
    adc #1
    ldx #BANK_CHR1C00
    jsr BANK_SWAP
    iny

    ;PPUADDR = nmi_queue[y]++, ++
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    lda nmi_queue.w, y
    sta PPUADDR
    iny

    ;text_data_buffer[x] = PPUDATA
    lda PPUDATA
    ldx #0
    @write:
    lda PPUDATA
    sta text_data_buffer.w, x
    inx
    cpx #STACK.w-text_data_buffer.w
    bcc @write

    ;restore tileset banks
    pla
    ldx #BANK_CHR1C00
    jsr BANK_SWAP
    pla
    ldx #BANK_CHR1800
    jsr BANK_SWAP

    pla
    sta bankswitch_mode.w

    ora bankswitch_flags
    sta BANKSELECT

    jmp NMI_Next
.endif

;;this could work without all of the bit manip.
;;besides, this is effectively a loop over x but they skip
;;the first 3 bits for some reason. ok man
;;is this optimized for cycles? surely not, right?
.define byte_count UNK_C0
NMI_WritePPUBytes:
    ;byte_count = nmi_queue[y]++
    ;bytecount
    iny
    ldx nmi_queue.w, y
    stx byte_count.w

    ;PPUADDR = nmi_queue[y]++, ++
    iny
    lda nmi_queue.w, y
    sta PPUADDR
    iny
    lda nmi_queue.w, y
    sta PPUADDR

    ;if bytecount.0, copy one byte to ppudata
    iny
    lsr byte_count.w
    bcc @one_byte
    lda nmi_queue.w, y
    sta PPUDATA
    iny
    @one_byte:

    ;if bytecount.1, copy two bytes to ppudata
    lsr byte_count.w
    bcc @two_bytes
    .repeat 2
        lda nmi_queue.w, y
        sta PPUDATA
        iny
    .endr
    @two_bytes:

    ;if bytecount.2, copy four bytes to ppudata
    lsr byte_count.w
    bcc @four_bytes
    .repeat 4
        lda nmi_queue.w, y
        sta PPUDATA
        iny
    .endr
    @four_bytes:

    ;if bytecount == 0, exit
    ldx byte_count.w
    beq @exit
    ;else, write 8 bytes per
    @loop:
    .repeat 8
        lda nmi_queue.w, y
        sta PPUDATA
        iny
    .endr
    dex
    bne @loop

    @exit:
    rts
