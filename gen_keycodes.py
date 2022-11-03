# source: https://upload.wikimedia.org/wikipedia/commons/6/66/Ps2_de_keyboard_scancode_set_2.svg

codes = {
    # first row
    "ESC": 0x76,
    "F1": 0x05,
    "F2": 0x06,
    "F3": 0x04,
    "F4": 0x0C,
    "F5": 0x03,
    "F6": 0x0B,
    "F7": 0x83,
    "F8": 0x0A,
    "F9": 0x01,
    "F10": 0x09,
    "F11": 0x78,
    "F12": 0x07,
    "SLEEP": 0xE03F,
    "WAKEUP": 0xE05E,
    "POWER": 0xE037,

    # second row
    "CIRCUMFLEX": 0x0E,
    "1": 0x16,
    "2": 0x1E,
    "3": 0x26,
    "4": 0x25,
    "5": 0x2E,
    "6": 0x36,
    "7": 0x3D,
    "8": 0x3E,
    "9": 0x46,
    "0": 0x45,
    "QUESTION_MARK": 0x4E,
    "BACKTICK": 0x55,
    "BACKSPACE": 0x66,
    # PRINT keycode is weird
    "ROLL": 0x7E,
    # PAUSE keycode is weird
    "NUMLOCK": 0x77,
    "NUM_DIV": 0xE04A,
    "NUM_MUL": 0x7C,
    "NUM_MINUS": 0x7B,

    # third row
    "TAB": 0x0D,
    "Q": 0x15,
    "W": 0x1D,
    "E": 0x24,
    "R": 0x2D,
    "T": 0x2C,
    "Z": 0x35,
    "U": 0x3C,
    "I": 0x43,
    "O": 0x44,
    "P": 0x4D,
    "UE": 0x54,
    "PLUS": 0x5B,
    "ENTER": 0x5A,
    "INSERT": 0xE070,
    "POS1": 0xE06C,
    "PAGE_UP": 0xE07D,
    "NUM_7": 0x6C,
    "NUM_8": 0x75,
    "NUM_9": 0x7D,
    "NUM_PLUS": 0x79,

    # forth row
    "CAPS_LOCK": 0x58,
    "A": 0x1C,
    "S": 0x1B,
    "D": 0x23,
    "F": 0x2B,
    "G": 0x34,
    "H": 0x33,
    "J": 0x3B,
    "K": 0x42,
    "L": 0x4B,
    "OE": 0x4C,
    "AE": 0x52,
    "HASH": 0x5D,
    "DELETE": 0xE071,
    "END": 0xE069,
    "PAGE_DOWN": 0xE07A,
    "NUM_4": 0x6B,
    "NUM_5": 0x73,
    "NUM_6": 0x74,

    # fifth row
    "SHIFT": 0x12,
    "SMALLER": 0x61,
    "Y": 0x1A,
    "X": 0x22,
    "C": 0x21,
    "V": 0x2A,
    "B": 0x32,
    "N": 0x31,
    "M": 0x3A,
    "COMMA": 0x41,
    "PERIOD": 0x49,
    "MINUS": 0x4A,
    "R_SHIFT": 0x59,
    "ARROW_UP": 0xE075,
    "NUM_1": 0x69,
    "NUM_2": 0x72,
    "NUM_3": 0x7A,
    "NUM_ENTER": 0xE05A,

    # sixth row
    "L_CTRL": 0x14,
    "L_WIN": 0xE01F,
    "ALT": 0x11,
    "SPACE": 0x29,
    "ALT_GR": 0xE011,
    "R_WIN": 0xE02F,
    "MENU": 0xE02F,
    "R_CTRL": 0xE014,
    "ARROW_LEFT": 0xE06B,
    "ARROW_DOWN": 0xE072,
    "ARROW_RIGHT": 0xE074,
    "NUM_0": 0x70,
    "NUM_DOT": 0x71,

    "INVALID": 0xFF  # arbitrary definition
}

for name in codes.keys():
    print(f"KEY_{name},")

print("\n\n\n")

for (name, code) in codes.items():
    print(f"KEY_{name} when x\"{code:04X}\",")
