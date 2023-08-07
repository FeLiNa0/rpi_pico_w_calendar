#!/bin/sh
files="$1"

if [ -z "$1" ] || [ "$1" = "-h" ]; then
    echo "Use this script to find certain lines containing MicroPython API code within the specified Python file."
    echo "  $0 [PYTHON FILES]"
    exit 0
fi

find() {
  pattern="$1"
  echo "Finding all uses of $pattern"
  ag --nofilename "$pattern" "$files" | \
    sed 's/\#.*$/COMMENT/g' | \
    sed 's/^[ \t]*//g' | \
    sed 's/[\t ]*$//g' | \
    sort | uniq -c
  echo
}

find 'utime'
find 'framebuf|(self.image.*)|(self.buffer.*)'
find 'Pin|(self.*_pin)|(.*_PIN)'
find 'SPI|(self.spi)'
