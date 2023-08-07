import time

import adafruit_framebuf
from upstream.pico_epd_2in66 import EPD_2in66

PIXEL_FORMAT = adafruit_framebuf.MVLSB

def draw():
    epd = EPD_2in66()
    image = adafruit_framebuf.FrameBuffer(epd.buffer_Landscape, epd.height, epd.width, PIXEL_FORMAT)
    image.fill(0x00)
    image.text("RPi Pico Zero", 0, 40, 0xFF)
    
    time.sleep(1)
    epd.init(0)
    epd.Clear(0xFF)
    time.sleep(2)
    epd.display_Landscape(epd.buffer_Landscape)
    print("Drawing done. Putting screen to sleep")
    epd.sleep()
