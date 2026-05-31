;clear carry
clc
;16 bit mode 65816
xce

;stop interrupts
sei

; begin executing from correct bank
; at reset, bank will always be $00 but we want to run from $80 in case we
; want to use fastrom someday
jml _reset_long
_reset_long:

sep #FLAG_ACCUM16

lda #%10001111
sta INIDISP ; Turn off screen ("forced blank")


rep #FLAG_ACCUM16

; ZeroCPU registers NMITIMEN through MEMSEL
stz $4200
stz $4202
stz $4204
stz $4206
stz $4208
stz $420A
stz $420C

; Zero some registers used for rendering
stz OAMADDL
stz BGMODE
stz BG1SC
stz BG3SC
stz BG12NBA
stz VMADDL
stz W12SEL
stz WH0
stz WH2
stz WBGLOG
stz TM
stz TS
stz TMW
stz SETINI

; Disable color math / etc
stz CGWSEL
stz COLDATA

sep #FLAG_ACCUM16

stz MOSAIC
stz WOBJSEL