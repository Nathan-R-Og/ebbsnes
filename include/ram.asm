.RAMSECTION "RAM" SLOT 1
z_L: ds 3 ;0-2
CursorX: ds 1 ;3
CursorY: ds 1 ;4
func_ram: ds 4 ;5-8
nmi_count: ds 2 ;9-$a
bg1_scrx: ds 2; $b-$c
bg1_scry: ds 2; $d-$e
bg2_scrx: ds 2; $f-$10
bg2_scry: ds 2; $11-$12
random_num: ds 2; $13-$14
object_count: ds 1 ; $15
nmi_data_offset: ds 1 ; $16
nmi_flags: ds 1 ; $17
nmi_mode: ds 1 ; $18
UNK_E0: ds 1 ; $19
ram_PPUCTRL: ds 1 ; $1a
ram_PPUMASK: ds 1 ; $1b
scroll_x: ds 1 ; $1c
scroll_y: ds 1 ; $1d
bankswitch_mode: ds 1 ; $1e
current_banks: ds 1 ; $1f
irq_count: ds 1 ; $20
irq_latch: ds 1 ; $21
irq_index: ds 1 ; $22
melody_timer: ds 1 ; $23
oam_and_300_clear_flag: ds 1 ; $24
UNK_E7: ds 1 ; $25
UNK_E1: ds 1 ; $26
bankswitch_flags: ds 1 ; $27
pad1_press: ds 1 ; $28
pad1_forced: ds 1 ; $29
pad2_press: ds 1 ; $2a
pad2_forced: ds 1 ; $2b
UNK_D7: ds 1 ; $2c
pad: ds $d3 ;$2d
STACK: ds $100 ;$100
SHADOW_OAM: ds $200 ;$200
;format
;76tttttt - t=tiles - 0
;oam slot - 1
;x,y - 2,3
;velx,vely - 4,5 (can also be a shake pointer)
;spritedef pointer - 6,7
SPRITE_OBJECTS: ds $100 ; $400 / SpriteDefs

;just an array of nmi commands
nmi_queue: ds $100 ;$500 / nmi queue
palette_queue: ds $20 ;$600 / palette queue
palette_backup: ds $20 ;$620 / palette queue backup
OBJECTS: ds $100 ; $640
text_data_buffer: ds $100 ; $740
.ENDS
.RAMSECTION "RAM7E" BASE $7E SLOT 2
test_7e: ds 2
.ENDS
.RAMSECTION "RAM7F" BASE $7F SLOT 3
test_7f: ds 2
.ENDS
