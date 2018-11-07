#
# RISC-V Emulator
#
# Copyright (c) 2016-2017 Fabrice Bellard
# Copyright (c) 2018 Esperanto Technology
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

CC=gcc
CFLAGS_OPT=-O2
CFLAGS=$(CFLAGS_OPT) -Wall -std=gnu99 -g -Werror -Wno-parentheses -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -MMD
CFLAGS+=-D_GNU_SOURCE -DCONFIG_VERSION=\"$(shell cat VERSION)\"
LDFLAGS=

bindir=/usr/local/bin
INSTALL=install
PROGS=riscvemu libvharness.a libriscvemu_cosim.a

all: $(PROGS)

EMU_OBJS:=virtio.o pci.o fs.o cutils.o iomem.o \
    json.o machine.o elf64.o

RISCVEMU_OBJS:=$(EMU_OBJS) riscvemu.o riscv_machine.o softfp.o riscvemu_main.o

EMU_OBJS+=fs_disk.o
EMU_LIBS=-lrt

riscvemu: vharness.o libriscvemu_cosim.a
	$(CC) $(LDFLAGS) -o $@ $^ $(RISCVEMU_LIBS) $(EMU_LIBS)

# Deprecated
libvharness.a: vharness.o riscv_cpu64.o riscvemu.o \
	riscv_machine.o softfp.o $(EMU_OBJS)
	ar rvs $@ $^

vharness.o: vharness.c
	$(CC) $(CFLAGS) -DMAX_XLEN=64 -c -o $@ $<

libriscvemu_cosim.a: riscvemu_cosim.o riscv_cpu64.o riscvemu.o \
	riscv_machine.o softfp.o $(EMU_OBJS)
	ar rvs $@ $^

riscvemu_cosim.o: riscvemu_cosim.c
	$(CC) $(CFLAGS) -DMAX_XLEN=64 -c -o $@ $<

riscvemu.o: riscvemu.c
	$(CC) $(CFLAGS) -DCONFIG_CPU_RISCV -c -o $@ $<

riscv_cpu64.o: riscv_cpu.c
	$(CC) $(CFLAGS) -DMAX_XLEN=64 -c -o $@ $<

install: $(PROGS)
	$(INSTALL) -m755 $(PROGS) "$(DESTDIR)$(bindir)"

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

debug:
	$(MAKE) CFLAGS_OPT=

clean:
	rm -f *.o *.d *~ $(PROGS)

-include $(wildcard *.d)
