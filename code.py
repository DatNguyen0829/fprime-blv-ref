# CubeSatLink Flight Transceiver Node (Summit)
# Connect to antenna before plug any power in
# Author: Tri Do

import time
import board
import busio
import sdcardio
import storage
import os
import digitalio
import microcontroller
import adafruit_rfm9x
from adafruit_bus_device.spi_device import SPIDevice
from adafruit_lsm6ds.lsm6dsox import LSM6DSOX
import adafruit_lis3mdl


# Initialize UART bus
uart0 = busio.UART(board.GP0, board.GP1, baudrate=9600, bits = 8, parity = None, timeout=1)
uart1 = busio.UART(board.GP4, board.GP5, baudrate=9600, bits = 8, parity = None, timeout=1)
message_started = False
# Status LED
led = digitalio.DigitalInOut(board.GP10)			# This is UART2 LED
led.direction = digitalio.Direction.OUTPUT


# INITIALIZE RF SECTIONS
    # GPIO for RF
CS_RF = digitalio.DigitalInOut(board.GP17)
RESET = digitalio.DigitalInOut(board.GP21)
    # GPIO for enable PA & LNA
RF_RXEN = digitalio.DigitalInOut(board.GP23)
RF_RXEN.direction = digitalio.Direction.OUTPUT
RF_TXEN = digitalio.DigitalInOut(board.GP24)
RF_TXEN.direction = digitalio.Direction.OUTPUT
    # Initialize RF SPI0 bus.
SPI0_CLK = board.GP18
SPI0_MOSI = board.GP19
SPI0_MISO = board.GP20
spi0 = busio.SPI(clock=SPI0_CLK, MOSI=SPI0_MOSI, MISO=SPI0_MISO)
    # Define radio parameters.
RF_RXEN.value = 0
RF_TXEN.value = 0
    # Init RFM9x
RADIO_FREQ_MHZ = 435.75
rfm9x = adafruit_rfm9x.RFM9x(spi0, CS_RF, RESET, RADIO_FREQ_MHZ, agc = True)
    # rfm9x post-config
rfm9x.enable_crc = True
rfm9x.tx_power = 23
rfm9x.spreading_factor = 7
rfm9x.coding_rate = 6
rfm9x.signal_bandwidth = 125000
rfm9x.ack_delay = 0.1		# set delay before sending ACK
rfm9x.node = 8
rfm9x.destination = 7
    # Initialize RFM radio
transmit_interval = 5		# set the time interval (seconds) for sending packets
RFMTimeOut = 10

# INITIALIZE MicroSD AND GNSS SECTIONS
    # GPIO for SD Card & GNSS (SPI bus 1)
CS_SD = board.GP11
CS_GNSS = board.GP13
SPI1_CLK = board.GP14
SPI1_MOSI = board.GP15
SPI1_MISO = board.GP12
spi1 = busio.SPI(clock=SPI1_CLK, MOSI=SPI1_MOSI, MISO=SPI1_MISO)

gnss_cs = digitalio.DigitalInOut(CS_GNSS)
gnss_cs.direction = digitalio.Direction.OUTPUT
gnss_cs.value = True

# Configure SPI device for GNSS
spi1_device = SPIDevice(
    spi1,
    gnss_cs,
    baudrate=1000000,
    polarity=0,
    phase=0
)

GNSS_BUF_LEN = 128
gnss_line_buffer = ""

# INITIALIZE flag and timer
time_now = 0
tnow = 0
uart_now = 0
rfmWatchdog = 0
cnt = 0
NoAck_cnt = 0
uartTxInterval = 3
uart0_receiving = ''
uart1_receiving = ''
gps_message = None


#I2C BUS INIIT
SDA_PIN = microcontroller.pin.GPIO28
SCL_PIN = microcontroller.pin.GPIO29

# GPIO28 = I2C0 SDA
# GPIO29 = I2C0 SCL
i2c = busio.I2C(
    scl=SCL_PIN,
    sda=SDA_PIN,
    frequency=400_000
)

# imu = LSM6DSOX(i2c, address=0x6A)
# magnetometer = adafruit_lis3mdl.LIS3MDL(i2c, address=0x1C)

# START FUNCTION DEF
def Blink_Status_LED():
    # Status LED blink every loop
    led.value = not led.value
    tnow=time.monotonic()
    
def UART_Tx(uart,msg):
    if (msg != None):
        uart.write(msg)
        print("({}). UART transmitting: {}".format(len(msg), msg))
    else:
        print('No UART Tx Message...')
        
def UART_Rx(uart):
    char_buffer = bytearray()
    rx_string = bytearray()
    while uart.in_waiting > 0:
        char_buffer = uart.read(1)
        rx_string = rx_string + char_buffer
    string = ''.join([chr(b) for b in rx_string])
    return string
    #.decode('utf-8','replace') != '':			#not empty
    #    return rx_string.decode('utf-8','ignore')
     

def incCnt():
    global cnt
    cnt += 1
def dspCnt():
    global cnt
    return cnt

def incNAK():
    global NoAck_cnt
    NoAck_cnt += 1

def petRFMWatchdog():
    global rfmWatchdog
    rfmWatchdog = time.monotonic()
    
def RFM_Tx(cust, msg):
    RF_TXEN.value = 1

    incCnt()

    full_msg = f"{cust}, {msg}"
    print("Airing Downlink with Message:", repr(full_msg))

    try:
        rfm9x.send(bytes(full_msg, "UTF-8"))
        SD_Write(cust, msg)
    except Exception as e:
        print("RFM send error:", repr(e))

    RF_TXEN.value = 0
        
def RFM_Rx():
    # Look for packet. Print header, payload, RSSI, SNR
    packet = rfm9x.receive(with_ack=True, with_header=True)
    if packet is not None:
        print("Received (raw header):", [hex(x) for x in packet[0:4]])
        print("Received (raw payload): {0}".format(packet[4:]))
        print("RSSI: {0}, SNR: {1}".format(rfm9x.last_rssi, rfm9x.last_snr))
        return packet[4:]

def parseNeo(dataLine: str):
    talkerID = dataLine[1:3]
    dataLine = dataLine.split(",")
    return f"{talkerID},UTC,{dataLine[1]},N,{dataLine[2]},W,{dataLine[4]},A,{dataLine[9]},G,{dataLine[11]}."

# DEF FOR GNSS
def GNSS():
    global gnss_line_buffer

    gnss_rx = bytearray(GNSS_BUF_LEN)
    gnss_tx = bytearray([0xFF] * GNSS_BUF_LEN)

    try:
        spi1_device = SPIDevice(
            spi1,
            gnss_cs,
            baudrate=1000000,
            polarity=0,
            phase=0
        )
        
        SPI1_Wait_Unlock()

        with spi1_device as spi_dev:
            spi_dev.write_readinto(gnss_tx, gnss_rx)

    except Exception as e:
        print("GNSS SPI failed:", repr(e))
        return None

    useful = bytes(b for b in gnss_rx if b not in (0xFF, 0x00))

    if useful:
        text = useful.decode("ascii", "ignore")
        gnss_line_buffer += text

    while "\r\n" in gnss_line_buffer:
        line, gnss_line_buffer = gnss_line_buffer.split("\r\n", 1)

        if line and len(line) > 6 and line[3:6] == "GGA":
            time.sleep(0.01)
            return parseNeo(line)
    

    return None
sdcard, vfs = None, None

def SD_Init():
    global sdcard, vfs

    try:
        print("init sd...")

        gnss_cs.value = True
        SPI1_Wait_Unlock()
        time.sleep(0.05)

        sdcard = sdcardio.SDCard(spi1, CS_SD, baudrate=1000000)
        print("sector count:", sdcard.count())

        vfs = storage.VfsFat(sdcard)
        storage.mount(vfs, "/sd")

        print("mounted:", os.listdir("/sd"))

        with open("/sd/Dev.csv", "a") as f:
            f.write("\n-----------STARTED-------------\n")
            f.write("time (ms),GroundStation cnt,Summit cnt,CubeSat #,RSSI,SNR, Message\n")
            f.flush()

        for cust in range(3):
            with open(f"/sd/Cube{cust}Data.csv", "a") as f:
                f.write("\n-----------STARTED-------------\n")
                f.write("Count 1,Count 2,CubeSat #, Message\n")
                f.flush()

        # storage.umount("/sd")
        # sdcard.deinit()
        # sdcard = None
        # vfs = None

        SPI1_Wait_Unlock()
        
        time.sleep(0.5)
        gnss_cs.value = True

        print("SD released")

    except Exception as e:
        print("SD init failed:", repr(e))
    
def SPI1_Wait_Unlock():
    while not spi1.try_lock():
        time.sleep(0.001)
    spi1.unlock()

def SD_Write(cust, msg):
    files = {
        "A": "/sd/Cube0Data.csv",
        "B": "/sd/Cube1Data.csv",
        "C": "/sd/Cube2Data.csv"
    }

    filename = files.get(cust)

    if filename is None:
        return

    try:
        # Prevent message newlines from creating multiple CSV rows
        clean_msg = str(msg).replace("\r", "").replace("\n", "\\n")
        clean_msg = clean_msg.replace('"', '""')

        with open(filename, "a") as f:
            f.write('{},{},{},"{}"\n'.format(
                time.monotonic(),
                dspCnt(),
                cust,
                clean_msg
            ))
            f.flush()

        # print("Saved to SD:", filename)

    except Exception as e:
        print("SD write failed:", repr(e))

# DEF FOR IMU
def imuRead():
    
    global imu
    acceleration = imu.acceleration
    
    print("\nAcceleration (m/s^2)")
    print(
        "X: {:8.3f}, Y: {:8.3f}, Z: {:8.3f}".format(
            acceleration[0],
            acceleration[1],
            acceleration[2]
        )
    )

# START CODE
    # send startup message from my_node
rfm9x.send_with_ack(bytes("startup message from node {}".format(rfm9x.node), "UTF-8"))
time.sleep(0.1)

SD_Init()
print("Waiting for packets...")

while True:
    try:
        Blink_Status_LED()

        # -----------------------
        # Read GNSS FIRST
        # -----------------------
        gps = GNSS()
        if gps is not None:
            gps_message = gps
            # print("GNSS:", gps_message)

        # -----------------------
        # Read UART
        # -----------------------
        rx0 = UART_Rx(uart0)
        if rx0:
            uart0_receiving += rx0
            # print("UART0:", repr(rx0))

        rx1 = UART_Rx(uart1)
        if rx1:
            uart1_receiving += rx1
            # print("UART1:", repr(rx1))

        # -----------------------
        # Transmit ONE packet only
        # -----------------------

        if gps_message is not None:
            petRFMWatchdog()
            RFM_Tx('C', gps_message)
            gps_message = None
            time.sleep(0.5)
        
        elif uart0_receiving:
            petRFMWatchdog()
            RFM_Tx('A', uart0_receiving)
            uart0_receiving = ''
            time.sleep(0.5)
        
        elif uart1_receiving:
            petRFMWatchdog()
            RFM_Tx('B', uart1_receiving)
            uart1_receiving = ''
            time.sleep(0.5)

        elif time.monotonic() - rfmWatchdog > RFMTimeOut:
            petRFMWatchdog()
            RFM_Tx('S', "Link healthy, No UART Message")
        
        # READ OUT IMU

        time.sleep(0.5)

    except Exception as e:
        print("Loop Error:", repr(e))


