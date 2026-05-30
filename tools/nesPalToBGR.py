binary = """
    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12
    .byte $0f, $21, $30, $12
    """
binary = binary.replace("\n", "").replace(".byte ", "").replace("$", "").replace(", ", "").replace(" ", "")
actu = bytearray()
i = 0
while i < len(binary):
    actu.append(int(binary[i:i+2], 16))
    i += 2
binary = actu

bgr5 = open("palettes/nes_bgr5.pal", "rb").read()

out_binary = bytearray()

i = 0
while i < len(binary):
    nes_id = binary[i]
    out_binary += bgr5[nes_id*2:(nes_id+1)*2]
    i += 1

open("artifacts/us/chr/earth.pal", "wb").write(out_binary)