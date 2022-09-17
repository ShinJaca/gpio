all: lcdtest clean

# Executáveis

ioset: iomem.o setReg.o
	gcc -o $@ $+
ioclr: iomem_clear.o setReg.o
	gcc -o $@ $+
memmap: memmap.o setReg.o
	gcc -o $@ $+

# Objetos principais

iomem.o: iomem.s
	as -o $@ $<
iomem_clear.o: iomem_clear.s
	as -o $@ $<
memmap.o: memmap.s
	as -o $@ $<

# Bibliotecas

setReg.o: setReg.s
	as -o $@ $<


testec: teste clean
teste: teste.o
	gcc -o $@ $+
teste.o: teste.s
	as -o $@ $<



# LCD

lcd2: lcdtest2 clean
lcdtest2: lcdtest2.o
	gcc -o lcdtest $+
lcdtest2.o: lcdtest.s
	as -o $@ $< -mcpu=cortex-a7

lcdZ: lcdtestZ clean
lcdtestZ: lcdtestZ.o
	gcc -o lcdtest $+
lcdtestZ.o: lcdtest.s
	as -o $@ $< -mcpu=arm1176jz-s



# Input

intest: inputtest clean
inputtest: inputtest.o
	gcc -o $@ $+
inputtest.o: inputtest.s
	as -o $@ $<

clean:
	rm -vf *.o