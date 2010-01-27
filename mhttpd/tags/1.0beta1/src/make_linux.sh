#!/bin/sh
# 32-bit version
/usr/bin/gcc34 mhttpd.cpp -o ../dist/Linux_x86-gcc3/mhttpd -lstdc++ -m32 -v -v
strip ../dist/Linux_x86-gcc3/mhttpd
# 64 bit version
/usr/bin/gcc34 mhttpd.cpp -o ../dist/Linux_x86_64-gcc3/mhttpd -lstdc++ -v -v
strip ../dist/Linux_x86_64-gcc3/mhttpd

