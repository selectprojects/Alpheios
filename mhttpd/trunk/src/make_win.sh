#!/usr/bin/sh
rm -f ../dist/WINNT_x86-gcc3/mhttpd.exe
/bin/gcc mhttpd.cpp -o ../dist/WINNT_x86-gcc3/mhttpd -lstdc++ -mwindows
strip ../dist/WINNT_x86-gcc3/mhttpd.exe
cp ../lib/WINNT_x86-gcc3/cygwin1.dll ../dist/WINNT_x86-gcc3
