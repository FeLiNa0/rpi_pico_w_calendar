SERIAL_DEVICE=/dev/ttyACM0
ADAFRUIT_CIRCUITPY_VERSION := 8.2.2
UF2_FILE := ./deps/uf2/adafruit-circuitpython-pico_w-en_US-$(ADAFRUIT_CIRCUITPY_VERSION).uf2

BASE_DEST:=/run/media/$(shell whoami)
BOOTLOADER=${BASE_DEST}/RPI-RP2
DEST:=${BASE_DEST}/CIRCUITPY

get-upstream:
	git clone git@github.com:waveshareteam/Pico_ePaper_Code.git ./deps/Pico_ePaper_Code

flash-circuitpython: clean wait-for-bootloader
	wget -O $(UF2_FILE) \
		https://downloads.circuitpython.org/bin/raspberry_pi_pico_w/en_US/adafruit-circuitpython-raspberry_pi_pico_w-en_US-$(ADAFRUIT_CIRCUITPY_VERSION).uf2
	cp $(UF2_FILE) $(BOOTLOADER)

install-libraries:
	# --compile 
	pipkin --mount $(DEST) install -r requirements.txt

wait-for-dest:
	@echo Will loop until $(DEST) is mounted
	while [ ! -d $(DEST) ] ; do sleep 1 ; done

wait-for-bootloader:
	@echo Will loop until $(BOOTLOADER) is mounted
	while [ ! -d $(BOOTLOADER) ] ; do sleep 1 ; done

cp:
	cp -r src/* $(DEST)/

diff:
	diff ${DEST}/settings.toml settings.toml
	diff -r ${DEST}/ src/ \
	  --exclude='.*' --exclude=settings.toml --exclude=boot_out.txt --exclude=lib
	echo "No changes"

dev:
	@echo Your code should only re-run when you make changes to it
	watch -n1 'make diff || make cp'

open-serial-console:
	# Pico W CircuitPython baud rate is 115200, or 11520 characters per second
	# https://learn.adafruit.com/welcome-to-circuitpython/advanced-serial-console-on-linux
	@[ -c ${SERIAL_DEVICE} ] || ( echo "Serial device not found ${SERIAL_DEVICE}" ; exit 1 )
	@echo Try running this as root user or with sudo
	screen ${SERIAL_DEVICE} 115200

clean:
	rm -rf ./deps/uf2
