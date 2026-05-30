def do(infile, outfile, depth=2, shift=0):
    binary = open(infile, "rb").read()

    outbinary = bytearray()
    i = 0
    while i < len(binary):
        tile = bytearray(binary[i:i+16])
        plane1 = tile[:8]
        plane2 = tile[8:]
        new_tile = [item for pair in zip(plane1, plane2) for item in pair]
        outbinary += bytearray(new_tile)
        #pad other planes if 4bpp
        if depth == 4:
            outbinary += bytearray(16 * [0])
        i += 16

    open(outfile, "wb").write(outbinary)