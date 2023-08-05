SERIAL_DEVICE=/dev/ttyACM0
ADAFRUIT_CIRCUITPY_VERSION := 8.2.2
C := ./dependencies/adafruit-circuitpython-pico_w-en_US-$(ADAFRUIT_CIRCUITPY_VERSION).uf2

BASE_DEST:=/run/media/$(shell whoami)
BOOTLOADER=${BASE_DEST}/RPI-RP2
DEST:=${BASE_DEST}/CIRCUITPY

$(BOOTLOADER):
	@test ! -d $(BOOTLOADER) \
		&& echo "If this directory does not exist:" \
		&& echo "unplug your Pico W and then press the BOOTSEL button and plug it back in" \
		&& exit 1

flash-circuitpython: clean $(BOOTLOADER)
	mkdir -p ./dependencies
	wget -O $(C) \
		https://downloads.circuitpython.org/bin/raspberry_pi_pico_w/en_US/adafruit-circuitpython-raspberry_pi_pico_w-en_US-$(ADAFRUIT_CIRCUITPY_VERSION).uf2
	cp $(C) $(BOOTLOADER)

install-libraries:
	pipkin --mount $(DEST) install --compile -r requirements.txt

wait-for-dest:
	@echo Will loop until $(DEST) is mounted
	while [ ! -d $(DEST) ] ; do sleep 1 ; done

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
	rm -rf ./dependencies
