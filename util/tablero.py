FUERA_DEL_TABLERO = "\x1b[38;5;000;48;5;000m %c \x1b[0m\x00"
DENTRO_DEL_TABLERO = "\x1b[38;5;000;48;5;051m %c \x1b[0m\x00"

BUFFER = ""

for i in range(7):
    for j in range(7):
        if ((i <= 1 and j <= 1) or
            (i >= 5 and j <= 1) or
            (i <= 1 and j >= 5) or
            (i >= 5 and j >= 5)):
            BUFFER += FUERA_DEL_TABLERO
        else:
            BUFFER += DENTRO_DEL_TABLERO

with open("./build/tablero.dat", "wb") as f:
    f.write(BUFFER.encode("ascii"))
