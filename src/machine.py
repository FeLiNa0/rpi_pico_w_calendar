import board
import busio
import digitalio

# AKA DC PIN
# Pico Zero: MISO aka GPIO4 aka RX0 (receive) for SPI protocol
# Waveshare: DC aka Data/Command control pin (High: Data; Low: Command)
# CircuitPython tutorial: MISO = main output, secondary input\u2019
# Reset pin
SPI0_RX_MISO_PIN = board.GP4
SPI1_RX_MISO_PIN = board.GP8

# AKA CS PIN
# Pico Zero: RX aka GPIO5 aka CSn0 (chip select) for SPI protocol
# Waveshare: CS aka Chip select pin of SPI interface, Low active
# CircuitPython tutorial: most chips have a CS, or chip select, wire which is toggled to tell the chip that it should listen and respond to requests on the SPI bus. Each device requires its own unique CS line.
SPI0_CHIP_SELECT_PIN = board.GP5
SPI1_CHIP_SELECT_PIN = board.GP9

# Pico Zero: SCK aka GPIO6 aka SCK0 (SPI clock) for SPI protocol
# Waveshare: CLK aka SCK pin of SPI interface, clock input
# CircuitPython tutorial: most chips have a CS, or chip select, wire which is toggled to tell the chip that it should listen and respond to requests on the SPI bus. Each device requires its own unique CS line.
SPI0_CLOCK_PIN = board.GP6
SPI1_CLOCK_PIN = board.GP10

# Pico Zero: MOSI aka GPIO3 aka TX0 (transmit) for SPI protocol
# Waveshare: DIN aka MOSI pin of SPI interface, data transmitted from Master to Slave.
SPI0_TX_MOSI_PIN = board.GP3
SPI1_TX_MOSI_PIN = board.GP11

class Pin:
    PULL_UP = digitalio.Pull.UP
    PULL_DOWN = digitalio.Pull.DOWN
    OUT = digitalio.Direction.OUTPUT
    IN = digitalio.Direction.INPUT
    DC_PIN   = 8
    CS_PIN   = 9
    RST_PIN  = 12
    BUSY_PIN = 13

    def __init__(self, pin_gpio_number, direction, pull=None):
        if pin_gpio_number == Pin.DC_PIN:
            self.pin_obj = SPI1_RX_MISO_PIN
        elif pin_gpio_number == Pin.CS_PIN:
            self.pin_obj = SPI1_CHIP_SELECT_PIN
        elif pin_gpio_number == Pin.RST_PIN:
            self.pin_obj = board.GP12
        elif pin_gpio_number == Pin.BUSY_PIN:
            self.pin_obj = board.GP13
        else:
            raise Exception("Unknown PIN ID " + str(pin_gpio_number))

        self.pin = digitalio.DigitalInOut(self.pin_obj)
        self.pin.direction = direction
        if direction == Pin.IN and pull is not None:
            self.pin.pull = pull

    def __call__(self, new_value):
        self.pin.value = new_value

    def value(self) -> None:
        return self.pin.value


class SPI:
    def __init__(self, spi_channel):
        self.spi = busio.SPI(SPI1_CLOCK_PIN, MOSI=SPI1_TX_MOSI_PIN)

    def init(self, baudrate):
        if not self.spi.try_lock():
            raise RuntimeError("SPI device is locked")
        self.spi.configure(baudrate=baudrate)
        self.spi.unlock()

    def write(self, this_bytearray):
        if not self.spi.try_lock():
            raise RuntimeError("SPI device is locked")
        self.spi.write(this_bytearray)
        self.spi.unlock()
