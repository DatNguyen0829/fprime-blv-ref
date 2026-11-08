import time
import board
import busio
import digitalio
from adafruit_bus_device.spi_device import SPIDevice

SCK = board.GP14
MOSI = board.GP15
MISO = board.GP12
CS_PIN = board.GP13

spi = busio.SPI(
    clock=SCK,
    MOSI=MOSI,
    MISO=MISO
)

cs = digitalio.DigitalInOut(CS_PIN)
cs.direction = digitalio.Direction.OUTPUT
cs.value = True

device = SPIDevice(
    spi,
    cs,
    baudrate=1000000,
    polarity=0,
    phase=0
)

BUF_LEN = 128
line_buffer = ""

def parseNeo(dataLine: str):
    talkerID = dataLine[1:3]
    dataLine = dataLine.split(",")
    return f"{talkerID},UTC,{dataLine[1]},N,{dataLine[2]},W,{dataLine[4]},A,{dataLine[9]},G,{dataLine[11]}."
    
while True:
    
    rx = bytearray(BUF_LEN)
    tx = bytearray([0xFF] * BUF_LEN)

    with device as spi_dev:
        spi_dev.write_readinto(tx, rx)

    useful = bytes(b for b in rx if b not in (0xFF, 0x00))

    if useful:
        text = useful.decode("ascii", "ignore")
        line_buffer += text

        while "\r\n" in line_buffer:
            line, line_buffer = line_buffer.split("\r\n", 1)
            print(line)
            if line and line[3:6] == "GGA":
                    print(parseNeo(line))


    time.sleep(0.1)
