# reads FontPage.bmp and emits monochrome binary (encoded as hex)
# fontpage created by http://www.codehead.co.uk/cbfg/
# font is FiraCode regular
# https://www.reddit.com/r/FPGA/comments/w5fq5m/initialize_array_of_std_logic_vector_with_binary/
# https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Initializing-Block-RAM-From-an-External-Data-File-VHDL

# input format: 32 columns, 7 rows, starting at char 32
# output format: row after row -> char after char

import numpy as np
from PIL import Image

char_w = 16
char_h = 24
n_rows = 7
n_cols = 32


in_map = np.array(Image.open("./FontPage.bmp"))
in_mono = in_map[:, :, 0]  # drop color channels

chars = []

for row in range(n_rows):
    for col in range(n_cols):
        x = col * char_w
        y = row * char_h
        char = in_mono[y:(y + char_h), x:(x + char_w)]  # cut out character
        chars.append(char.flatten())  # flatten column major

for char in chars:
    out_bytes = bytearray()

    for i_byte in range(int(char.size / 8)):
        arr = char[i_byte*8:i_byte*8 + 8]  # get a slice of 8 color values
        byte = 0

        # MSB left -> shift from right
        for i_bit in range(8):
            byte <<= 1
            byte |= 1 if arr[i_bit] > 127 else 0
        out_bytes.append(byte)

    print('x"' + out_bytes.hex().upper() + '",')

print("done!")
